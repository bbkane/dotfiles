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
[envvars]
service_api_key = "thiswasntworththemoney"
other_key = "value"

[names."/path/to/thing"]
SERVICE_API_KEY = "service_api_key"
```

Then plop those API keys in your environment with:

```bash
eval $(envwarden.py gen --config /path/to/cfg.toml --key "/path/to/thing")
```

That's a lot to type, and `--key` defaults to the current directory, so I put the following alias in my `~/.bashrc`:

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


def read_config(*, config: dict[str, Any], key: str) -> ConfigParseResult:
    if key not in config["names"]:
        return ConfigParseResult(kvs=[], errors=[Error(msg=f"{key!r} not in names")])

    errors: list[Error] = []
    kvs: list[KV] = []
    for kv_name, kv_envvar_name in config["names"][key].items():
        if kv_envvar_name not in config["envvars"]:
            errors.append(Error(msg=f"{kv_envvar_name!r} not found in envvars"))
        else:
            kvs.append(KV(key=kv_name, value=config["envvars"][kv_envvar_name]))

    return ConfigParseResult(kvs=kvs, errors=errors)


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

    # greet
    greet_cmd = subcommands.add_parser("gen", help="print an environment script")
    add_common_args(greet_cmd)
    greet_cmd.add_argument(
        "--key",
        default=str(Path().cwd()),
        help="section of the config to print a script form. Defaults to cwd",
    )

    greet_cmd.add_argument(
        "--config",
        help="config path to read keys and values from",
        required=True,
        type=Path,
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
            pr = read_config(config=config, key=args.key)
            print_as_shell(pr=pr)
        case _:
            raise SystemExit(f"Unknown command: {args.subcommand_name!r}")


if __name__ == "__main__":
    main()
