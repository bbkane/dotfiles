#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import shlex
import subprocess
import sys
from pathlib import Path

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
Diff a file in example-go-cli against the the same-named file in my other Go projects
Examples:
    {sys.argv[0]} --src <file> --group all|libs|clis
Help:
Please see Benjamin Kane for help.
Code at <repo>
"""

logger = logging.getLogger(__name__)


def run_cmd(*args: str):
    logger.info(f"Running command: {shlex.join(args)}")
    res = subprocess.run(
        args,
        encoding="utf-8",
        capture_output=True,
        text=True,
    )
    level = logging.DEBUG
    if res.returncode != 0:
        level = logging.ERROR
        logger.error(f"Command failed with return code: {res.returncode}")
    if res.stdout:
        logger.log(level, f"stdout:\n{res.stdout}")
    else:
        logger.log(level, "no stdout")

    if res.stderr:
        logger.log(level, f"stderr:\n{res.stderr}")
    else:
        logger.log(level, "no stderr")


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

    parser.add_argument(
        "--src",
        type=Path,
        required=True,
        help="source file to diff",
    )

    parser.add_argument(
        "--group",
        choices=["all", "libs", "clis"],
        default="all",
        help="group to diff against",
    )

    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).parent.parent,
        help="root directory of the Go projects",
    )

    return parser


def main():

    parser = build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        format="%(levelname)s %(filename)s:%(lineno)s: %(message)s",  # noqa: E501
        level=logging.getLevelNamesMapping()[args.log_level],
    )

    clis = sorted(("enventory", "fling", "grabbit", "toddlerevents"))
    libs = sorted(("gocolor", "logos", "warg"))
    all_ = sorted((*clis, *libs))

    group_apps = {
        "all": all_,
        "libs": libs,
        "clis": clis,
    }[args.group]

    for app in group_apps:
        src_file = args.src
        target_file = args.root / app / src_file.name

        if not target_file.exists():
            logger.error(f"Target file {target_file} does not exist.")
            continue

        src_str = src_file.read_text(encoding="utf-8")
        target_str = target_file.read_text(encoding="utf-8")
        if src_str == target_str:
            logger.info(f"No differences found in {app}.")
            continue

        # run_cmd("diff", "-u", str(src_file), str(target_file))
        run_cmd("delta", str(src_file), str(target_file))


if __name__ == "__main__":
    main()
