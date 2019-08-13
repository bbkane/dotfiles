#!/usr/bin/env python
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
""".format(prog=sys.argv[0])


html="""
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>{name}</title>
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
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        '-m',
        '--mode',
        choices=[
            'markers',
            'lines',
            'lines+markers'
        ],
        default='lines+markers',
        help='defaults to markers'
    )
    parser.add_argument(
        '-t',
        '--type',
        choices=[
            'scatter'
        ],
        default='scatter',
        help='defaults to scatter'
    )
    parser.add_argument(
        '-x',
        '--x_values',
        nargs='+',
        required=True,
        help='x values'
    )
    parser.add_argument(
        '-y',
        '--y_values',
        nargs='+',
        required=True,
        help='y values'
    )
    right_now = datetime.datetime.now().strftime('%Y-%m-%d.%H.%M.%S')
    default_name = '.'.join(['scatterplot', right_now, 'html'])
    parser.add_argument(
        '-n',
        '--name',
        default=default_name,
        help='Name defaults to ' + default_name
    )
    return parser.parse_args(*args, **kwargs)


def main():
    args = parse_args()
    format_args = dict(
        mode=args.mode,
        type=args.type,
        x_values=args.x_values,
        y_values=args.y_values,
        name=args.name
    )

    if len(args.x_values) != len(args.y_values):
        print('Error: Each point must have an x and a y value!', file=sys.stderr)
        sys.exit(1)

    with open(args.name, 'w') as fp:
        print(html.format(**format_args), file=fp)


if __name__ == "__main__":
    main()
