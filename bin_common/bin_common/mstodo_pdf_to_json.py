#!/usr/bin/env python3
"""Convert a Microsoft To Do "Print list" PDF into JSON.

Uses `pdftotext -bbox-layout` (poppler) for line coordinates:
- Tasks start at the leftmost content x position.
- Notes are indented slightly further right.
- Wrapped lines are tightly spaced and either fill the page width or are a
  bare URL tail (long URLs break early at "?" or "&").
- A left-outdented "Completed" line starts the completed section.

Usage: todo_pdf_to_json.py LIST.pdf [-o out.json]
"""

import argparse
import json
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

NS = "{http://www.w3.org/1999/xhtml}"
HEADER_Y = 35  # browser print header (date/time, page title)
TITLE_Y = 60  # list title + printed date row
FOOTER_MARGIN = 60  # "Printed with Microsoft To Do", URL, page number
LINE_GAP = 13  # yMin delta below this: same task/note block (wrap or newline)
FULL_WIDTH = 0.88  # line reaching this fraction of page width likely wrapped
INDENT_TOL = 1.0
SAME_ROW = 3  # vertical-center delta for fragments of one visual row
ROW_GAP = 20  # max horizontal gap to join fragments (keeps title and date apart)


def read_pages(pdf):
    out = subprocess.run(
        ["pdftotext", "-bbox-layout", pdf, "-"],
        check=True, capture_output=True, text=True,
    ).stdout
    root = ET.fromstring(re.sub(r"<!DOCTYPE[^>]*>", "", out))
    for page in root.iter(NS + "page"):
        lines = []
        for ln in page.iter(NS + "line"):
            words = [w.text or "" for w in ln.iter(NS + "word")]
            lines.append({
                "x": float(ln.get("xMin")),
                # Vertical center: emoji glyphs are taller, so yMin is unreliable.
                "y": (float(ln.get("yMin")) + float(ln.get("yMax"))) / 2,
                "x_end": float(ln.get("xMax")),
                "text": " ".join(words).strip(),
            })
        lines.sort(key=lambda l: (l["y"], l["x"]))
        yield float(page.get("width")), float(page.get("height")), merge_rows(lines)


def merge_rows(lines):
    """pdftotext can split one visual row (e.g. at an emoji) into separate lines."""
    groups = []
    for l in lines:
        if groups and abs(l["y"] - groups[-1][0]["y"]) < SAME_ROW:
            groups[-1].append(l)
        else:
            groups.append([l])
    rows = []
    for g in groups:
        g.sort(key=lambda l: l["x"])
        for l in g:
            r = rows[-1] if rows and rows[-1]["_g"] is g else None
            if r and l["x"] - r["x_end"] < ROW_GAP:
                r["text"] = f'{r["text"]} {l["text"]}'.strip()
                r["x_end"] = l["x_end"]
            else:
                rows.append({**l, "_g": g})
    for r in rows:
        del r["_g"]
    return rows


def join_wrapped(prev, cont):
    last = prev.split()[-1] if prev.split() else ""
    return prev + ("" if "://" in last else " ") + cont


def is_wrap(prev, cur, width):
    """Tight spacing alone is ambiguous: multi-line notes are spaced like wraps."""
    if cur["y"] - prev["y"] >= LINE_GAP:
        return False
    if prev["x_end"] >= width * FULL_WIDTH:
        return True
    # Long URLs break early at "?"/"&"; the tail is one token with no scheme.
    last = prev["text"].split()[-1]
    return "://" in last and " " not in cur["text"] and "://" not in cur["text"]


def parse(pdf):
    list_name = printed = None
    content = []
    for width, height, lines in read_pages(pdf):
        prev = None
        for l in lines:
            if l["y"] < HEADER_Y or l["y"] > height - FOOTER_MARGIN or not l["text"]:
                continue
            if l["y"] < TITLE_Y:
                if list_name is None and l["x"] < 300:
                    list_name = l["text"]
                elif printed is None and l["x"] >= 300:
                    printed = l["text"]
                continue
            l["wrap"] = prev is not None and is_wrap(prev, l, width)
            prev = l
            content.append(l)

    body_x = [l["x"] for l in content if l["text"] != "Completed"]
    task_x = min(body_x) if body_x else 0
    tasks, completed = [], False
    for l in content:
        if l["text"] == "Completed" and l["x"] < task_x - INDENT_TOL:
            completed = True
            continue
        if l["wrap"] and tasks:
            t = tasks[-1]
            if t["_notes"]:
                t["_notes"][-1] = join_wrapped(t["_notes"][-1], l["text"])
            else:
                t["title"] = join_wrapped(t["title"], l["text"])
        elif l["x"] <= task_x + INDENT_TOL or not tasks:
            tasks.append({"title": l["text"], "completed": completed, "_notes": []})
        else:
            tasks[-1]["_notes"].append(l["text"])

    for t in tasks:
        notes = t.pop("_notes")
        t["notes"] = "\n".join(notes)
    return {"list": list_name, "printed": printed, "tasks": tasks}


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("pdf")
    ap.add_argument("-o", "--output", help="write JSON here instead of stdout")
    args = ap.parse_args()
    data = json.dumps(parse(args.pdf), indent=2, ensure_ascii=False)
    if args.output:
        with open(args.output, "w") as f:
            f.write(data + "\n")
    else:
        print(data)


if __name__ == "__main__":
    sys.exit(main())
