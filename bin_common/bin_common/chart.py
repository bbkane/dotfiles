#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from textwrap import dedent
import argparse
import collections
import csv
import dataclasses
import datetime
import json
import pathlib
import sys
import typing as t

__author__ = "Benjamin Kane"
__version__ = "1.0.0"
__doc__ = """
Create interactive HTML charts with plotly and a Kusto-like command line interface!

No dependencies other than Python3 and a browser to open the generated HTML
Similar syntax to and uses help from https://github.com/microsoft/Kusto-Query-Language/blob/master/doc/renderoperator.md (Apache License)
Generate charts with https://plotly.com/javascript/
Only operate on table-like data piped in or from a file.

Examples:
    {prog}
    printf "1 2\\n3 4\\n" | {prog} -o graph.html -f ' ' --columns x,y linechart
    printf "x y\\n1 2\\n3 4\\n" | {prog} -o graph.html -f ' ' --headers linechart
    printf "2020-01-01 Ben 2\\n2020-02-01 Jenny 4\\n" | {prog} -f ' ' --columns date,author,lines timechart

Please see Benjamin Kane for help.
Repo: https://github.com/bbkane/dotfiles
""".format(
    prog=pathlib.Path(sys.argv[0]).name
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
    Plotly.plot("myplot", JSON.parse('{plotly_json}'));
    </script>
  </body>
</html>
"""


# https://docs.python.org/3/library/dataclasses.html#module-dataclasses
# https://www.youtube.com/watch?v=T-TwcmT6Rcw
# https://stackoverflow.com/questions/49908399/replace-attributes-in-data-class-objects


@dataclasses.dataclass
class PlotlyTrace:
    mode: str
    name: str
    type: str
    x: t.Iterable[t.Any]
    y: t.Iterable[t.Any]


def parse_args(*args, **kwargs):
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )

    # -- flags
    parser.add_argument(
        "--field_sep",
        "-f",
        default="\t",
        help="Field separator for input table. SPACE by default",
    )
    parser.add_argument(
        "--columns",
        "-c",
        help="Column names separated by commas. Will be generated if not passed",
    )
    # TODO: add --header  thad reads first line as mutually exclusive option

    right_now = datetime.datetime.now().strftime("%Y-%m-%d.%H.%M.%S")
    default_name = ".".join(["chart", right_now, "html"])
    parser.add_argument(
        "--output",
        "-o",
        default=default_name,
        help="defaults to: " + repr(default_name),
    )

    # -- args
    # Use a file or stdin for an argument
    # https://stackoverflow.com/a/11038508/2958070
    parser.add_argument(
        "input_table",
        nargs="?",
        type=argparse.FileType("r"),
        default=sys.stdin,
        help="table data to use. Defaults to STDIN",
    )

    # -- subcommands - the actual chart types and any special args
    subcommands = parser.add_subparsers(dest="subcommand_name", required=True)
    subcommands.add_parser(
        "timechart",
        help='Line graph. First column is x-axis, and should be datetime. Second column can optionally be a string whose values are used to "group" the numeric columns and create different lines in the chart. Other (numeric) columns are y-axes.',
    )

    return parser.parse_args(*args, **kwargs)


def csv_to_columns(inputfile, delimiter):
    # TODO: there are 3 ways to get field names - generated (here), args.columns, reading the first line and interpreting them as field names (I think DictReader can do this automatically)

    # read first line to get num fields
    csvreader = csv.reader(inputfile, delimiter=delimiter)
    first_line = next(csvreader)  # TODO: what if this is empty? Do I care?
    fields = [f"field_{i}" for i in range(len(first_line))]

    # add the first line
    # NOTE: we can rely on insertion order, so iterating over keys later will
    # work as expected
    ret = collections.defaultdict(list)
    for k, v in zip(fields, first_line):
        ret[k].append(v)

    # add the rest of the lines
    dictreader = csv.DictReader(inputfile, fieldnames=fields, delimiter=delimiter)
    for d_row in dictreader:
        for k, v in d_row.items():
            ret[k].append(v)

    return ret


def gen_timechart_json(columns):
    # first column is datetime for xs (leave as string for now)
    # TODO: the second version is optionally a grouping string
    # rest of the columns should be numeric for ys

    traces = []
    column_names = tuple(columns.keys())
    xs = columns[column_names[0]]
    for name in column_names[1:]:
        trace = PlotlyTrace(
            mode="lines+markers", name=name, type="scatter", x=xs, y=columns[name],
        )
        traces.append(dataclasses.asdict(trace))

    return traces


def main():
    args = parse_args()

    # This breaks if it's in a function :(

    with args.input_table:
        columns = csv_to_columns(args.input_table, args.field_sep)

    if args.subcommand_name == "timechart":
        # plotly_json = PlotlyTrace(mode="lines", type="scatter", x=[1, 2], y=[1, 2])
        # plotly_json = [dataclasses.asdict(plotly_json)]
        plotly_json = json.dumps(gen_timechart_json(columns))
        html_args = dict(output=args.output, plotly_json=plotly_json)
    with open(args.output, "w") as fp:
        print(html.format(**html_args), file=fp)


if __name__ == "__main__":
    main()
