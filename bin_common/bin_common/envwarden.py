#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import abc
import argparse
import binascii
import logging
import subprocess
import sys
from datetime import UTC, datetime
from pathlib import Path
from shlex import quote
from typing import Any, NamedTuple

import tomllib

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = """
envwarden exports environmental variables.

Create a TOML config file:

```toml
[shared]
service_api_key = "thiswasntworththemoney"
other_key = "value"

[env."/path/to/thing"]
shared.SERVICE_API_KEY = "service_api_key"
local.LOG_LEVEL = "DEBUG"
```

Then plop those API keys in your environment with:

```bash
eval $(envwarden.py gen --config /path/to/cfg.toml --envname "/path/to/thing")
```

That's a lot to type, and `--envname` defaults to the current directory, so I put the following alias in my `~/.bashrc`:

```bash
ew() {
    eval $(./envwarden.py gen --config /path/to/cfg.toml "$@")
}
```

Then, when I'm in a directory I've specified in the config (`names."/path/to/thing"`), I can just run `ew` and get my environmental variables working

Help:
Please see Benjamin Kane for help.
Code at https://github.com/bbkane/dotfiles
"""  # noqa: E501

logger = logging.getLogger(__name__)


class Error(NamedTuple):
    msg: str


# Yes, we need a String class so we can pattern match...
class String(NamedTuple):
    content: str


class DarwinKeyring(abc.ABC):
    """Darwin (macOS) keyring interface.
    Modified from https://github.com/zalando/go-keyring/blob/master/keyring_darwin.go
    Because the underlying tooling can return either a normal string or a hex-encoded
    string (in the case of non-ascii, newlines), we don't allow storing passwords that
    happen to look hex-encoded. If we did, the get() method wouldn't know whether to
    decode the returned value or not. This can be avoided by base64 encoding all
    passwords like the Go lib does, but I like to be able to read values in the keychain
    Access app.
    """

    EXEC_PATH_KEYCHAIN = "/usr/bin/security"

    @classmethod
    def set(cls, *, service: str, username: str, password: str) -> Error | None:
        """store a secret in the keyring. Cannot store hex-encoded strings"""
        try:
            binascii.a2b_hex(password)
        # ValueError: string argument should contain only ASCII characters
        except (binascii.Error, ValueError):
            pass
        else:
            return Error(
                msg="passord is a hex-encoded string. Cannot store/retrieve safely"
            )
        # fmt: off
        cmd = [
            cls.EXEC_PATH_KEYCHAIN,
            "add-generic-password",
            # Update item if it already exists (if omitted, the item cannot already exist)  # noqa: E501
            "-U",
            # Specify service name (required)
            "-s", service,
            # Specify account name (required)
            "-a", username,
            # Specify password data to be added as a hexadecimal string
            "-X", password.encode('utf-8').hex(),
        ]
        # fmt: on

        logger.debug(f"{cmd = !r}")
        result = subprocess.run(
            args=cmd,
            encoding="utf-8",
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        logger.debug(f"{result = !r}")
        if result.returncode != 0:
            return Error(msg=f"output: {result.stdout}")

        return None

    @classmethod
    def get(cls, *, service: str, username: str) -> String | Error:
        """get password from keychain.
        If returned string can be hex-decoded, we do that
        """

        # fmt: off
        cmd = [
            cls.EXEC_PATH_KEYCHAIN,
            "find-generic-password",
            # Display only the password on stdout
            "-w",
            # Match "service" string
            "-s", service,
            # Match "account" string
            "-a", username,
        ]
        # fmt: on
        logger.debug(f"{cmd = !r}")
        result = subprocess.run(
            args=cmd,
            encoding="utf-8",
            capture_output=True,
            text=True,
        )
        logger.debug(f"{result = !r}")
        if result.returncode != 0:
            return Error(msg=f"stderr output: {result.stderr}")
        value = result.stdout.removesuffix("\n")
        try:
            decoded = str(binascii.a2b_hex(value), encoding="utf-8")
        except binascii.Error:
            return String(content=value)
        else:
            return String(content=decoded)


class KV(NamedTuple):
    key: str
    value: str


class Ref(NamedTuple):
    name: str
    ref_env_name: str
    ref_var_name: str


class ConfigParseResult(NamedTuple):
    kvs: list[KV]
    errors: list[Error]


def print_as_shell(*, pr: ConfigParseResult) -> None:
    logger.debug(f"{pr.errors = !r}")

    if len(pr.errors) > 0:
        for err in pr.errors:
            print(f"echo 'Error:' {quote(err.msg)};")
        return

    for kv in pr.kvs:
        print(f"echo 'Adding:' {quote(kv.key)};")
        print(f"export {quote(kv.key)}={quote(kv.value)};")


def read_config(
    *, config_path: Path, config_data: dict[str, Any], envname: str
) -> ConfigParseResult:
    if envname not in config_data["env"]:
        return ConfigParseResult(kvs=[], errors=[Error(msg=f"{envname!r} not in env")])

    errors: list[Error] = []
    kvs: list[KV] = []

    for kv_name, kv_keyring_name in (
        config_data["env"][envname].get("keyring", {}).items()
    ):
        res = DarwinKeyring.get(service=str(config_path), username=kv_keyring_name)
        match res:
            case Error(_) as err:
                errors.append(Error(msg=f"{kv_name} -> {kv_keyring_name}: {err.msg}"))
            case String(msg):
                kvs.append(KV(key=kv_name, value=msg))

    for kv_name, kv_value in config_data["env"][envname].get("local", {}).items():
        kvs.append(KV(key=kv_name, value=kv_value))

    for kv_name, kv_shared_name in (
        config_data["env"][envname].get("shared", {}).items()
    ):
        if kv_shared_name not in config_data["shared"]:
            errors.append(Error(msg=f"{kv_shared_name!r} not found in shared section"))
        else:
            kvs.append(KV(key=kv_name, value=config_data["shared"][kv_shared_name]))

    return ConfigParseResult(kvs=kvs, errors=errors)


def migrate(config_path: Path, config_data: dict[str, Any]) -> None:

    comment = f"envwarden migration: {datetime.now(UTC).strftime('%Y-%m-%dT%H:%M:%SZ')}"

    # build keys and values for shared env
    shared_env_vars: list[KV] = []
    for key, value in config_data["shared"].items():
        shared_env_vars.append(KV(key=key, value=value))

    # build keys and values for keyring env
    keyring_env_vars: list[KV] = []
    keyring_errors: list[Error] = []
    for envname in config_data["env"]:
        for kv_name, kv_keyring_name in (
            config_data["env"][envname].get("keyring", {}).items()
        ):
            res = DarwinKeyring.get(service=str(config_path), username=kv_keyring_name)
            match res:
                case Error(_) as err:
                    keyring_errors.append(
                        Error(msg=f"{kv_name} -> {kv_keyring_name}: {err.msg}")
                    )
                case String(msg):
                    keyring_env_vars.append(KV(key=kv_keyring_name, value=msg))

    print("set -x")

    # output shared env
    if keyring_errors:
        print("# -- keyring errors")
    for err in keyring_errors:
        print(f"# Error: {err.msg}")

    print("# -- shared env")
    print(f"envelope env create --name shared --comment {quote(comment)}")
    for kv in shared_env_vars:
        print(
            f"envelope env var create --env-name shared --name {quote(kv.key)} --value {quote(kv.value)} --comment {quote(comment)}"
        )
    print()

    # output keyring env
    print("# -- keyring env")
    print(f"envelope env create --name keyring --comment {quote(comment)}")
    for kv in keyring_env_vars:
        print(
            f"envelope env var create --env-name keyring --name {quote(kv.key)} --value {quote(kv.value)} --comment {quote(comment)}"
        )
    print()

    # loop through other envs and create local vars, shared refs, and keyring refs
    for envname in config_data["env"]:

        errors: list[Error] = []
        local_vars: list[KV] = []
        keyring_refs: list[Ref] = []
        shared_refs: list[Ref] = []

        # keyring refs
        for kv_name, kv_keyring_name in (
            config_data["env"][envname].get("keyring", {}).items()
        ):
            keyring_refs.append(
                Ref(
                    name=kv_name,
                    ref_env_name="keyring",
                    ref_var_name=kv_keyring_name,
                )
            )

        # local vars
        for kv_name, kv_value in config_data["env"][envname].get("local", {}).items():
            local_vars.append(KV(key=kv_name, value=kv_value))

        # shared refs
        for kv_name, kv_shared_name in (
            config_data["env"][envname].get("shared", {}).items()
        ):
            if kv_shared_name not in config_data["shared"]:
                errors.append(
                    Error(msg=f"{kv_shared_name!r} not found in shared section")
                )
            else:
                shared_refs.append(
                    Ref(
                        name=kv_name,
                        ref_env_name="shared",
                        ref_var_name=kv_shared_name,
                    )
                )

        # output
        print(f"# {envname = !r}")
        for err in errors:
            print(f"# Error: {err.msg}")

        print(f"envelope env create --name {quote(envname)} --comment {quote(comment)}")

        # local vars
        print("# -- local vars")
        for kv in local_vars:
            print(
                f"envelope env var create --env-name {quote(envname)} --name {quote(kv.key)} --value {quote(kv.value)} --comment {quote(comment)}"
            )

        # shared refs
        print("# -- shared refs")
        for r in shared_refs:
            print(
                f"envelope env ref create --env-name {quote(envname)} --name {quote(r.name)} --ref-env-name {quote(r.ref_env_name)}  --ref-var-name {quote(r.ref_var_name)} --comment {quote(comment)}"
            )

        # keyring refs
        print("# -- keyring refs")
        for r in keyring_refs:
            print(
                f"envelope env ref create --env-name {quote(envname)} --name {quote(r.name)} --ref-env-name {quote(r.ref_env_name)}  --ref-var-name {quote(r.ref_var_name)} --comment {quote(comment)}"
            )

        print()


def print_config_block(envname: str) -> None:
    template = f"""
[env."{envname}"]
local.key = "value"
"""
    print(template)


def add_logger_arg(parser: argparse.ArgumentParser):
    parser.add_argument(
        "--log-level",
        choices=["NOTSET", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        default="INFO",
        help="log level",
    )


def add_config_arg(parser: argparse.ArgumentParser):
    parser.add_argument(
        "--config",
        help="path to TOML config",
        required=True,
        type=Path,
    )


def add_keyring_name_arg(parser: argparse.ArgumentParser):
    parser.add_argument(
        "--name",
        required=True,
        help="keyring value name",
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    subcommands = parser.add_subparsers(dest="subcommand_name", required=True)

    # gen
    gen_cmd = subcommands.add_parser("gen", help="print an environment script")
    add_config_arg(gen_cmd)
    add_logger_arg(gen_cmd)
    gen_cmd.add_argument(
        "--envname",
        default=str(Path().cwd()),
        help="section of the config to print a script form. Defaults to cwd",
    )

    # keyring
    keyring_cmd = subcommands.add_parser("keyring", help="keyring commands")
    keyring_subcommands = keyring_cmd.add_subparsers(
        dest="keyring_subcommand_name",
        required=True,
        help="subcommand name",
    )

    # keyring get
    get_cmd = keyring_subcommands.add_parser("get", help="get value in keyring")
    add_config_arg(get_cmd)
    add_logger_arg(get_cmd)
    add_keyring_name_arg(get_cmd)

    # keyring set
    set_cmd = keyring_subcommands.add_parser("set", help="set value in keyring")
    add_config_arg(set_cmd)
    add_logger_arg(set_cmd)
    add_keyring_name_arg(set_cmd)
    set_cmd.add_argument(
        "--value",
        required=True,
        help="value to store",
    )

    # migrate
    migrate_cmd = subcommands.add_parser(
        "migrate", help="migrate all data in the config"
    )
    add_config_arg(migrate_cmd)
    add_logger_arg(migrate_cmd)

    # print-config-block
    print_config_block_cmd = subcommands.add_parser(
        "print-config-block", help="print a section to add to the config"
    )
    add_logger_arg(print_config_block_cmd)
    print_config_block_cmd.add_argument(
        "--envname",
        default=str(Path().cwd()),
        help="name to put in the 'names' section of the config",
    )

    return parser


def main():
    if sys.platform != "darwin":
        raise SystemError("Only MacOS supported")
    parser = build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        format="# %(asctime)s %(levelname)s %(name)s %(filename)s:%(lineno)s\n%(message)s\n",  # noqa: E501
        level=logging.getLevelNamesMapping()[args.log_level],
    )

    logger.debug(f"{args = !r}")

    match args.subcommand_name:
        case "gen":
            with args.config.open(mode="rb") as fp:
                config = tomllib.load(fp)
            pr = read_config(
                config_data=config, config_path=args.config, envname=args.envname
            )
            print_as_shell(pr=pr)

        case "keyring":
            match args.keyring_subcommand_name:
                case "get":
                    res = DarwinKeyring.get(service=args.config, username=args.name)
                    match res:
                        case Error(msg) as err:
                            raise SystemExit(f"Err: {args.name}: {msg}")
                        case String(msg):
                            print(msg)

                case "set":
                    err = DarwinKeyring.set(
                        service=args.config, username=args.name, password=args.value
                    )
                    if err is not None:
                        raise SystemExit(f"Err: {err.msg}")

                case _:
                    raise SystemExit(
                        f"Unknown keyring subcommand: {args.subcommand_name!r}"
                    )

        case "migrate":
            with args.config.open(mode="rb") as fp:
                config = tomllib.load(fp)
            migrate(config_path=args.config, config_data=config)

        case "print-config-block":
            print_config_block(envname=args.envname)

        case _:
            raise SystemExit(f"Unknown command: {args.subcommand_name!r}")


if __name__ == "__main__":
    main()
