#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import html
import re
import subprocess
import sys
import tempfile
import os
from html.parser import HTMLParser

__author__ = "Benjamin Kane"
__version__ = "0.1.0"
__doc__ = f"""
**MacOS Specific**

Restyle the clipboard so pasting into Google Docs keeps *structure* (lists,
links, bold/italic, headings, tables) but drops *cosmetic* styling (font
family, font size, color, line-height). With the cosmetic styling gone, Google
Docs falls back to the destination document's own style for anything we leave
unspecified -- so your pasted content matches the GDoc instead of your Notes app.

Reads the clipboard's rich flavor (RTF, else HTML) itself, strips the styling,
and writes clean HTML *back to the clipboard*.

Why it sets the clipboard itself instead of printing for `| pbcopy`: GDocs only
honors the clipboard's HTML flavor here, and pbcopy can only set plain-text or
RTF -- RTF would reintroduce the very font you're trying to drop. So just run:

    {os.path.basename(sys.argv[0])}

    # ...then Cmd-V into Google Docs.

Inspired by copy_as_rtf.py. Pass a file path to restyle that instead of the
clipboard (handy for testing). Plain-text clipboards are left untouched.
"""


# Structural tags worth keeping. Everything else (span, font, div, ...) is
# unwrapped so its children survive but its styling does not.
KEEP = {
    "a", "p", "br",
    "ul", "ol", "li",
    "blockquote", "pre", "code",
    "b", "strong", "i", "em", "u", "s", "strike", "del", "sub", "sup",
    "h1", "h2", "h3", "h4", "h5", "h6", "hr",
    "table", "thead", "tbody", "tr", "td", "th", "caption",
}
VOID = {"br", "hr"}
# Headings get one explicit style: font-weight:normal. Google Docs sizes a
# pasted <hN> like its named Heading style but, because HTML headings are
# semantically bold, leaves them bold -- unlike a heading you type in the doc.
# Forcing normal weight makes pasted headings match native ones while staying
# real headings (still in the outline).
HEADINGS = {"h1", "h2", "h3", "h4", "h5", "h6"}
# Container tags whose entire subtree we discard (the <style> block is where
# textutil hides its class-based font definitions).
DROP_TREE = {"script", "style", "head", "title"}
# Void drop-tags: no closing tag, so just ignore them (never adjust depth).
DROP_VOID = {"meta", "link", "base"}


class StyleStripper(HTMLParser):
    """Rebuild HTML keeping only structural tags, dropping all attributes
    except href on links."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.out = []
        self._drop_depth = 0

    def handle_starttag(self, tag, attrs):
        if tag in DROP_VOID:
            return
        if tag in DROP_TREE:
            self._drop_depth += 1
            return
        if self._drop_depth:
            return
        if tag in VOID:
            self.out.append(f"<{tag}>")
            return
        if tag in KEEP:
            if tag == "a":
                href = dict(attrs).get("href")
                if href:
                    self.out.append(f'<a href="{html.escape(href, quote=True)}">')
                else:
                    self.out.append("<a>")
            elif tag in HEADINGS:
                self.out.append(f'<{tag} style="font-weight: normal;">')
            else:
                self.out.append(f"<{tag}>")
        # otherwise: unwrap -- emit nothing, children still flow through

    def handle_startendtag(self, tag, attrs):
        if tag in DROP_VOID or self._drop_depth:
            return
        if tag in VOID:
            self.out.append(f"<{tag}>")

    def handle_endtag(self, tag):
        if tag in DROP_TREE:
            if self._drop_depth:
                self._drop_depth -= 1
            return
        if self._drop_depth:
            return
        if tag in KEEP and tag not in VOID:
            self.out.append(f"</{tag}>")

    def handle_data(self, data):
        if self._drop_depth:
            return
        self.out.append(html.escape(data, quote=False))

    def result(self):
        return "".join(self.out)


def rtf_to_html(data: bytes) -> str:
    proc = subprocess.run(
        ["textutil", "-stdin", "-format", "rtf", "-convert", "html",
         "-encoding", "UTF-8", "-stdout"],
        check=True,
        capture_output=True,
        input=data,
    )
    return proc.stdout.decode("utf-8", errors="replace")


def clean_html(raw_html: str) -> str:
    parser = StyleStripper()
    parser.feed(raw_html)
    parser.close()
    body = parser.result()
    return (
        '<!DOCTYPE html><html><head><meta charset="utf-8"></head>'
        f"<body>{body}</body></html>"
    )


def set_clipboard_html(clean: str) -> None:
    """Put HTML on the clipboard's public.html flavor via AppleScript.

    We write to a temp file and have osascript read it (rather than passing the
    HTML inline) to dodge argument-length limits on large notes.
    """
    fd, path = tempfile.mkstemp(suffix=".html")
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write(clean)
        subprocess.run(
            [
                "osascript",
                "-e", "on run argv",
                "-e", "set the clipboard to (read (POSIX file (item 1 of argv)) as «class HTML»)",
                "-e", "end run",
                path,
            ],
            check=True,
        )
    finally:
        os.unlink(path)


def read_clipboard_rtf() -> bytes:
    """RTF bytes if the clipboard has an RTF flavor, else its plain-text fallback."""
    return subprocess.run(
        ["pbpaste", "-Prefer", "rtf"], check=True, capture_output=True
    ).stdout


def read_clipboard_html_flavor():
    """The clipboard's public.html flavor as a string, or None if absent."""
    try:
        raw = subprocess.run(
            ["osascript", "-e", "the clipboard as «class HTML»"],
            check=True,
            capture_output=True,
            text=True,
        ).stdout
    except subprocess.CalledProcessError:
        return None
    m = re.search(r"«data HTML([0-9A-Fa-f]+)»", raw)
    if not m:
        return None
    try:
        return bytes.fromhex(m.group(1)).decode("utf-8", errors="replace")
    except ValueError:
        return None


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "infile",
        nargs="?",
        help="Restyle this file instead of the clipboard (handy for testing)",
    )
    args = parser.parse_args()

    if args.infile:
        with open(args.infile, "rb") as f:
            data = f.read()
        stripped = data.lstrip()
        if stripped.startswith(b"{\\rtf"):
            raw_html = rtf_to_html(data)
        elif b"<" in stripped:
            raw_html = data.decode("utf-8", errors="replace")
        else:
            print("Plain text -- nothing to restyle.", file=sys.stderr)
            return
        set_clipboard_html(clean_html(raw_html))
        print("Clean HTML on the clipboard. Cmd-V into Google Docs.", file=sys.stderr)
        return

    # Read the clipboard's richest flavor: prefer RTF (what Notes provides and
    # what textutil converts cleanly), fall back to an HTML flavor, then plain.
    rtf = read_clipboard_rtf()
    if rtf.lstrip().startswith(b"{\\rtf"):
        raw_html = rtf_to_html(rtf)
    else:
        raw_html = read_clipboard_html_flavor()
        if raw_html is None:
            print("Clipboard is plain text -- nothing to restyle.", file=sys.stderr)
            return

    set_clipboard_html(clean_html(raw_html))
    print("Clean HTML on the clipboard. Cmd-V into Google Docs.", file=sys.stderr)


if __name__ == "__main__":
    main()
