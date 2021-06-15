#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import pathlib
import subprocess

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
Cache `az -h` commands
Examples:
    {sys.argv[0]}
Help:
Please see Benjamin Kane for help.
Code at <repo>
"""


def main():
    if "-h" not in sys.argv:
        subprocess.run(
            ["az", *sys.argv[1:]],
        )
        return

    cachedir = pathlib.Path("~/.fazt-cache").expanduser()
    cachedir.mkdir(exist_ok=True)

    key = " ".join(sys.argv[1:])
    helppath = pathlib.Path(cachedir, key)
    if helppath.exists():
        help = helppath.read_text()
    else:
        help_ret = subprocess.run(
            ["az", *sys.argv[1:]],
            capture_output=True,
            check=True,
            encoding="utf-8",
            text=True,
        )
        help = help_ret.stdout
        helppath.write_text(help)
    print(help)


if __name__ == "__main__":
    main()
