"""Dependency-free Markdown -> HTML renderer.

Supports the subset of Markdown that Copilot CLI transcripts actually use:
headings, fenced/indented code, inline code, bold/italic/strikethrough, links,
autolinks, bullet + ordered lists (nested), tables, blockquotes and rules.

Everything is HTML-escaped before any markup is generated, so rendered output is
safe to inline into a document without a sanitizer.
"""

from __future__ import annotations

import html
import re

__all__ = ["render_markdown", "escape"]

PLACEHOLDER = "\x00%d\x00"
_PLACEHOLDER_RE = re.compile(r"\x00(\d+)\x00")

_FENCE_RE = re.compile(r"^(\s*)(`{3,}|~{3,})[ \t]*([\w+#.\-]*)[ \t]*$")
_HEADING_RE = re.compile(r"^ {0,3}(#{1,6})\s+(.*?)\s*#*\s*$")
_HR_RE = re.compile(r"^ {0,3}([-*_])[ \t]*(?:\1[ \t]*){2,}$")
_QUOTE_RE = re.compile(r"^ {0,3}>\s?(.*)$")
_ULI_RE = re.compile(r"^(\s*)([-*+])[ \t]+(.*)$")
_OLI_RE = re.compile(r"^(\s*)(\d{1,9})[.)][ \t]+(.*)$")
_TABLE_SEP_RE = re.compile(r"^\s*\|?\s*:?-{1,}:?\s*(\|\s*:?-{1,}:?\s*)+\|?\s*$")
_TASK_RE = re.compile(r"^\[([ xX])\]\s+(.*)$")

_CODESPAN_RE = re.compile(r"(?<!\\)(`+)(.+?)(?<!`)\1(?!`)", re.S)
_LINK_RE = re.compile(r"(?<!\\)\[([^\]]*)\]\(\s*<?([^\s<>)]+)>?(?:\s+&quot;[^\)]*&quot;)?\s*\)")
_AUTOLINK_RE = re.compile(r"(?<![\w@/])((?:https?://|www\.)[^\s<>\[\]{}\"'`]+[^\s<>\[\]{}\"'`.,;:!?)])")
_BOLD_ITALIC_RE = re.compile(r"(?<!\w)\*\*\*(?=\S)(.+?)(?<=\S)\*\*\*", re.S)
_BOLD_RE = re.compile(r"(?<!\w)(\*\*|__)(?=\S)(.+?)(?<=\S)\1(?!\w)", re.S)
_ITALIC_STAR_RE = re.compile(r"(?<![\w*])\*(?=[^\s*])(.+?)(?<=[^\s*])\*(?![\w*])", re.S)
_ITALIC_UND_RE = re.compile(r"(?<![\w_])_(?=[^\s_])(.+?)(?<=[^\s_])_(?![\w_])", re.S)
_STRIKE_RE = re.compile(r"~~(?=\S)(.+?)(?<=\S)~~", re.S)


def escape(text, quote=True):
    return html.escape("" if text is None else str(text), quote=quote)


class _Inline:
    """Inline renderer that parks generated HTML in placeholders.

    Parking protects already-generated markup (code spans, links) from later
    passes, which is what keeps autolinking from corrupting link hrefs.
    """

    def __init__(self):
        self.parked = []

    def park(self, html_fragment):
        self.parked.append(html_fragment)
        return PLACEHOLDER % (len(self.parked) - 1)

    def unpark(self, text):
        # Placeholders can nest (a link label may hold a code span), so repeat
        # until the text stops changing.
        for _ in range(6):
            new = _PLACEHOLDER_RE.sub(lambda m: self.parked[int(m.group(1))], text)
            if new == text:
                break
            text = new
        return text

    def run(self, text):
        text = escape(text.replace("\x00", ""), quote=False)
        text = _CODESPAN_RE.sub(
            lambda m: self.park("<code>%s</code>" % m.group(2).strip()), text
        )
        text = _LINK_RE.sub(self._link, text)
        text = _AUTOLINK_RE.sub(self._autolink, text)
        text = self._emphasis(text)
        text = text.replace("\\*", "*").replace("\\_", "_").replace("\\`", "`")
        text = re.sub(r"[ \t]{2,}\n", "<br>\n", text)
        return self.unpark(text)

    def _emphasis(self, text, depth=0):
        """Apply emphasis rules, parking each result so later passes cannot
        match across an already-emitted tag pair (which would cross tags)."""
        if depth > 6 or not text:
            return text
        rules = (
            (_BOLD_ITALIC_RE, 1, "<strong><em>%s</em></strong>"),
            (_BOLD_RE, 2, "<strong>%s</strong>"),
            (_ITALIC_STAR_RE, 1, "<em>%s</em>"),
            (_ITALIC_UND_RE, 1, "<em>%s</em>"),
            (_STRIKE_RE, 1, "<del>%s</del>"),
        )
        for regex, group, wrapper in rules:
            def repl(match, _g=group, _w=wrapper):
                inner = self._emphasis(match.group(_g), depth + 1)
                return self.park(_w % inner)

            text = regex.sub(repl, text)
        return text

    def _safe_url(self, raw):
        url = html.unescape(raw).strip()
        scheme = url.split(":", 1)[0].lower() if ":" in url.split("/", 1)[0] else ""
        if scheme and scheme not in ("http", "https", "mailto", "file", "ftp"):
            return None
        return escape(url)

    def _link(self, match):
        label, raw = match.group(1), match.group(2)
        url = self._safe_url(raw)
        if url is None:
            return escape(match.group(0), quote=False)
        return self.park(
            '<a href="%s" target="_blank" rel="noopener noreferrer">%s</a>'
            % (url, label or url)
        )

    def _autolink(self, match):
        raw = match.group(1)
        url = raw if "://" in raw else "https://" + raw
        return self.park(
            '<a href="%s" target="_blank" rel="noopener noreferrer">%s</a>'
            % (escape(url), escape(raw))
        )


def _inline(text):
    return _Inline().run(text)


def _code_block(code, lang=""):
    cls = ' class="lang-%s"' % escape(lang) if lang else ""
    label = '<span class="code-lang">%s</span>' % escape(lang) if lang else ""
    return '<div class="codewrap">%s<pre><code%s>%s</code></pre></div>' % (
        label,
        cls,
        escape(code, quote=False),
    )


def _split_row(line):
    line = line.strip()
    if line.startswith("|"):
        line = line[1:]
    if line.endswith("|") and not line.endswith("\\|"):
        line = line[:-1]
    cells, buf, i = [], "", 0
    while i < len(line):
        ch = line[i]
        if ch == "\\" and i + 1 < len(line) and line[i + 1] == "|":
            buf += "|"
            i += 2
            continue
        if ch == "|":
            cells.append(buf.strip())
            buf = ""
        else:
            buf += ch
        i += 1
    cells.append(buf.strip())
    return cells


def _alignments(sep_line):
    out = []
    for cell in _split_row(sep_line):
        left, right = cell.startswith(":"), cell.endswith(":")
        out.append("center" if left and right else "right" if right else "left" if left else "")
    return out


def _table(lines, start):
    header = _split_row(lines[start])
    aligns = _alignments(lines[start + 1])
    i = start + 2
    rows = []
    while i < len(lines) and lines[i].strip() and "|" in lines[i]:
        rows.append(_split_row(lines[i]))
        i += 1

    def cell(tag, value, idx):
        style = ' style="text-align:%s"' % aligns[idx] if idx < len(aligns) and aligns[idx] else ""
        return "<%s%s>%s</%s>" % (tag, style, _inline(value), tag)

    out = ['<div class="tablewrap"><table><thead><tr>']
    out += [cell("th", h, n) for n, h in enumerate(header)]
    out.append("</tr></thead><tbody>")
    for row in rows:
        row = (row + [""] * len(header))[: max(len(header), len(row))]
        out.append("<tr>" + "".join(cell("td", c, n) for n, c in enumerate(row)) + "</tr>")
    out.append("</tbody></table></div>")
    return "".join(out), i


def _list_item_match(line):
    m = _ULI_RE.match(line)
    if m:
        return len(m.group(1).expandtabs(4)), "ul", m.group(3), m.group(2)
    m = _OLI_RE.match(line)
    if m:
        return len(m.group(1).expandtabs(4)), "ol", m.group(3), m.group(2)
    return None


def _collect_list(lines, start):
    """Collect a run of list items into (indent, kind, [content lines])."""
    items, i, base_indent, blanks = [], start, None, 0
    while i < len(lines):
        line = lines[i]
        info = _list_item_match(line)
        if info:
            indent, kind, content, marker = info
            if base_indent is None:
                base_indent = indent
            if indent < base_indent:
                break
            if blanks and indent <= base_indent and items and _blank_run_ends_list(lines, i):
                pass
            items.append({"indent": indent, "kind": kind, "lines": [content], "marker": marker})
            blanks = 0
            i += 1
            continue
        if not line.strip():
            # A blank line only ends the list when the next line is not
            # indented continuation / another item.
            nxt = lines[i + 1] if i + 1 < len(lines) else ""
            if not nxt.strip():
                break
            if _list_item_match(nxt) or len(nxt) - len(nxt.lstrip()) >= (base_indent or 0) + 2:
                blanks += 1
                if items:
                    items[-1]["lines"].append("")
                i += 1
                continue
            break
        indent = len(line) - len(line.lstrip())
        if items and indent >= (base_indent or 0) + 2:
            items[-1]["lines"].append(line.strip())
            i += 1
            continue
        if items and indent > (base_indent or 0):
            items[-1]["lines"].append(line.strip())
            i += 1
            continue
        break
    return items, i


def _blank_run_ends_list(lines, i):
    return False


def _render_items(items, pos=0, indent=None):
    """Build nested <ul>/<ol> from flat items using indentation levels."""
    if pos >= len(items):
        return "", pos
    indent = items[pos]["indent"] if indent is None else indent
    kind = items[pos]["kind"]
    start_num = items[pos]["marker"] if kind == "ol" else None
    out = []
    while pos < len(items):
        item = items[pos]
        if item["indent"] < indent:
            break
        if item["indent"] > indent:
            nested, pos = _render_items(items, pos, item["indent"])
            if out and out[-1].endswith("</li>"):
                out[-1] = out[-1][: -len("</li>")] + nested + "</li>"
            elif out:
                out[-1] += nested
            else:
                out.append("<li>%s</li>" % nested)
            continue
        if item["kind"] != kind:
            break
        body_lines = item["lines"]
        first = body_lines[0]
        task = _TASK_RE.match(first)
        checkbox = ""
        if task:
            checked = " checked" if task.group(1).lower() == "x" else ""
            checkbox = '<input type="checkbox" disabled%s> ' % checked
            body_lines = [task.group(2)] + body_lines[1:]
        rendered = _render_blocks(body_lines).strip()
        if rendered.startswith("<p>") and rendered.endswith("</p>") and rendered.count("<p>") == 1:
            rendered = rendered[3:-4]
        out.append("<li>%s%s</li>" % (checkbox, rendered))
        pos += 1
    attrs = ""
    if kind == "ol":
        try:
            if start_num is not None and int(start_num) != 1:
                attrs = ' start="%d"' % int(start_num)
        except (TypeError, ValueError):
            attrs = ""
    cls = ' class="task-list"' if any("<input type=\"checkbox\"" in x for x in out) else ""
    return "<%s%s%s>%s</%s>" % (kind, attrs, cls, "".join(out), kind), pos


def _render_blocks(lines):
    out, i, n = [], 0, len(lines)
    while i < n:
        line = lines[i]

        if not line.strip():
            i += 1
            continue

        fence = _FENCE_RE.match(line)
        if fence:
            marker, lang = fence.group(2), fence.group(3)
            strip = len(fence.group(1))
            body, i = [], i + 1
            while i < n:
                close = _FENCE_RE.match(lines[i])
                if close and close.group(2)[0] == marker[0] and len(close.group(2)) >= len(marker):
                    i += 1
                    break
                body.append(lines[i][strip:] if lines[i][:strip].strip() == "" else lines[i])
                i += 1
            out.append(_code_block("\n".join(body), lang))
            continue

        heading = _HEADING_RE.match(line)
        if heading:
            level = len(heading.group(1))
            out.append("<h%d>%s</h%d>" % (level, _inline(heading.group(2)), level))
            i += 1
            continue

        if _HR_RE.match(line):
            out.append("<hr>")
            i += 1
            continue

        if _QUOTE_RE.match(line):
            body = []
            while i < n and (_QUOTE_RE.match(lines[i]) or (lines[i].strip() and body)):
                m = _QUOTE_RE.match(lines[i])
                if m:
                    body.append(m.group(1))
                    i += 1
                else:
                    break
            out.append("<blockquote>%s</blockquote>" % _render_blocks(body))
            continue

        if "|" in line and i + 1 < n and _TABLE_SEP_RE.match(lines[i + 1]) and line.strip():
            html_table, i = _table(lines, i)
            out.append(html_table)
            continue

        if _list_item_match(line):
            items, i = _collect_list(lines, i)
            rendered, _ = _render_items(items)
            out.append(rendered)
            continue

        if line.startswith("    ") and (not out or out[-1].startswith(("<pre", "<div class=\"codewrap"))) is False:
            body = []
            while i < n and (lines[i].startswith("    ") or not lines[i].strip()):
                if not lines[i].strip() and not (i + 1 < n and lines[i + 1].startswith("    ")):
                    break
                body.append(lines[i][4:])
                i += 1
            out.append(_code_block("\n".join(body).rstrip()))
            continue

        para = []
        while i < n and lines[i].strip():
            if (
                _FENCE_RE.match(lines[i])
                or _HEADING_RE.match(lines[i])
                or _HR_RE.match(lines[i])
                or _QUOTE_RE.match(lines[i])
                or (para and _list_item_match(lines[i]))
                or ("|" in lines[i] and i + 1 < n and _TABLE_SEP_RE.match(lines[i + 1]))
            ):
                break
            para.append(lines[i])
            i += 1
        if para:
            out.append("<p>%s</p>" % _inline("\n".join(para)))
        else:
            i += 1
    return "\n".join(out)


def render_markdown(text):
    if not text:
        return ""
    text = str(text).replace("\r\n", "\n").replace("\r", "\n")
    return _render_blocks(text.split("\n"))
