# agents

Shared [agent skills](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
for CLI coding agents, kept in one central place so multiple harnesses pick them up.

Skills live in `dot-agents/skills/<skill-name>/SKILL.md` (plus any helper scripts in
that same folder), which flings to `~/.agents/skills/`.

# Where Copilot gets skills

GitHub Copilot CLI discovers skills from:

| Scope | Directories |
| --- | --- |
| Personal | `~/.agents/skills/`, `~/.copilot/skills/` |
| Project | `.agents/skills/`, `.github/skills/`, `.claude/skills/` (git root & cwd) |
| Custom | dirs added via `/skills add`, or the `COPILOT_SKILLS_DIRS` env var (colon-separated) |
| Plugins | `~/.copilot/installed-plugins/` |

`~/.agents/skills/` is the harness-neutral personal location, which is why this package
targets it.

# Install/Symlink

```bash
fling --src-dir agents link
```

Then, in a Copilot CLI session, run `/skills reload` (or `copilot skill list` from a
shell) to confirm the skills are found.

# Personal Skills

- `transcript-export` — export a Copilot CLI session to a single self-contained HTML file.


# CMUX skills

The reviewed CMUX skill bundle is checked in under `dot-agents/skills/cmux*` and is
installed by the same `fling --src-dir agents link` command above. No separate
download or internet-hosted install script is required.

Included skills:

- `cmux` — core topology and routing controls.
- `cmux-browser` — browser automation in cmux webviews.
- `cmux-customization` — actions, commands, layouts, and shortcuts.
- `cmux-diagnostics` — health checks and support-safe diagnostics.
- `cmux-markdown` — formatted Markdown panels with live reload.
- `cmux-settings` — safe cmux configuration management.
- `cmux-workspace` — current-workspace and pane automation.

## Update from upstream

Clone https://github.com/manaflow-ai/cmux-skills/blob/main/README.md

```bash
git clone https://github.com/manaflow-ai/cmux-skills.git
```

Copy the inside the skills directory into ~/.agents/skills/

# crit

Installs some skills here.

```bash
brew install crit
```

https://crit.md/integrations/github-copilot

```
$ cd ~ && crit install github-copilot
  Installed: /Users/bkane/.agents/skills/crit/SKILL.md
  Installed: /Users/bkane/.agents/skills/crit-cli/SKILL.md
  Run /crit in GitHub Copilot to start a review loop
  The crit-cli skill is available to GitHub Copilot agents when needed
```
