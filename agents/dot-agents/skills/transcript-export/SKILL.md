---
name: transcript-export
description: >
  Export a GitHub Copilot CLI session transcript to a single self-contained HTML file
  that preserves formatting (markdown, code blocks, diffs, tables, tool calls). Use when
  the user asks to export/save/share/archive a transcript, conversation, session or chat
  log as HTML, wants a readable copy of a Copilot session, wants to attach a session to a
  ticket, issue or email, or asks "what sessions do I have". Run the bundled export_transcript.py
  helper rather than hand-building HTML.
allowed-tools: ["Bash", "AskUserQuestion"]
---

# Copilot Transcript Export

Turns a Copilot CLI session into one HTML file: inline CSS/JS, no external assets, no
network calls. Safe to email, archive, or attach to an issue.

Source of truth is the event log Copilot CLI writes per session:
`~/.copilot/session-state/<session-id>/events.jsonl` (session titles come from
`~/.copilot/session-store.db`). Nothing is uploaded anywhere.

## Usage

```bash
S=~/.agents/skills/transcript-export/scripts/export_transcript.py

python3 "$S" --list                        # browse sessions (newest first, * = active)
python3 "$S" --session current             # the session running right now
python3 "$S" --session latest --open       # most recently updated, open when done
python3 "$S" --session 435455e9            # id prefix is enough
python3 "$S" --all --since 7d --out-dir ~/transcripts
```

`--session` accepts `current`, `latest`, a full id, an unambiguous id prefix, or a path
to a session directory / `events.jsonl`.

## Choosing the session

1. If the user says "this session" / "our conversation", use `--session current`.
2. If they name a topic, repo or date, run `--list` first and match on the summary
   column, then export by id. `--list --since 7d`, `--cwd-filter <text>` and
   `--grep <text>` narrow it down.
3. If ambiguous, show the `--list` output and ask which one.

Always report the written path back to the user, and mention the file is self-contained.

## Useful flags

| Flag | Effect |
|---|---|
| `-o, --output PATH` | Exact output file (or a directory) |
| `--out-dir DIR` | Directory for generated names (default: cwd) |
| `--full` | Never truncate tool output |
| `--compact` | Truncate tool output hard (1200 chars) for a small file |
| `--max-output-chars N` | Custom truncation (default 20000) |
| `--all --since 7d` | Batch export; `--limit N` caps the count |
| `--open` | Open the result in the default browser |
| `-q, --quiet` | Print only the path (good for scripting/piping) |

Default filename: `copilot-<date>-<slug>-<shortid>.html` in `--out-dir`.

## What the HTML contains

- User prompts, Copilot replies, and collapsible **Thinking** blocks, in order.
- Collapsible tool calls: command/arguments rendered per tool (bash, view, edit,
  apply_patch, sql, task, MCP tools...), plus output, duration and ok/failed status.
  Sub-agent calls nest under their parent.
- Markdown formatting preserved: headings, lists, tables, blockquotes, links,
  inline code, fenced code blocks, and colored diffs for edits/patches.
- Header with session id, repo, branch, cwd, model, duration, tool/token stats.
- Sidebar index of prompts, live search with highlighting, toggles for
  Tools / Thinking / Context, expand-all, light-dark theme, print stylesheet.

Harness-injected messages (skill contexts, system reminders) are classified as
**Context** and hidden behind a toggle so the human conversation reads cleanly.

## Notes

- Huge sessions produce multi-MB files; suggest `--compact` if the user wants to email it.
- Transcripts can contain secrets, internal hostnames and file contents that were on
  screen during the session. Remind the user to review before sharing externally.
- Exports are plain files on disk; nothing is sent to any service.
