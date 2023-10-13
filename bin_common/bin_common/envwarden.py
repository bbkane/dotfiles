#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import tomllib
from pathlib import Path
from shlex import quote
from typing import Any, NamedTuple

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


class KV(NamedTuple):
    key: str
    value: str


class Error(NamedTuple):
    msg: str


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


def read_config(*, config: dict[str, Any], envname: str) -> ConfigParseResult:
    if envname not in config["env"]:
        return ConfigParseResult(kvs=[], errors=[Error(msg=f"{envname!r} not in env")])

    errors: list[Error] = []
    kvs: list[KV] = []
    for kv_name, kv_value in config["env"][envname].get("local", {}).items():
        kvs.append(KV(key=kv_name, value=kv_value))

    for kv_name, kv_shared_name in config["env"][envname].get("shared", {}).items():
        if kv_shared_name not in config["shared"]:
            errors.append(Error(msg=f"{kv_shared_name!r} not found in shared section"))
        else:
            kvs.append(KV(key=kv_name, value=config["shared"][kv_shared_name]))

    return ConfigParseResult(kvs=kvs, errors=errors)


def print_config_block(envname: str) -> None:
    template = f"""
[env."{envname}"]
local.key = "value"
"""
    print(template)


def add_common_args(parser: argparse.ArgumentParser):
    parser.add_argument(
        "--log-level",
        choices=["NOTSET", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        default="INFO",
        help="log level",
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    subcommands = parser.add_subparsers(dest="subcommand_name", required=True)

    # gen
    greet_cmd = subcommands.add_parser("gen", help="print an environment script")
    add_common_args(greet_cmd)
    greet_cmd.add_argument(
        "--envname",
        default=str(Path().cwd()),
        help="section of the config to print a script form. Defaults to cwd",
    )

    greet_cmd.add_argument(
        "--config",
        help="config path to read keys and values from",
        required=True,
        type=Path,
    )

    # print-config-block
    print_config_block_cmd = subcommands.add_parser(
        "print-config-block", help="print a section to add to the config"
    )
    add_common_args(print_config_block_cmd)
    print_config_block_cmd.add_argument(
        "--envname",
        default=str(Path().cwd()),
        help="name to put in the 'names' section of the config",
    )

    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        format="# %(asctime)s %(levelname)s %(name)s %(filename)s:%(lineno)s\n%(message)s\n",  # noqa: E501
        level=logging.getLevelName(args.log_level),
    )

    logger.debug(f"{args = !r}")

    match args.subcommand_name:
        case "gen":
            with args.config.open(mode="rb") as fp:
                config = tomllib.load(fp)
            pr = read_config(config=config, envname=args.envname)
            print_as_shell(pr=pr)
        case "print-config-block":
            print_config_block(envname=args.envname)
        case _:
            raise SystemExit(f"Unknown command: {args.subcommand_name!r}")


if __name__ == "__main__":
    main()
