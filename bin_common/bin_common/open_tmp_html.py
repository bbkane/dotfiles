#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import contextlib
import sys
import tempfile
import shutil
import pathlib
import webbrowser

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
Write html input to a tmpfile, then open in a browser. Useful for tablegraph

Examples:
    printf '<h1>Hello JJ</h1>' | {sys.argv[0]}
Help:
Please see Benjamin Kane for help.
Code at <repo>
"""


def parse_args(*args, **kwargs):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument(
        "infile",
        nargs="?",
        type=pathlib.Path,
        help="HTML file to read (default: stdin)",
    )

    parser.add_argument(
        "--silent",
        action="store_true",
        help="Don't print file name to stdout",
    )

    return parser.parse_args(*args, **kwargs)


def main():
    args = parse_args()

    with (
        args.infile.open(encoding="utf-8")
        if args.infile
        else contextlib.nullcontext(sys.stdin)
    ) as infile, tempfile.NamedTemporaryFile(
        mode="w",
        delete=False,
        suffix=".html",
    ) as outfp:
        shutil.copyfileobj(infile, outfp)
        filename = outfp.name
        url = pathlib.Path(filename).as_uri()

    if not args.silent:
        print(f"Wrote:\n  {filename = }\n  {url = }")

    webbrowser.open_new_tab(url)


if __name__ == "__main__":
    main()
