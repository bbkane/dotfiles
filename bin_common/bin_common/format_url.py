#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import urllib.parse

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = """
Format URL from stdin with url-encoding

NOTE: this isnt working for now. I"ll try to come back to it :)

Examples:
    echo https://my-url | format_url.py
Help:
Please see Benjamin Kane for help.
Code at https://github.com/bbkane/dotfiles
"""



def main():
    if len(sys.argv) == 2 and sys.argv[1] in ("-h", "--help"):
        print(__doc__)
        exit(0)
    for line in sys.stdin:
        parsed = urllib.parse.urlparse(line)
        # This isn't working, so I'm giving up for now :D
        print(parsed.scheme + "://" + parsed.netloc + parsed.path + "?" + urllib.parse.quote(parsed.query))


if __name__ == "__main__":
    main()
