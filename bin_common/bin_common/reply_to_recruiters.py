#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
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
I just recently started my current job at LinkedIn. I'm very happy here, and I'm going to stay a while. However, it sounds like you guys are doing exciting things. {sentence}I wish you the best of luck!
Thanks,
Ben
"""

def parse_args(*args, **kwargs):
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument(
        'name'
    )
    parser.add_argument(
        '-s',
        '--sentence',
        default='',
    )

    return parser.parse_args(*args, **kwargs)


def main():
    args = parse_args()
    if args.sentence and not args.sentence.endswith(' '):
        args.sentence = args.sentence + ' '
    print(REPLY.format(name=args.name, sentence=args.sentence))
    # do real work

if __name__ == "__main__":
    main()
