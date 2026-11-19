#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import contextlib
import csv
import io
import subprocess
import sys
from pathlib import Path

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
**MacOS Specific**

Copy CSV file as rich text for easier pasting into apps like Typora, GDocs, GSheets...

Inspired by https://stackoverflow.com/q/6095497/2958070

Examples:

    cat report.csv | {sys.argv[0]}
"""


def parse_args(*args, **kwargs):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument(
        "infile",
        nargs="?",
        type=Path,
        help="CSV file to read (default: stdin)",
    )

    return parser.parse_args(*args, **kwargs)


def main():
    args = parse_args()

    # Convert CSV to HTML string
    with (
        args.infile.open(encoding="utf-8")
        if args.infile
        else contextlib.nullcontext(sys.stdin)
    ) as infile, io.StringIO() as csvfp:

        def p(s: str):
            print(s, file=csvfp)

        csvreader = csv.reader(infile)
        p("<table>")
        for row in csvreader:
            p("  <tr>")
            for item in row:
                p(f"    <td>{item}</td>")
            p("  </tr>")
        p("</table>")
        csvbytes = bytes(csvfp.getvalue().strip(), encoding="utf-8")

    textutil = subprocess.run(
        [
            "textutil",
            "-stdin",
            "-format",
            "html",
            "-convert",
            "rtf",
            "-stdout",
        ],
        check=True,
        capture_output=True,
        input=csvbytes,
    )

    _ = subprocess.run(
        ["pbcopy"],
        check=True,
        input=textutil.stdout,
    )


if __name__ == "__main__":
    main()
