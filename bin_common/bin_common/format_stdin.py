#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = """
Format stdin with f-string rules
Examples:
    echo 'hi {name}' | format_stdin.py name Ben
Help:
Please see Benjamin Kane for help.
Code at <repo>
"""

# Test as_pairs with:
# python3 -m doctest format_stdin.py


def as_pairs(lst):
    """Yield pairs from a list.

    Raises ValueError for lists with an odd number of items

    >>> list(as_pairs([1, 2, 3, 4]))
    [(1, 2), (3, 4)]

    >>> list(as_pairs([]))
    []

    >>> list(as_pairs([1, 2, 3]))
    Traceback (most recent call last):
        ...
    ValueError: lst must contain an even number of items
    """

    if len(lst) % 2 != 0:
        raise ValueError("lst must contain an even number of items")

    it = iter(lst)
    while True:
        try:
            first = next(it)
            second = next(it)
            yield (first, second)
        except StopIteration:
            return


def main():
    infile = sys.stdin.read()
    args = sys.argv[1:]
    if len(args) == 0 or len(args) % 2 != 0:
        raise SystemExit(
            "Need some keys and values! Ex: cat file.txt | format_stdin.py key value key2 value2"
        )
    print(infile.format(**dict(as_pairs(args))))


if __name__ == "__main__":
    main()
