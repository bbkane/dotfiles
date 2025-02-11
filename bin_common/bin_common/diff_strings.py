#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import difflib
import logging
import sys

red = lambda text: f"\033[38;2;255;0;0m{text}\033[38;2;255;255;255m"
green = lambda text: f"\033[38;2;0;255;0m{text}\033[38;2;255;255;255m"
blue = lambda text: f"\033[38;2;0;0;255m{text}\033[38;2;255;255;255m"
white = lambda text: f"\033[38;2;255;255;255m{text}\033[38;2;255;255;255m"

def get_edits_string(old, new):
    result = ""
    codes = difflib.SequenceMatcher(a=old, b=new).get_opcodes()
    for code in codes:
        if code[0] == "equal":
            result += white(old[code[1]:code[2]])
        elif code[0] == "delete":
            result += red(old[code[1]:code[2]])
        elif code[0] == "insert":
            result += green(new[code[3]:code[4]])
        elif code[0] == "replace":
            result += (red(old[code[1]:code[2]]) + green(new[code[3]:code[4]]))
    return result


__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
Diff two strings!

Stolen from https://stackoverflow.com/questions/32500167/how-to-show-diff-of-two-string-sequences-in-colors

Examples:
    {sys.argv[0]}  # will prompt for strings
    {sys.argv[0]} string1 string2
"""

logger = logging.getLogger(__name__)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "string1",
        help="first string",
    )

    parser.add_argument(
        "string2",
        help="second string",
    )

    return parser


def main():
    if len(sys.argv) == 1:
        string1 = input("string1: ")
        string2 = input("string2: ")
    else:
        parser = build_parser()
        args = parser.parse_args()
        string1 = args.string1
        string2 = args.string2

    print(get_edits_string(string1, string2))


if __name__ == "__main__":
    main()

