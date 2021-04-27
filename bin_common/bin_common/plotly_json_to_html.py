#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import datetime
import json
import pathlib
import sys
import tempfile
import webbrowser

__author__ = "Benjamin Kane"
__version__ = "1.0.0"
__doc__ = """
Convert .plotly.json docs ( see https://plotly.com/javascript/reference/) to HTML files

Example:
    cat plot.plotly.json | {prog}

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
        JSON.parse('{plotly_data}'),
        JSON.parse('{plotly_layout}'),
        {{editable: false}}
    );
    </script>
  </body>
</html>
"""


def parse_args(*args, **kwargs):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)

    parser.add_argument(
        "--output",
        "-o",
        help="If not passed, chart will open in browswer. If passed with arg DATEME, chart.<timestamp>.html will be written. Otherwise, the arg will be written. Also used for chart title if --title not passed",
    )

    # -- args
    # Use a file or stdin for an argument
    # https://stackoverflow.com/a/11038508/2958070
    parser.add_argument(
        "input_json",
        nargs="?",
        type=argparse.FileType("r"),
        default=sys.stdin,
        help=".plotly.json data to use. Defaults to STDIN",
    )

    return parser.parse_args(*args, **kwargs)


def main():
    args = parse_args()

    with args.input_json:
        plotly_json = json.load(args.input_json)
    formatted_html = html.format(
        output=args.output,
        plotly_data=json.dumps(plotly_json["data"]),
        plotly_layout=json.dumps(plotly_json["layout"]),
    )

    if not args.output:
        with tempfile.NamedTemporaryFile(
            mode="w",
            delete=False,
            suffix=".html",
        ) as fp:
            print(formatted_html, file=fp)
            url = pathlib.Path(fp.name).as_uri()
        webbrowser.open_new_tab(url)
    elif args.output == "DATEME":
        right_now = datetime.datetime.now().strftime("%Y-%m-%d.%H.%M.%S")
        default_name = ".".join(["chart", right_now, "html"])
        with open(default_name, "w") as fp:
            print(formatted_html, file=fp)
    else:
        with open(args.output, "w") as fp:
            print(formatted_html, file=fp)


if __name__ == "__main__":
    main()
