#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import sys
import urllib.parse

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = """
Format python dict from stdin.

USE ONLY WITH TRUSTED DATA! Uses `eval` to parse the dict.

Examples:
    echo '{"hi": "there"}' | format_dict.py
Help:
Please see Benjamin Kane for help.
Code at https://github.com/bbkane/dotfiles
"""

def main():
    if len(sys.argv) == 2 and sys.argv[1] in ("-h", "--help"):
        print(__doc__)
        exit(0)
    for line in sys.stdin:
        parsed = eval(line)
        print(json.dumps(parsed, indent=4, sort_keys=True))


if __name__ == "__main__":
    main()
