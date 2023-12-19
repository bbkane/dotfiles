#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import os
import shlex
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from string import capwords

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
<description>
Examples:
    {sys.argv[0]}
Help:
Create a blog post for www.bbkane.com
"""

logger = logging.getLogger(__name__)

INDEX = """+++
title = "{title}"
date = {date}
+++
"""


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
        "--log-format",
        default=r"%(levelname)s: %(message)s",
        help=r"log format",
    )

    parser.add_argument(
        "--root",
        "-r",
        default=Path("~/Git-GH/www.bbkane.com/content/blog"),
        help="blog post directory",
    )

    parser.add_argument(
        "--title",
        "-t",
        help="blog post title",
    )

    default_create_date = datetime.today().strftime("%Y-%m-%d")
    parser.add_argument(
        "--create-date",
        "-c",
        default=default_create_date,
        help=f"create date. defaults to {default_create_date!r}",
    )

    parser.add_argument(
        "--open",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Open blog post for editing after creation",
    )

    parser.add_argument(
        "--editor",
        "-e",
        default="open -a typora",
        help="Editor to open blog post in",
    )

    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        format=args.log_format,
        level=logging.getLevelName(args.log_level),
    )

    if not args.root.expanduser().exists():
        logger.error(f"--root doesn't exist: {args.root}")
        exit(1)

    if args.title is None:
        args.title = input("Enter Blog Title: ")

    blog_dir_name = capwords(args.title, sep=None).replace(" ", "-")
    blog_dir = Path(args.root.expanduser(), blog_dir_name)
    logger.info(f"creating: {repr(str(blog_dir))}")
    blog_dir.mkdir()

    post_path = Path(blog_dir, "index.md")
    post_path.write_text(
        INDEX.format(
            title=args.title,
            date=args.create_date,
        ),
        encoding="utf-8",
    )

    cmd = args.editor + " " + shlex.quote(str(post_path))
    logger.info(f"open cmd: {cmd}")
    if args.open:
        os.system(cmd)


if __name__ == "__main__":
    main()
