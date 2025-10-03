#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import io
import json
import logging
import sys
import typing
from pathlib import Path

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
Format file, pretty-printing JSON lines

Examples:
    go run . serve | format_jsonl.py fmt

Help:
Please see Benjamin Kane for help.

https://github.com/bbkane/dotfiles/blob/master/bin_common/bin_common/format_jsonl.py
"""

logger = logging.getLogger(__name__)


# https://stackoverflow.com/a/287944/2958070
class col:
    HEADER = "\033[95m"
    BLUE = "\033[94m"
    CYAN = "\033[96m"
    GREEN = "\033[92m"
    WARNING = "\033[93m"
    FAIL = "\033[91m"
    RESET = "\033[0m"
    BOLD = "\033[1m"
    UNDERLINE = "\033[4m"


class NonDictJSONObject(ValueError):
    pass


def fmt(*, stream: typing.TextIO):
    print(col.BOLD + "---" + col.RESET)
    for line in stream:
        try:
            obj = json.loads(line)
            if not isinstance(obj, dict):
                raise NonDictJSONObject()
            sorted_keys = sorted(obj.keys())
            for key in sorted_keys:
                value = obj[key]
                if isinstance(value, str) and "\n" in value:
                    print(col.BLUE + repr(key) + col.RESET + ":" + "\n", value)
                else:
                    print(col.CYAN + repr(key) + col.RESET + ":", value)
            print(col.BOLD + "---" + col.RESET)

        except (json.decoder.JSONDecodeError, NonDictJSONObject):
            # line already ends in "\n"
            print(col.GREEN + "line:" + col.RESET, line, end="")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "--log-level",
        choices=["NOTSET", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        default="INFO",
        help="log level",
    )

    subcommands = parser.add_subparsers(dest="subcommand_name", required=True)

    # greet
    fmt_cmd = subcommands.add_parser("fmt", help="Pretty-print passed file or stdin")
    fmt_cmd.add_argument(
        "--file",
        "-f",
        default="-",
        help="file to print. Defaults to '-', which means print from stdin",
    )

    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        format="# %(asctime)s %(levelname)s %(name)s %(filename)s:%(lineno)s\n%(message)s\n",  # noqa: E501
        level=logging.getLevelNamesMapping()[args.log_level],
    )

    match args.subcommand_name:
        case "fmt":
            path = args.file
            if path == "-":
                # https://stackoverflow.com/a/16549381/2958070
                stream = io.TextIOWrapper(sys.stdin.buffer, encoding="utf-8")
                fmt(stream=stream)
            else:
                with Path(path).expanduser().open(encoding="utf-8") as stream:
                    fmt(stream=stream)
        case _:
            raise SystemExit(f"Unknown command: {args.subcommand_name!r}")


if __name__ == "__main__":
    main()
