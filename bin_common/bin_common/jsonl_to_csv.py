#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import csv
import json
import sys
import typing as ty

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = """
Normalize a newline delimited JSON log by adding any missing keys with null
values. Super useful for converting logs to spreadsheets

Example:

./jsonl_to.py <<-EOF
    {"a": 1}
    {"a": 1, "b": 2}
EOF
{"a": 1, "b": null}
{"a": 1, "b": 2}

Help:
Please see Benjamin Kane for help.
Code at <repo>
"""


def parse_args(*args, **kwargs):
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )

    # Use a file or stdin for an argument
    # https://stackoverflow.com/a/11038508/2958070
    parser.add_argument(
        "infile",
        nargs="?",
        type=argparse.FileType("r"),
        default=sys.stdin,
        help="newline delimited JSON - file or STDIN",
    )

    parser.add_argument(
        "--format",
        "-f",
        choices=("jsonl", "csv"),
        default="jsonl",
        help="output format",
    )

    return parser.parse_args(*args, **kwargs)


def parse_input_objs(
    input_objs: ty.List[ty.Dict[str, ty.Any]]
) -> ty.List[ty.Dict[str, ty.Any]]:
    """Normalize a list of JSON dicts to have the same keys"""

    # get all the keys
    all_keys: ty.Set[str] = set()
    for input_obj in input_objs:
        all_keys |= input_obj.keys()

    output_objs = []
    for input_obj in input_objs:
        output_obj = dict()
        # if the value for the key doesn't exist, just put None
        for key in all_keys:
            output_obj[key] = input_obj.get(key, None)
        output_objs.append(output_obj)
    return output_objs


def main():
    args = parse_args()

    with args.infile:
        input_objs = [json.loads(line) for line in args.infile]

    output_objs = parse_input_objs(input_objs)

    if len(output_objs) == 0:
        raise SystemError("no rows")

    if args.format == "csv":
        writer = csv.DictWriter(f=sys.stdout, fieldnames=sorted(output_objs[0].keys()))
        writer.writeheader()
        writer.writerows(output_objs)
    elif args.format == "jsonl":
        for output_obj in output_objs:
            print(json.dumps(output_obj, sort_keys=True))
    else:
        raise SystemError(f"Unknown --format: {args.format}")


if __name__ == "__main__":
    main()
