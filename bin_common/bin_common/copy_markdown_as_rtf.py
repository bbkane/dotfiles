#!/usr/bin/env python3

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = """
Convert Markdown-formatted plain text on the macOS clipboard to rich text and
copy it back for pasting into apps such as Slack.

The clipboard receives HTML, RTF, and plain-text flavors so the destination app
can choose the richest format it supports.

Requires pandoc, pbpaste, and osascript.
"""

JXA_SET_CLIPBOARD = r"""
ObjC.import("AppKit");
ObjC.import("Foundation");

function run(argv) {
    const html = $.NSString.stringWithContentsOfFileEncodingError(
        $(argv[0]), $.NSUTF8StringEncoding, null
    );
    const text = $.NSString.stringWithContentsOfFileEncodingError(
        $(argv[1]), $.NSUTF8StringEncoding, null
    );
    const rtf = $.NSData.dataWithContentsOfFile($(argv[2]));
    const pasteboard = $.NSPasteboard.generalPasteboard;

    pasteboard.clearContents;
    pasteboard.setStringForType(html, $("public.html"));
    pasteboard.setStringForType(text, $("public.utf8-plain-text"));
    pasteboard.setDataForType(rtf, $("public.rtf"));
}
"""


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    return parser.parse_args()


def require_command(command: str) -> None:
    if shutil.which(command) is None:
        raise RuntimeError(f"Required command not found: {command}")


def run_pandoc(markdown: bytes, output_format: str, *, standalone: bool = False) -> bytes:
    command = ["pandoc", "--from=gfm", f"--to={output_format}"]
    if standalone:
        command.append("--standalone")

    result = subprocess.run(
        command,
        check=True,
        capture_output=True,
        input=markdown,
    )
    return result.stdout


def markdown_to_rtf(markdown: bytes) -> bytes:
    result = run_pandoc(markdown, "rtf", standalone=True)
    if not result.lstrip().startswith(b"{\\rtf"):
        raise RuntimeError("pandoc did not produce a complete RTF document")
    return result


def set_clipboard(markdown: bytes, html: bytes, rtf: bytes) -> None:
    with tempfile.TemporaryDirectory() as directory:
        paths = {
            "html": Path(directory, "content.html"),
            "text": Path(directory, "content.txt"),
            "rtf": Path(directory, "content.rtf"),
        }
        paths["html"].write_bytes(html)
        paths["text"].write_bytes(markdown)
        paths["rtf"].write_bytes(rtf)

        subprocess.run(
            [
                "osascript",
                "-l",
                "JavaScript",
                "-e",
                JXA_SET_CLIPBOARD,
                str(paths["html"]),
                str(paths["text"]),
                str(paths["rtf"]),
            ],
            check=True,
            capture_output=True,
        )


def main() -> int:
    parse_args()

    try:
        for command in ("pbpaste", "pandoc", "osascript"):
            require_command(command)

        markdown = subprocess.run(
            ["pbpaste", "-Prefer", "txt"],
            check=True,
            capture_output=True,
        ).stdout
        if not markdown.strip():
            raise RuntimeError("Clipboard does not contain any text")

        html = run_pandoc(markdown, "html")
        rtf = markdown_to_rtf(markdown)
        set_clipboard(markdown, html, rtf)
    except (RuntimeError, subprocess.CalledProcessError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    print("Markdown copied to the clipboard as rich text.", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
