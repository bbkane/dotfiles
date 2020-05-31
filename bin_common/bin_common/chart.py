#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import collections
import csv
import dataclasses
import datetime
import json
import pathlib
import sys
import tempfile
import typing as ty
import webbrowser

__author__ = "Benjamin Kane"
__version__ = "1.0.0"
__doc__ = """
Create interactive HTML charts with plotly and a Kusto-like command line interface!

No dependencies other than Python3 and a browser to open the generated HTML
Similar syntax to and uses help from
https://github.com/microsoft/Kusto-Query-Language/blob/master/doc/renderoperator.md
(Apache License)
Generate charts with https://plotly.com/javascript/
Only operate on table-like data piped in or from a file.

Examples:
    {prog}
    printf "1 2 3\\n3 4 5\\n" | {prog} -f ' ' timechart
    printf "time x y\\n1 2 3\\n3 4 5\\n" | {prog} -o DATEME -f ' ' --firstline timechart
    printf "2020-01-01 Ben 2\\n2020-02-01 Jenny 4\\n" | {prog} -o tmp.html -f ' ' --fieldnames date,author,lines timechart

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
    Plotly.plot(
        "myplot",
        JSON.parse('{plotly_json}'),
        JSON.parse('{plotly_layout}'),
        {{editable: false}}
    );
    </script>
  </body>
</html>
"""


# https://docs.python.org/3/library/dataclasses.html#module-dataclasses
# https://www.youtube.com/watch?v=T-TwcmT6Rcw
# https://stackoverflow.com/questions/49908399/replace-attributes-in-data-class-objects


@dataclasses.dataclass
class PlotlyAxis:
    title: ty.Optional[str] = None
    range: ty.Optional[ty.List[int]] = None


@dataclasses.dataclass
class PlotlyLayout:
    title: str
    xaxis: ty.Optional[PlotlyAxis] = None
    yaxis: ty.Optional[PlotlyAxis] = None


@dataclasses.dataclass
class PlotlyTrace:
    mode: str
    name: str
    type: str
    x: ty.Iterable[ty.Any]
    y: ty.Iterable[ty.Any]


def parse_args(*args, **kwargs):
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )

    # -- flags
    parser.add_argument(
        "--fieldsep",
        "-f",
        default="\t",
        help="Field separator for input table. SPACE by default",
    )

    fieldnames_group = parser.add_mutually_exclusive_group()
    fieldnames_group.add_argument("--fieldnames", help="column delimited fieldnames")
    fieldnames_group.add_argument(
        "--firstline", action="store_true", help="get fieldnames from first line of csv"
    )

    parser.add_argument(
        "--output",
        "-o",
        help="If not passed, chart will open in browswer. If passed with arg DATEME, chart.<timestamp>.html will be written. Otherwise, the arg will be written. Also used for chart title",
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


def csv_to_columns_with_fieldnames(
    inputfile: ty.TextIO, delimiter: str, fieldnames: ty.List[str]
):
    """Create columns when you already know the fieldnames"""
    csvreader = csv.reader(inputfile, delimiter=delimiter)
    first_line = next(csvreader)  # TODO: what if this is empty? Do I care?
    assert len(first_line) == len(fieldnames)
    return _csv_to_columns(inputfile, delimiter, fieldnames, first_line)


def csv_to_columns_gen_fieldnames(inputfile: ty.TextIO, delimiter: str):
    """Create columns and just auto-generate the fieldnames"""
    csvreader = csv.reader(inputfile, delimiter=delimiter)
    first_line = next(csvreader)  # TODO: what if this is empty? Do I care?
    fieldnames = [f"field_{i}" for i in range(len(first_line))]
    return _csv_to_columns(inputfile, delimiter, fieldnames, first_line)


def csv_to_columns_first_line_as_fieldnames(inputfile: ty.TextIO, delimiter: str):
    """Create columns and read fieldnames from first line"""
    csvreader = csv.reader(inputfile, delimiter=delimiter)
    fieldnames = next(csvreader)  # TODO: what if this is empty? Do I care?
    first_line = next(csvreader)
    return _csv_to_columns(inputfile, delimiter, fieldnames, first_line)


def _csv_to_columns(
    inputfile: ty.TextIO,
    delimiter: str,
    fieldnames: ty.List[str],
    first_line: ty.List[str],
):
    # add the first line
    # NOTE: we can rely on insertion order, so iterating over keys later will
    # work as expected
    ret = collections.defaultdict(list)
    for k, v in zip(fieldnames, first_line):
        ret[k].append(v)

    # add the rest of the lines
    dictreader = csv.DictReader(inputfile, fieldnames=fieldnames, delimiter=delimiter)
    for d_row in dictreader:
        for k, v in d_row.items():
            ret[k].append(v)

    return ret


def gen_timechart_json(columns: ty.Dict[str, ty.List]):
    # first column is datetime for xs (leave as string for now)
    # TODO: the second version is optionally a grouping string
    # rest of the columns should be numeric for ys

    traces = []
    column_names = tuple(columns.keys())
    xs = columns[column_names[0]]
    for name in column_names[1:]:
        trace = PlotlyTrace(
            # mode="lines+markers", name=name, type="scatter", x=xs, y=columns[name],
            mode="",
            name=name,
            type="bar",
            x=xs,
            y=columns[name],
        )
        traces.append(dataclasses.asdict(trace))

    return traces


def main():
    args = parse_args()

    # This breaks if it's in a function :(

    with args.input_table:
        if args.fieldnames:
            fieldnames = [f.strip() for f in args.fieldnames.split(",")]
            columns = csv_to_columns_with_fieldnames(
                args.input_table, args.fieldsep, fieldnames
            )
        elif args.firstline:
            columns = csv_to_columns_first_line_as_fieldnames(
                args.input_table, args.fieldsep
            )
        else:
            columns = csv_to_columns_gen_fieldnames(args.input_table, args.fieldsep)

    if args.subcommand_name == "timechart":
        # plotly_json = PlotlyTrace(mode="lines", type="scatter", x=[1, 2], y=[1, 2])
        # plotly_json = [dataclasses.asdict(plotly_json)]
        plotly_json = json.dumps(gen_timechart_json(columns))

        # TODO: why doesn't this work?
        # plotly_layout = json.dumps(
        #     dataclasses.asdict(
        #         PlotlyLayout(title=args.output, yaxis=PlotlyAxis(range=[-10, 10]))
        #     )
        # )

        # When this does work?
        # plotly_layout = json.dumps(
        #     {"title": "Lines changed", "yaxis": {"range": [-300, 300],},}
        # )

        plotly_layout = '{}'
        html_args = dict(
            output=args.output, plotly_json=plotly_json, plotly_layout=plotly_layout
        )

    if not args.output:
        with tempfile.NamedTemporaryFile(mode="w", delete=False, suffix=".html") as fp:
            print(html.format(**html_args), file=fp)
            url = pathlib.Path(fp.name).as_uri()
        webbrowser.open_new_tab(url)
    elif args.output == "DATEME":
        right_now = datetime.datetime.now().strftime("%Y-%m-%d.%H.%M.%S")
        default_name = ".".join(["chart", right_now, "html"])
        with open(default_name, "w") as fp:
            print(html.format(**html_args), file=fp)
    else:
        with open(args.output, "w") as fp:
            print(html.format(**html_args), file=fp)


if __name__ == "__main__":
    main()
