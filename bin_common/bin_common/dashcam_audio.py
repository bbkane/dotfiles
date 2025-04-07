#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import os
import sys
from pathlib import Path
import shlex
from subprocess import run

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

    parser.add_argument(
        "--root",
        type=Path,
        default=Path("/Volumes/Untitled/CARDV/Movie_F"),
        help="root directory to search for files",
    )

    parser.add_argument(
        "--first",
        help="first file to process. Will prompt for a name if not provided",
    )
    parser.add_argument(
        "--last",
        help="last file to process. Will prompt for a name if not provided",
    )

    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("~/OneDrive/Videos").expanduser(),
        help="output directory",
    )

    parser.add_argument(
        "--output-name",
        help="output name. Will prompt for a name if not provided",
    )

    parser.add_argument(
        "--work-dir",
        type=Path,
        default="/tmp",
        help="work directory for temporary files",
    )
    return parser


def main():

    parser = build_parser()
    args = parser.parse_args()

    logging.basicConfig(
        format="# %(asctime)s %(levelname)s %(name)s %(filename)s:%(lineno)s\n%(message)s\n",
        level=logging.getLevelName(args.log_level),
    )

    if not args.output_dir.exists():
        raise ValueError(f"Output directory {args.output_dir} does not exist")
    if not args.root.exists():
        raise ValueError(f"Root directory {args.root} does not exist")

    if not args.first:
        args.first = input("First file to process: ")
    if not args.last:
        args.last = input("Last file to process: ")
    if not args.output_name:
        args.output_name = input("Output name: ")

    args.first = args.root / args.first
    args.last = args.root / args.last

    # list the files
    files = list(args.root.glob("*.MP4"))
    files.sort()

    # remove all files before the first file
    first_index = files.index(Path(args.first))
    files = files[first_index:]
    # remove all files after the last file
    last_index = files.index(Path(args.last))
    files = files[:last_index + 1]

    file_list = Path(args.work_dir, args.output_name).with_suffix(".txt")
    with file_list.open("w") as f:
        for file in files:
            f.write(f"file {shlex.quote(str(file))}\n")
    logger.info(f"File list written to {file_list}")

    # run ffmpeg to concatenate the files
    aac_file = Path(args.work_dir, args.output_name).with_suffix(".aac")
    concat_cmd =  ["ffmpeg", "-f", "concat", "-safe", "0", "-i", str(file_list), "-c:a", "copy", str(aac_file)]
    logger.info(f"Running command: {shlex.join(concat_cmd)}")
    run(concat_cmd, check=True)
    logger.info(f"AAC file written to: {aac_file}")

    # convert the output file to m4a
    m4a_file = Path(args.output_dir, args.output_name).with_suffix(".m4a")
    output_cmd =  ["ffmpeg", "-i", str(aac_file), "-c:a", "copy", "-movflags", "+faststart", str(m4a_file)]
    logger.info(f"Running command: {shlex.join(output_cmd)}")
    run(output_cmd, check=True)
    logger.info(f"M4A file written to: {m4a_file}")

if __name__ == "__main__":
    main()

