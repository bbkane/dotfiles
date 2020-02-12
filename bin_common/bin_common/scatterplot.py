#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import datetime
import sys

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = """
<description>
Examples:
    `{prog}`
Help:
Please see Benjamin Kane for help.
Code at <repo>
""".format(
    prog=sys.argv[0]
)


html = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>{output}</title>
    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
  </head>
  <body>
    <div id="myplot"></div>
    <script>
    Plotly.plot("myplot", [{{
        x: {x_values},
        y: {y_values},
        mode: "{mode}",
        type: "{type}"
    }}]);
    </script>
  </body>
</html>

"""


def parse_args(*args, **kwargs):
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "-m",
        "--mode",
        choices=["markers", "lines", "lines+markers"],
        default="lines+markers",
        help="defaults to markers",
    )
    parser.add_argument(
        "-t",
        "--type",
        choices=["scatter"],
        default="scatter",
        help="defaults to scatter",
    )
    right_now = datetime.datetime.now().strftime("%Y-%m-%d.%H.%M.%S")
    default_name = ".".join(["scatterplot", right_now, "html"])
    parser.add_argument(
        "-o",
        "--output",
        default=default_name,
        help="defaults to: " + repr(default_name),
    )
    subparsers = parser.add_subparsers(dest="subcommand", required=True)

    # points
    points_cmd = subparsers.add_parser(
        "points", help="Graph points via cmdline options"
    )
    points_cmd.add_argument(
        "-x", "--x_values", nargs="+", required=True, help="x values"
    )
    points_cmd.add_argument(
        "-y", "--y_values", nargs="+", required=True, help="y values"
    )

    # file
    file_cmd = subparsers.add_parser(
        "file",
        help='Use a file or stdin -needs to be a newline separated list of "x y"',
    )
    file_cmd.add_argument(
        "file",
        nargs="?",
        type=argparse.FileType("r"),
        default=sys.stdin,
        help='filepath or stdin: newline separated list of "x y"',
    )
    return parser.parse_args(*args, **kwargs)


def main():
    args = parse_args()
    if args.subcommand == "points":
        format_args = dict(
            mode=args.mode,
            type=args.type,
            x_values=args.x_values,
            y_values=args.y_values,
            output=args.output,
        )
    elif args.subcommand == "file":
        xs = []
        ys = []
        for line_num, line in enumerate(args.file):
            line = line.strip()
            if line:
                x, y = map(float, line.split())
                xs.append(x)
                ys.append(y)
            else:
                print("line {} is blank! Skipping...".format(line_num), file=sys.stderr)
        format_args = dict(
            mode=args.mode,
            type=args.type,
            x_values=xs,
            y_values=ys,
            output=args.output,
        )
    else:
        raise SystemExit("Unrecognized subcommand: ", repr(args.subcommand))

    if len(format_args["x_values"]) != len(format_args["y_values"]):
        raise SystemExit("Error: Each point must have an x and a y value!")

    with open(args.output, "w") as fp:
        print(html.format(**format_args), file=fp)


if __name__ == "__main__":
    main()
