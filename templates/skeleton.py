#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = "Benjamin Kane"
__version__ = "0.1.0"

import argparse
import sys

__doc__ = """
<description>

Examples:

    `{prog}`

Help:

Please see Benjamin Kane for help.
Code at <repo>
""".format(prog=sys.argv[0])


def parse_args(*args, **kwargs):
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    # TODO: add some args
    return parser.parse_args(*args, **kwargs)


def main():
    pass


if __name__ == "__main__":
    main()
