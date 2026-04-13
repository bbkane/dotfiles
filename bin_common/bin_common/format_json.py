#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
import sys
from pathlib import Path

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
Format JSON files

Examples:
    format_json.py file.json
    format_json.py -i file.json file2.json

Help:
Please see Benjamin Kane for help.

https://github.com/bbkane/dotfiles/blob/master/bin_common/bin_common/format_json.py
"""


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "files",
        nargs="+",
        type=Path,
        help="JSON files to format",
    )
    parser.add_argument(
        "-i",
        "--in-place",
        action="store_true",
        help="edit files in place",
    )
    parser.add_argument(
        "--indent",
        type=int,
        default=2,
        help="indentation level (default: 2)",
    )
    parser.add_argument(
        "--sort-keys",
        type=lambda s: s.lower() not in ("false", "0", "no"),
        default=True,
        nargs="?",
        const=True,
        help="sort object keys (default: true). Use --sort-keys false to disable",
    )

    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()

    for path in args.files:
        try:
            text = path.read_text(encoding="utf-8")
            obj = json.loads(text)
            formatted = json.dumps(obj, indent=args.indent, sort_keys=args.sort_keys, ensure_ascii=False) + "\n"
            if args.in_place:
                path.write_text(formatted, encoding="utf-8")
                print(f"formatted: {path}", file=sys.stderr)
            else:
                sys.stdout.write(formatted)
        except json.JSONDecodeError as e:
            print(f"error: {path}: {e}", file=sys.stderr)
            sys.exit(1)
        except FileNotFoundError:
            print(f"error: {path}: file not found", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
