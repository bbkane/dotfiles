#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# the goal of this is to highlight exceptions in log files
# Example: ./hello_exceptions.py 2>&1 | ./color_exceptions.py
# TODO: use argparse to add --help and such

__author__ = "Benjamin Kane"
__version__ = "0.1.0"

import sys

class State:
    NORMAL = 'NORMAL'
    FIRST_LINE = 'FIRST_LINE'
    NESTED = 'NESTED'
    LAST_LINE = 'LAST_LINE'

class Colors:
    # https://stackoverflow.com/a/56944256/2958070
    grey = "\x1b[38;21m"
    yellow = "\x1b[33;21m"
    red = "\x1b[31;21m"
    bold_red = "\x1b[31;1m"
    reset = "\x1b[0m"

def main():
    state = State.NORMAL
    colors = {
        State.NORMAL: Colors.reset,
        State.FIRST_LINE: Colors.bold_red,
        State.NESTED: Colors.red,
        State.LAST_LINE: Colors.bold_red,
    }

    for line in sys.stdin:
        if state == State.NORMAL:
            if line == 'Traceback (most recent call last):\n':
                state = State.FIRST_LINE
        elif state == State.FIRST_LINE:
            state = State.NESTED
        elif state == State.NESTED:
            if not line.startswith('  '):
                state = State.LAST_LINE
        elif state == State.LAST_LINE:
            state = State.NORMAL
        else:
            raise ValueError(f"Unrecognized state: {state}")

        print(f'{colors[state]}{line}{Colors.reset}', end='')


if __name__ == "__main__":
    main()

