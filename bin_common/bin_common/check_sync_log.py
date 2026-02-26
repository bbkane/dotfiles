#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import sys
import pathlib
import collections

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
Check the log for rclone sync --dry-run --combined
Examples:
    {sys.argv[0]}
Help:
Please see Benjamin Kane for help.
Code at <repo>
"""

logger = logging.getLogger(__name__)


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

    # Use a file or stdin for an argument
    # https://stackoverflow.com/a/11038508/2958070
    parser.add_argument(
        "sync_file",
        type=pathlib.Path,
        help="path to the sync log file",
    )

    return parser


def main():

    parser = build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        format="# %(asctime)s %(levelname)s %(name)s %(filename)s:%(lineno)s\n%(message)s\n",  # noqa: E501
        level=logging.getLevelNamesMapping()[args.log_level],
    )

    counter = collections.Counter()
    different_files: list[str] = []
    errors: list[str] = []
    with args.sync_file.open() as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith("="):
                counter["="] += 1
            elif line.startswith("-"):
                counter["-"] += 1
            elif line.startswith("+"):
                counter["+"] += 1
            elif line.startswith("*"):
                different_files.append(line)
            elif line.startswith("!"):
                errors.append(line)
            else:
                logger.warning(f"Unknown line format: {line}")

    print(f"Same files: {counter['=']}")
    print(f"Deleted files: {counter['-']}")
    print(f"Added files: {counter['+']}")

    if errors:
        print("Errors:")
        for error in errors:
            print(f"  {error}")

    if different_files:
        print("Different files:")
        for different_file in different_files:
            print(f"  {different_file}")

    if counter["-"] != counter["+"]:
        print(f"Number of deleted files ({counter['-']}) does not match number of added files ({counter['+']})")

    # find deletions vs adds by re-opening the file and comparing the the deleted and added files
    deleted_files = set()
    added_files = set()
    with args.sync_file.open() as f:
        for line in f:
            line = line.strip()
            filename = pathlib.Path(line[1:].strip()).name
            if line.startswith("-"):
                deleted_files.add(filename)
            elif line.startswith("+"):
                added_files.add(filename)

    deleted_not_added = deleted_files - added_files
    added_not_deleted = added_files - deleted_files

    if deleted_not_added:
        print("Deleted files not added:")
        for filename in sorted(deleted_not_added):
            print(f"  {filename}")

    if added_not_deleted:
        print("Added files not deleted:")
        for filename in sorted(added_not_deleted):
            print(f"  {filename}")



if __name__ == "__main__":
    main()

