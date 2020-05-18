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
I'm very happy here at LinkedIn, and I'm going to stay a while. However, it sounds like you guys are doing exciting things. {sentence}I've saved your contact info if anything changes on my end. Best of luck finding good people!
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
