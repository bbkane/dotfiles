#!/usr/bin/env python3
"""Export a GitHub Copilot CLI session transcript to a self-contained HTML file.

Reads the append-only event log Copilot CLI writes at
``~/.copilot/session-state/<session-id>/events.jsonl`` and renders a single HTML
document: inline CSS/JS, no external assets, no network calls, safe to email,
archive or attach to a ticket.

Examples
--------
  export_transcript.py --list
  export_transcript.py --session latest --open
  export_transcript.py --session 435455e9 -o ~/Desktop/debug-session.html
  export_transcript.py --all --since 7d --out-dir ~/transcripts
"""

from __future__ import annotations

import argparse
import datetime as dt
import html as html_mod
import json
import os
import re
import sqlite3
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from assets import CSS, JS  # noqa: E402
from markdown_lite import escape, render_markdown  # noqa: E402

DEFAULT_MAX_OUTPUT = 20000
TAIL_CHARS = 600

# Events that carry no reader value; hooks/permissions are pure machinery.
SKIP_TYPES = {
    "hook.start",
    "hook.end",
    "permission.requested",
    "permission.completed",
    "assistant.turn_start",
    "assistant.turn_end",
    "session.usage_checkpoint",
    "session.permissions_changed",
    "session.binary_asset",
    "session.workspace_file_changed",
    "tool.user_requested",
}

TOOL_ICONS = {
    "bash": "\u2318",
    "view": "\U0001f4c4",
    "edit": "\u270e",
    "create": "\u2795",
    "apply_patch": "\u270e",
    "glob": "\U0001f50d",
    "grep": "\U0001f50d",
    "rg": "\U0001f50d",
    "task": "\U0001f916",
    "skill": "\U0001f9e9",
    "web_fetch": "\U0001f310",
    "sql": "\U0001f5c4",
    "session_store_sql": "\U0001f5c4",
    "ask_user": "\u2753",
    "read_bash": "\u2318",
    "stop_bash": "\u2318",
}


# --------------------------------------------------------------------------
# session discovery
# --------------------------------------------------------------------------
def copilot_home():
    env = os.environ.get("COPILOT_HOME") or os.environ.get("XDG_COPILOT_HOME")
    return Path(env).expanduser() if env else Path.home() / ".copilot"


def sessions_root():
    return copilot_home() / "session-state"


def store_metadata():
    """Best-effort session metadata (summary/repo/branch) from session-store.db."""
    db = copilot_home() / "session-store.db"
    if not db.exists():
        return {}
    out = {}
    for uri in (
        "file:%s?mode=ro" % db,
        "file:%s?mode=ro&immutable=1" % db,
    ):
        try:
            conn = sqlite3.connect(uri, uri=True, timeout=2.0)
            try:
                rows = conn.execute(
                    "SELECT id, cwd, repository, branch, summary, created_at, updated_at FROM sessions"
                ).fetchall()
            finally:
                conn.close()
            for r in rows:
                out[r[0]] = {
                    "cwd": r[1],
                    "repository": r[2],
                    "branch": r[3],
                    "summary": r[4],
                    "created_at": r[5],
                    "updated_at": r[6],
                }
            return out
        except sqlite3.Error:
            continue
    return out


def discover_sessions():
    root = sessions_root()
    if not root.is_dir():
        return []
    meta = store_metadata()
    found = []
    for d in root.iterdir():
        log = d / "events.jsonl"
        if not d.is_dir() or not log.is_file() or log.stat().st_size == 0:
            continue
        info = dict(meta.get(d.name) or {})
        info.update(
            {
                "id": d.name,
                "dir": d,
                "log": log,
                "mtime": dt.datetime.fromtimestamp(log.stat().st_mtime),
                "size": log.stat().st_size,
                "active": any(d.glob("inuse.*.lock")),
            }
        )
        found.append(info)
    found.sort(key=lambda s: s["mtime"], reverse=True)
    return found


def peek_session(info):
    """Fill in cwd / first prompt for sessions missing store metadata."""
    if info.get("summary") and info.get("cwd"):
        return info
    try:
        with info["log"].open("r", encoding="utf-8", errors="replace") as fh:
            for n, line in enumerate(fh):
                if n > 400:
                    break
                try:
                    ev = json.loads(line)
                except ValueError:
                    continue
                data = ev.get("data") or {}
                if ev.get("type") == "session.start":
                    ctx = data.get("context") or {}
                    info.setdefault("cwd", ctx.get("cwd"))
                    info["cwd"] = info.get("cwd") or ctx.get("cwd")
                    info["repository"] = info.get("repository") or ctx.get("repository")
                    info["branch"] = info.get("branch") or ctx.get("branch")
                elif ev.get("type") == "user.message" and data.get("source") != "system":
                    text = (data.get("content") or "").strip()
                    if text and not info.get("summary"):
                        info["summary"] = " ".join(text.split())[:120]
                        break
    except OSError:
        pass
    return info


def parse_since(spec):
    if not spec:
        return None
    m = re.fullmatch(r"(\d+)\s*([hdwm])", spec.strip().lower())
    if not m:
        try:
            return dt.datetime.fromisoformat(spec)
        except ValueError:
            raise SystemExit("Cannot parse --since %r (use 24h, 7d, 2w or ISO date)" % spec)
    n, unit = int(m.group(1)), m.group(2)
    hours = {"h": 1, "d": 24, "w": 168, "m": 720}[unit] * n
    return dt.datetime.now() - dt.timedelta(hours=hours)


def resolve_session(spec, sessions):
    if not sessions:
        raise SystemExit("No Copilot sessions found under %s" % sessions_root())
    if spec in (None, "latest", "last"):
        return sessions[0]
    if spec == "current":
        active = [s for s in sessions if s["active"]]
        if not active:
            raise SystemExit("No active session found; try --session latest")
        return active[0]
    spec_l = spec.lower()
    exact = [s for s in sessions if s["id"].lower() == spec_l]
    if exact:
        return exact[0]
    if os.sep in spec or spec.endswith(".jsonl"):
        p = Path(spec).expanduser()
        log = p if p.is_file() else p / "events.jsonl"
        if log.is_file():
            return {
                "id": log.parent.name,
                "dir": log.parent,
                "log": log,
                "mtime": dt.datetime.fromtimestamp(log.stat().st_mtime),
                "size": log.stat().st_size,
                "active": False,
            }
    prefix = [s for s in sessions if s["id"].lower().startswith(spec_l)]
    if len(prefix) == 1:
        return prefix[0]
    if len(prefix) > 1:
        raise SystemExit(
            "Ambiguous session %r matches: %s" % (spec, ", ".join(s["id"][:12] for s in prefix[:8]))
        )
    raise SystemExit("No session matching %r (use --list to see available sessions)" % spec)


# --------------------------------------------------------------------------
# event parsing
# --------------------------------------------------------------------------
def parse_ts(value):
    if not value:
        return None
    try:
        text = str(value)
        if text.endswith("Z"):
            text = text[:-1] + "+00:00"
        stamp = dt.datetime.fromisoformat(text)
        if stamp.tzinfo:
            stamp = stamp.astimezone()
        return stamp
    except ValueError:
        return None


def fmt_ts(stamp, with_date=False):
    if not stamp:
        return ""
    return stamp.strftime("%b %d, %H:%M:%S" if with_date else "%H:%M:%S")


def fmt_duration(seconds):
    if seconds is None:
        return ""
    seconds = int(seconds)
    h, rem = divmod(seconds, 3600)
    m, s = divmod(rem, 60)
    if h:
        return "%dh %dm" % (h, m)
    if m:
        return "%dm %ds" % (m, s)
    return "%ds" % s


def load_events(path):
    with path.open("r", encoding="utf-8", errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except ValueError:
                continue


def parse_transcript(log_path):
    """Turn the raw event log into an ordered list of renderable items."""
    meta = {
        "session_id": log_path.parent.name,
        "models": [],
        "resumes": 0,
        "tool_counts": {},
        "files": set(),
        "usage": {},
    }
    items = []
    tools = {}
    intents = {}
    first_ts = last_ts = None

    for ev in load_events(log_path):
        etype = ev.get("type")
        data = ev.get("data") or {}
        stamp = parse_ts(ev.get("timestamp"))
        if stamp:
            first_ts = first_ts or stamp
            last_ts = stamp
        if etype in SKIP_TYPES:
            continue

        if etype == "session.start":
            ctx = data.get("context") or {}
            meta.setdefault("start_time", parse_ts(data.get("startTime")) or stamp)
            for key, src in (
                ("cwd", ctx.get("cwd")),
                ("repository", ctx.get("repository")),
                ("branch", ctx.get("branch")),
                ("git_root", ctx.get("gitRoot")),
                ("head_commit", ctx.get("headCommit")),
                ("copilot_version", data.get("copilotVersion")),
                ("context_tier", data.get("contextTier")),
            ):
                if src and not meta.get(key):
                    meta[key] = src

        elif etype == "session.resume":
            meta["resumes"] += 1
            items.append({"kind": "notice", "ts": stamp, "text": "Session resumed"})

        elif etype == "session.model_change":
            model = data.get("newModel")
            if model and model not in meta["models"]:
                meta["models"].append(model)
            effort = data.get("reasoningEffort")
            label = "Model set to %s" % model if model else "Model changed"
            if effort:
                label += " (reasoning: %s)" % effort
            items.append({"kind": "notice", "ts": stamp, "text": label})

        elif etype == "user.message":
            content = data.get("content") or data.get("transformedContent") or ""
            if not str(content).strip():
                continue
            source = str(data.get("source") or "")
            if not source:
                kind, who = "user", "You"
            elif source.startswith("agent-"):
                kind, who = "peer", "Agent"
            else:
                kind, who = "system", source
            items.append(
                {
                    "kind": kind,
                    "who": who,
                    "role": source or None,
                    "ts": stamp,
                    "content": str(content),
                    "attachments": [
                        a.get("displayName") or a.get("path") or "attachment"
                        for a in (data.get("attachments") or [])
                        if isinstance(a, dict)
                    ],
                }
            )

        elif etype == "system.message":
            content = data.get("content") or ""
            if str(content).strip():
                items.append(
                    {
                        "kind": "system",
                        "ts": stamp,
                        "content": str(content),
                        "role": data.get("role") or "system",
                        "attachments": [],
                    }
                )

        elif etype == "assistant.message":
            model = data.get("model")
            if model and model not in meta["models"]:
                meta["models"].append(model)
            for req in data.get("toolRequests") or []:
                if isinstance(req, dict) and req.get("toolCallId"):
                    intents[req["toolCallId"]] = req.get("intentionSummary") or req.get("toolTitle")
            content = str(data.get("content") or "")
            reasoning = str(data.get("reasoningText") or "")
            if content.strip() or reasoning.strip():
                items.append(
                    {
                        "kind": "assistant",
                        "ts": stamp,
                        "content": content,
                        "reasoning": reasoning,
                        "model": model,
                        "tokens": data.get("outputTokens"),
                    }
                )

        elif etype == "tool.execution_start":
            name = data.get("toolName") or "tool"
            meta["tool_counts"][name] = meta["tool_counts"].get(name, 0) + 1
            args = data.get("arguments")
            if isinstance(args, str):
                try:
                    args = json.loads(args)
                except ValueError:
                    args = {"input": args}
            item = {
                "kind": "tool",
                "ts": stamp,
                "name": name,
                "args": args if isinstance(args, dict) else {"input": args},
                "call_id": data.get("toolCallId"),
                "mcp": data.get("mcpServerName"),
                "mcp_tool": data.get("mcpToolName"),
                "result": None,
                "success": None,
                "children": [],
                "intent": intents.get(data.get("toolCallId")),
            }
            for path_key in ("path", "file_path", "filePath"):
                if isinstance(item["args"], dict) and item["args"].get(path_key):
                    if name in ("edit", "create", "apply_patch", "str_replace_editor"):
                        meta["files"].add(str(item["args"][path_key]))
            if data.get("toolCallId"):
                tools[data["toolCallId"]] = item
            parent = tools.get(data.get("parentToolCallId"))
            if parent is not None:
                parent["children"].append(item)
            else:
                items.append(item)

        elif etype == "tool.execution_complete":
            item = tools.get(data.get("toolCallId"))
            if item is None:
                continue
            result = data.get("result") or {}
            if isinstance(result, dict):
                item["result"] = result.get("detailedContent") or result.get("content") or ""
                structured = result.get("structuredContent")
                if structured and not item["result"]:
                    item["result"] = json.dumps(structured, indent=2)
            else:
                item["result"] = str(result)
            item["success"] = data.get("success")
            item["end_ts"] = stamp

        elif etype == "skill.invoked":
            name = data.get("skillName") or data.get("name") or data.get("skill") or "skill"
            items.append({"kind": "notice", "ts": stamp, "text": "Skill invoked: %s" % name})

        elif etype == "subagent.started":
            label = data.get("agentType") or data.get("name") or "sub-agent"
            items.append({"kind": "notice", "ts": stamp, "text": "Sub-agent started: %s" % label})

        elif etype == "subagent.completed":
            label = data.get("agentType") or data.get("name") or "sub-agent"
            items.append({"kind": "notice", "ts": stamp, "text": "Sub-agent finished: %s" % label})

        elif etype == "abort":
            items.append({"kind": "notice", "ts": stamp, "text": "Request aborted"})

        elif etype in ("session.warning", "session.info", "system.notification"):
            text = data.get("message") or data.get("content") or data.get("text")
            if text:
                items.append({"kind": "notice", "ts": stamp, "text": str(text)[:600]})

        elif etype == "session.shutdown":
            meta["usage"] = {
                "Premium requests": data.get("totalPremiumRequests"),
                "Conversation tokens": data.get("conversationTokens"),
                "API time": fmt_duration((data.get("totalApiDurationMs") or 0) / 1000.0)
                if data.get("totalApiDurationMs")
                else None,
            }
            changes = data.get("codeChanges") or {}
            if isinstance(changes, dict):
                if changes.get("linesAdded") is not None:
                    meta["usage"]["Lines added"] = changes.get("linesAdded")
                if changes.get("linesRemoved") is not None:
                    meta["usage"]["Lines removed"] = changes.get("linesRemoved")

    meta["first_ts"] = first_ts
    meta["last_ts"] = last_ts
    meta["duration"] = (last_ts - first_ts).total_seconds() if first_ts and last_ts else None
    return meta, items


# --------------------------------------------------------------------------
# tool rendering
# --------------------------------------------------------------------------
def code_html(text, lang=""):
    label = '<span class="code-lang">%s</span>' % escape(lang) if lang else ""
    cls = ' class="lang-%s"' % escape(lang) if lang else ""
    return '<div class="codewrap">%s<pre><code%s>%s</code></pre></div>' % (
        label,
        cls,
        escape(text, quote=False),
    )


def diff_html(text):
    lines = []
    for line in str(text).split("\n"):
        cls = ""
        if line.startswith(("+++", "---")):
            cls = "hunk"
        elif line.startswith("@@"):
            cls = "hunk"
        elif line.startswith("+"):
            cls = "add"
        elif line.startswith("-"):
            cls = "del"
        safe = escape(line, quote=False) or "&nbsp;"
        lines.append('<span class="%s">%s</span>' % (cls, safe) if cls else "<span>%s</span>" % safe)
    return '<div class="codewrap diff"><pre><code>%s</code></pre></div>' % "".join(lines)


def looks_like_diff(text):
    head = str(text)[:4000]
    if head.lstrip().startswith(("diff --git", "--- a/", "*** Begin Patch")):
        return True
    lines = head.split("\n")
    if len(lines) < 4:
        return False
    marked = sum(1 for ln in lines if ln[:1] in "+-" and ln[:3] not in ("---", "+++"))
    return marked >= 3 and marked >= len(lines) * 0.3 and any(ln.startswith("@@") for ln in lines)


def truncate(text, limit):
    text = "" if text is None else str(text)
    if limit <= 0 or len(text) <= limit:
        return text, 0
    if limit > TAIL_CHARS * 2:
        head = text[: limit - TAIL_CHARS]
        tail = text[-TAIL_CHARS:]
        return head + "\n\n[... %d characters omitted ...]\n\n" % (len(text) - limit) + tail, len(text) - limit
    return text[:limit], len(text) - limit


def label(text):
    return '<div class="label">%s</div>' % escape(text)


LANG_BY_EXT = {
    ".py": "python", ".js": "javascript", ".ts": "typescript", ".tsx": "tsx", ".jsx": "jsx",
    ".java": "java", ".go": "go", ".rs": "rust", ".rb": "ruby", ".sh": "bash", ".bash": "bash",
    ".zsh": "bash", ".yaml": "yaml", ".yml": "yaml", ".json": "json", ".sql": "sql",
    ".html": "html", ".css": "css", ".md": "markdown", ".xml": "xml", ".toml": "toml",
    ".ini": "ini", ".c": "c", ".h": "c", ".cpp": "cpp", ".kt": "kotlin", ".scala": "scala",
}


def lang_for_path(path):
    return LANG_BY_EXT.get(Path(str(path)).suffix.lower(), "")


def render_tool_args(name, args, limit):
    """Tool-aware argument rendering; falls back to pretty JSON."""
    if not isinstance(args, dict) or not args:
        return ""
    base = (name or "").split("-")[-1]
    out = []

    def get(*keys):
        for k in keys:
            if args.get(k) not in (None, ""):
                return args[k]
        return None

    if base in ("bash", "shell", "run_command"):
        cmd = get("command", "cmd", "input")
        if cmd:
            out.append(code_html(str(cmd), "bash"))
        for key, text in (("initial_wait", "wait"), ("shellId", "shell"), ("detach", "detach")):
            if args.get(key) not in (None, ""):
                out.append("<p><code>%s: %s</code></p>" % (escape(text), escape(args[key])))
    elif base in ("read_bash", "stop_bash"):
        out.append(code_html(json.dumps(args, indent=2, default=str), "json"))
    elif base == "view":
        path = get("path", "file_path")
        rng = args.get("view_range")
        suffix = " (lines %s-%s)" % (rng[0], rng[1]) if isinstance(rng, list) and len(rng) == 2 else ""
        out.append("<p><code>%s%s</code></p>" % (escape(path), escape(suffix)))
    elif base == "create":
        out.append("<p><code>%s</code></p>" % escape(get("path", "file_path")))
        body, omitted = truncate(get("file_text", "content") or "", limit)
        out.append(code_html(body, lang_for_path(get("path", "file_path") or "")))
        if omitted:
            out.append('<div class="truncated">%d characters omitted</div>' % omitted)
    elif base in ("edit", "str_replace_editor", "str_replace"):
        out.append("<p><code>%s</code></p>" % escape(get("path", "file_path")))
        old, _ = truncate(args.get("old_str") or "", limit // 2 or limit)
        new, _ = truncate(args.get("new_str") or "", limit // 2 or limit)
        lang = lang_for_path(get("path", "file_path") or "")
        if old:
            out.append(label("removed"))
            out.append(diff_html("\n".join("-" + ln for ln in old.split("\n"))))
        if new:
            out.append(label("added"))
            out.append(diff_html("\n".join("+" + ln for ln in new.split("\n"))))
        if not old and not new:
            out.append(code_html(json.dumps(args, indent=2, default=str), lang or "json"))
    elif base == "apply_patch":
        patch, omitted = truncate(get("input", "patch", "diff") or "", limit)
        out.append(diff_html(patch))
        if omitted:
            out.append('<div class="truncated">%d characters omitted</div>' % omitted)
    elif base in ("sql", "session_store_sql"):
        if args.get("description"):
            out.append("<p>%s</p>" % escape(args["description"]))
        out.append(code_html(get("query", "sql") or "", "sql"))
    elif base in ("grep", "rg", "search"):
        rows = [(k, v) for k, v in args.items() if v not in (None, "", [])]
        out.append(kv_table(rows))
    elif base == "glob":
        out.append("<p><code>%s</code>%s</p>" % (
            escape(get("pattern") or ""),
            " in <code>%s</code>" % escape(args["paths"]) if args.get("paths") else "",
        ))
    elif base == "web_fetch":
        url = get("url") or ""
        out.append('<p><a href="%s" target="_blank" rel="noopener noreferrer">%s</a></p>'
                   % (escape(url), escape(url)))
    elif base == "task":
        rows = [(k, args[k]) for k in ("agent_type", "description", "model", "mode") if args.get(k)]
        if rows:
            out.append(kv_table(rows))
        prompt, omitted = truncate(args.get("prompt") or "", limit)
        if prompt:
            out.append(label("prompt"))
            out.append('<div class="body">%s</div>' % render_markdown(prompt))
            if omitted:
                out.append('<div class="truncated">%d characters omitted</div>' % omitted)
    elif base == "skill":
        out.append("<p><code>%s</code></p>" % escape(get("skill", "name") or ""))
    elif base == "ask_user":
        if args.get("message"):
            out.append('<div class="body">%s</div>' % render_markdown(str(args["message"])))
        if args.get("requestedSchema"):
            out.append(code_html(json.dumps(args["requestedSchema"], indent=2, default=str), "json"))
    else:
        blob, omitted = truncate(json.dumps(args, indent=2, default=str, ensure_ascii=False), limit)
        out.append(code_html(blob, "json"))
        if omitted:
            out.append('<div class="truncated">%d characters omitted</div>' % omitted)
    return "".join(out)


def kv_table(rows):
    cells = []
    for key, value in rows:
        if isinstance(value, (dict, list)):
            value = json.dumps(value, default=str)
        cells.append("<tr><td><code>%s</code></td><td><code>%s</code></td></tr>"
                     % (escape(key), escape(value)))
    return '<div class="tablewrap"><table><tbody>%s</tbody></table></div>' % "".join(cells)


def tool_summary_text(item):
    args = item.get("args") or {}
    base = (item.get("name") or "").split("-")[-1]
    if base == "apply_patch":
        patch = str(args.get("input") or args.get("patch") or "")
        files = re.findall(r"\*\*\* (?:Update|Add|Delete) File: (.+)", patch)
        if files:
            return ", ".join(f.strip() for f in files[:3])[:150]
    for key in ("command", "path", "file_path", "pattern", "query", "url", "description",
                "skill", "prompt", "message"):
        value = args.get(key)
        if isinstance(value, str) and value.strip():
            return " ".join(value.split())[:150]
    if item.get("intent"):
        return " ".join(str(item["intent"]).split())[:150]
    if base and args:
        return " ".join(json.dumps(args, default=str)[:150].split())
    return ""


def render_tool(item, limit, depth=0):
    name = item.get("name") or "tool"
    display = "%s\u00b7%s" % (item["mcp"], item["mcp_tool"]) if item.get("mcp") else name
    icon = TOOL_ICONS.get(name.split("-")[-1], "\u2699")
    success = item.get("success")
    status = ""
    if success is False:
        status = '<span class="status err">failed</span>'
    elif success is True:
        status = '<span class="status ok">ok</span>'
    summary = tool_summary_text(item)
    elapsed = ""
    if item.get("ts") and item.get("end_ts"):
        secs = (item["end_ts"] - item["ts"]).total_seconds()
        if secs >= 1:
            elapsed = '<span class="chip">%s</span>' % escape(fmt_duration(secs))

    body = [render_tool_args(name, item.get("args"), limit)]
    result = item.get("result")
    if result:
        text, omitted = truncate(result, limit)
        body.append(label("output"))
        body.append(diff_html(text) if looks_like_diff(text) else code_html(text))
        if omitted:
            body.append('<div class="truncated">%d characters omitted (re-run with --full)</div>' % omitted)
    elif success is not None:
        body.append('<div class="truncated">no output</div>')

    for child in item.get("children") or []:
        body.append(render_tool(child, limit, depth + 1))

    cls = "sub" if depth else "tool"
    return (
        '<details class="%s">'
        '<summary><span class="toolname">%s %s</span>'
        '<span class="toolsum">%s</span><span class="spacer"></span>%s%s</summary>'
        '<div class="tool-body">%s</div></details>'
    ) % (cls, icon, escape(display), escape(summary), elapsed, status, "".join(body))


# --------------------------------------------------------------------------
# document rendering
# --------------------------------------------------------------------------
def preview(text, length=95):
    flat = " ".join(str(text).split())
    return flat[:length] + ("\u2026" if len(flat) > length else "")


def render_document(meta, items, opts, source):
    limit = 0 if opts.full else opts.max_output_chars
    title = meta.get("title") or "Copilot transcript"
    turn = 0
    toc = []
    blocks = []

    for item in items:
        kind = item["kind"]
        stamp = item.get("ts")
        tstr = fmt_ts(stamp)
        tattr = escape(stamp.isoformat()) if stamp else ""

        if kind in ("user", "peer"):
            attach = ""
            if item.get("attachments"):
                attach = "".join('<span class="chip">%s</span>' % escape(a) for a in item["attachments"])
            if kind == "user":
                turn += 1
                anchor = "turn-%d" % turn
                toc.append((anchor, preview(item["content"])))
            else:
                anchor = "peer-%d" % len(blocks)
            blocks.append('<div class="turn-sep">Turn %d</div>' % turn if kind == "user" else "")
            blocks.append(
                '<article class="msg %s" id="%s">'
                '<div class="msg-head"><span class="who">%s</span>%s<span class="spacer"></span>'
                '<time title="%s">%s</time></div>'
                '<div class="body">%s</div></article>'
                % (kind, anchor, escape(item.get("who") or "You"), attach, tattr, escape(tstr),
                   render_markdown(item["content"]))
            )

        elif kind == "assistant":
            inner = []
            if item.get("reasoning", "").strip():
                inner.append(
                    '<details class="think"><summary><span class="toolname">\U0001f9e0 Thinking</span>'
                    '<span class="toolsum">%s</span></summary><div class="tool-body">%s</div></details>'
                    % (escape(preview(item["reasoning"], 110)), render_markdown(item["reasoning"]))
                )
            if item.get("content", "").strip():
                inner.append(render_markdown(item["content"]))
            if not inner:
                continue
            chips = ""
            if item.get("model"):
                chips += '<span class="chip">%s</span>' % escape(item["model"])
            blocks.append(
                '<article class="msg assistant">'
                '<div class="msg-head"><span class="who">Copilot</span>%s<span class="spacer"></span>'
                '<time title="%s">%s</time></div>'
                '<div class="body">%s</div></article>'
                % (chips, tattr, escape(tstr), "".join(inner))
            )

        elif kind == "tool":
            blocks.append(
                '<article class="msg toolcall"><div class="body">%s</div></article>'
                % render_tool(item, limit)
            )

        elif kind == "system":
            content = item.get("content", "")
            blocks.append(
                '<article class="msg system">'
                '<div class="msg-head"><span class="who">Context</span>'
                '<span class="chip">%s</span><span class="spacer"></span><time title="%s">%s</time></div>'
                '<div class="body"><details><summary>%s</summary><div>%s</div></details></div></article>'
                % (
                    escape(item.get("role") or "system"),
                    tattr,
                    escape(tstr),
                    escape(preview(content, 120)),
                    render_markdown(content),
                )
            )

        elif kind == "notice":
            blocks.append(
                '<article class="msg notice"><div class="msg-head">'
                '<span class="who">\u2139</span><span>%s</span><span class="spacer"></span>'
                '<time title="%s">%s</time></div></article>'
                % (escape(item["text"]), tattr, escape(tstr))
            )

    if not blocks:
        blocks.append('<div class="empty-state">This session contains no renderable messages.</div>')

    toc_html = "".join(
        '<li><a href="#%s">%s</a></li>' % (anchor, escape(text)) for anchor, text in toc
    ) or '<li><span class="toolsum">no prompts</span></li>'

    meta_rows = [
        ("Session", meta["session_id"]),
        ("Started", fmt_ts(meta.get("first_ts"), True)),
        ("Ended", fmt_ts(meta.get("last_ts"), True)),
        ("Duration", fmt_duration(meta.get("duration"))),
        ("Turns", turn),
        ("Repository", meta.get("repository")),
        ("Branch", meta.get("branch")),
        ("Directory", meta.get("cwd")),
        ("Model", ", ".join(meta.get("models") or [])),
        ("CLI version", meta.get("copilot_version")),
        ("Context tier", meta.get("context_tier")),
        ("Tool calls", sum((meta.get("tool_counts") or {}).values()) or None),
        ("Files edited", len(meta.get("files") or ()) or None),
        ("Resumes", meta.get("resumes") or None),
    ]
    for key, value in (meta.get("usage") or {}).items():
        meta_rows.append((key, value))
    meta_html = "".join(
        "<div><dt>%s</dt><dd>%s</dd></div>" % (escape(k), escape(v))
        for k, v in meta_rows
        if v not in (None, "", 0)
    )

    top_tools = sorted((meta.get("tool_counts") or {}).items(), key=lambda kv: -kv[1])[:8]
    tools_html = ""
    if top_tools:
        tools_html = "<div><dt>Tools used</dt><dd>%s</dd></div>" % escape(
            ", ".join("%s\u00d7%d" % (n, c) for n, c in top_tools)
        )

    files_html = ""
    if meta.get("files"):
        listed = sorted(meta["files"])[:40]
        files_html = "<div><dt>Files touched</dt><dd>%s</dd></div>" % "<br>".join(
            escape(f) for f in listed
        )

    generated = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return TEMPLATE % {
        "title": escape(title),
        "subtitle": escape(
            " \u00b7 ".join(
                str(x)
                for x in (meta.get("repository"), meta.get("branch"), meta.get("cwd"))
                if x
            )
        ),
        "css": CSS,
        "js": JS,
        "toc": toc_html,
        "meta": meta_html + tools_html + files_html,
        "content": "\n".join(blocks),
        "generated": escape(generated),
        "source": escape(str(source)),
        "session": escape(meta["session_id"]),
    }


TEMPLATE = """<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="generator" content="copilot transcript-export">
<meta name="color-scheme" content="light dark">
<title>%(title)s</title>
<style>%(css)s</style>
</head>
<body class="show-tools show-think">
<header class="top">
  <div class="top-inner">
    <h1 class="title">%(title)s<small>%(subtitle)s</small></h1>
    <div class="controls">
      <input id="search" type="search" placeholder="Search transcript  (/)" aria-label="Search transcript">
      <span class="hitcount" id="hitcount"></span>
      <button class="btn" data-class="show-tools" type="button" aria-pressed="true">Tools</button>
      <button class="btn" data-class="show-think" type="button" aria-pressed="true">Thinking</button>
      <button class="btn" data-class="show-system" type="button" aria-pressed="false">Context</button>
      <button class="btn" id="expand-btn" type="button" data-state="closed">Expand all</button>
      <button class="btn" id="theme-btn" type="button" title="Toggle theme">&#9788;</button>
      <button class="btn" id="print-btn" type="button">Print</button>
    </div>
  </div>
</header>
<div class="wrap">
  <nav class="toc"><h2>Prompts</h2><ol>%(toc)s</ol></nav>
  <main>
    <section class="meta-card"><dl class="meta-grid">%(meta)s</dl></section>
    %(content)s
  </main>
</div>
<footer class="bot">
  Exported %(generated)s from <code>%(source)s</code> &middot; session <code>%(session)s</code>.
  Self-contained: no external scripts, styles, fonts or network requests.
</footer>
<script>%(js)s</script>
</body>
</html>
"""


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------
def slugify(text, fallback="session"):
    slug = re.sub(r"[^a-z0-9]+", "-", str(text or "").lower()).strip("-")
    return (slug[:52] or fallback).strip("-")


def default_name(meta, session):
    stamp = (meta.get("first_ts") or session.get("mtime") or dt.datetime.now()).strftime("%Y-%m-%d")
    slug = slugify(meta.get("title") or session.get("summary") or "", "transcript")
    return "copilot-%s-%s-%s.html" % (stamp, slug, session["id"][:8])


def export_one(session, opts):
    meta, items = parse_transcript(session["log"])
    meta["repository"] = meta.get("repository") or session.get("repository")
    meta["branch"] = meta.get("branch") or session.get("branch")
    meta["cwd"] = meta.get("cwd") or session.get("cwd")
    summary = session.get("summary")
    if not summary:
        first_user = next((i for i in items if i["kind"] == "user"), None)
        summary = preview(first_user["content"], 90) if first_user else "Copilot session"
    meta["title"] = summary

    doc = render_document(meta, items, opts, session["log"])
    if opts.output:
        out = Path(opts.output).expanduser()
        if out.is_dir():
            out = out / default_name(meta, session)
    else:
        out = Path(opts.out_dir).expanduser() / default_name(meta, session)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(doc, encoding="utf-8")
    return out, meta, items


def cmd_list(opts):
    sessions = discover_sessions()
    since = parse_since(opts.since)
    rows = []
    for s in sessions:
        if since and s["mtime"] < since:
            continue
        if opts.cwd_filter and opts.cwd_filter not in (s.get("cwd") or ""):
            continue
        s = peek_session(s)
        if opts.grep and opts.grep.lower() not in json.dumps(
            {k: v for k, v in s.items() if isinstance(v, str)}
        ).lower():
            continue
        rows.append(s)
        if len(rows) >= opts.limit:
            break
    if not rows:
        print("No sessions found under %s" % sessions_root())
        return 0
    print("%-10s  %-16s  %8s  %-26s  %s" % ("ID", "UPDATED", "SIZE", "DIRECTORY", "SUMMARY"))
    print("-" * 118)
    for s in rows:
        size = s["size"]
        size_str = "%.1fM" % (size / 1048576.0) if size > 1048576 else "%dK" % (size // 1024)
        cwd = Path(s.get("cwd") or "").name or (s.get("repository") or "-")
        flag = "*" if s.get("active") else " "
        print(
            "%-10s%s %-16s  %8s  %-26s  %s"
            % (
                s["id"][:8],
                flag,
                s["mtime"].strftime("%m-%d %H:%M"),
                size_str,
                cwd[:26],
                preview(s.get("summary") or "", 46),
            )
        )
    print("\n* = currently active. Export with: --session <ID>")
    return 0


def main(argv=None):
    ap = argparse.ArgumentParser(
        prog="export_transcript.py",
        description="Export a Copilot CLI session transcript to a self-contained HTML file.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__.split("Examples")[-1],
    )
    ap.add_argument("--list", action="store_true", help="list available sessions and exit")
    ap.add_argument("--session", "-s", help="session id / id prefix / path / 'latest' / 'current'")
    ap.add_argument("--all", action="store_true", help="export every session (use with --since)")
    ap.add_argument("--since", help="only sessions updated within e.g. 24h, 7d, 2w")
    ap.add_argument("--output", "-o", help="output file (or directory) for a single export")
    ap.add_argument("--out-dir", default=".", help="output directory (default: current dir)")
    ap.add_argument("--max-output-chars", type=int, default=DEFAULT_MAX_OUTPUT,
                    help="truncate each tool output/argument blob (default: %d)" % DEFAULT_MAX_OUTPUT)
    ap.add_argument("--full", action="store_true", help="never truncate tool output")
    ap.add_argument("--compact", action="store_true", help="aggressively truncate tool output (1200 chars)")
    ap.add_argument("--limit", type=int, default=40, help="max rows for --list / --all")
    ap.add_argument("--cwd-filter", help="only sessions whose cwd contains this string")
    ap.add_argument("--grep", help="only sessions whose metadata matches this text (--list)")
    ap.add_argument("--open", action="store_true", dest="open_after", help="open the file when done")
    ap.add_argument("--quiet", "-q", action="store_true", help="print only the output path")
    opts = ap.parse_args(argv)

    if opts.compact:
        opts.max_output_chars = 1200
    if opts.list:
        return cmd_list(opts)

    sessions = discover_sessions()
    if opts.all:
        since = parse_since(opts.since)
        targets = [
            s for s in sessions
            if (not since or s["mtime"] >= since)
            and (not opts.cwd_filter or opts.cwd_filter in (s.get("cwd") or ""))
        ][: opts.limit]
        if not targets:
            print("No sessions matched.", file=sys.stderr)
            return 1
        opts.output = None
        written = []
        for s in targets:
            out, meta, _ = export_one(peek_session(s), opts)
            written.append(out)
            if not opts.quiet:
                print("%s  <-  %s" % (out, s["id"][:8]))
        if opts.quiet:
            print("\n".join(str(p) for p in written))
        return 0

    session = resolve_session(opts.session, sessions)
    session = peek_session(session)
    out, meta, items = export_one(session, opts)
    if opts.quiet:
        print(out)
    else:
        turns = sum(1 for i in items if i["kind"] == "user")
        tools = sum((meta.get("tool_counts") or {}).values())
        size_kb = out.stat().st_size / 1024.0
        print("Exported %s" % out)
        print(
            "  session %s | %d turns | %d tool calls | %s | %.0f KB"
            % (session["id"][:8], turns, tools, fmt_duration(meta.get("duration")), size_kb)
        )
    if opts.open_after:
        import webbrowser

        webbrowser.open(out.resolve().as_uri())
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except BrokenPipeError:
        sys.exit(0)
    except KeyboardInterrupt:
        sys.exit(130)
