#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import subprocess
import sys

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
Reply to recruiters
Examples:
    {sys.argv[0]}
"""

REPLY = """
Hello {name},
I'm very happy here at LinkedIn, and I'm going to stay a while. {exciting} {sentence} I've saved your contact info if anything changes on my end. Also, feel free to send me a Linkedin connection request. Best of luck finding good people!
Thanks,
Ben
"""

EXCITING = "However, it sounds like you guys are doing exciting things."


def parse_args(*args, **kwargs):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument(
        "-n",
        "--name",
        default="",
    )
    parser.add_argument(
        "-s",
        "--sentence",
        default="",
    )

    parser.add_argument(
        "-b",
        "--boring",
        action="store_true",
    )

    parser.add_argument("--skip-copy", action="store_true")

    return parser.parse_args(*args, **kwargs)


def main():
    args = parse_args()

    if args.name == "":
        args.name = input("name: ")

    if not args.boring:
        exciting = EXCITING
    else:
        exciting = ""

    if args.sentence and not args.sentence.endswith(" "):
        args.sentence = args.sentence + " "

    message = REPLY.format(exciting=exciting, name=args.name, sentence=args.sentence)
    print(message)

    if not args.skip_copy:
        subprocess.run(args=["pbcopy"], input=message, encoding="utf-8", text=True)


if __name__ == "__main__":
    main()
