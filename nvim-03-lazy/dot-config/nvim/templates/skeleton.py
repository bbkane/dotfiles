#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import sys

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
<description>
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
        "infile",
        nargs="?",
        type=argparse.FileType("r"),
        default=sys.stdin,
        help="Use a file or stdin",
    )

    return parser


def main():

    parser = build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        format="# %(asctime)s %(levelname)s %(name)s %(filename)s:%(lineno)s\n%(message)s\n",
        level=logging.getLevelNamesMapping()[args.log_level],
    )

    logger.debug("debug")
    logger.info("info")
    logger.warning("warning")

    with args.infile:
        pass


if __name__ == "__main__":
    main()
