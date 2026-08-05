# agents

Shared [agent skills](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
for CLI coding agents, kept in one central place so multiple harnesses pick them up.

Skills live in `dot-agents/skills/<skill-name>/SKILL.md` (plus any helper scripts in
that same folder), which flings to `~/.agents/skills/`.

## Which directories get picked up

GitHub Copilot CLI discovers skills from:

| Scope | Directories |
| --- | --- |
| Personal | `~/.agents/skills/`, `~/.copilot/skills/` |
| Project | `.agents/skills/`, `.github/skills/`, `.claude/skills/` (git root & cwd) |
| Custom | dirs added via `/skills add`, or the `COPILOT_SKILLS_DIRS` env var (colon-separated) |
| Plugins | `~/.copilot/installed-plugins/` |

`~/.agents/skills/` is the harness-neutral personal location, which is why this package
targets it.

## Install/Symlink

```bash
fling --src-dir agents link
```

Then, in a Copilot CLI session, run `/skills reload` (or `copilot skill list` from a
shell) to confirm the skills are found.

## Skills

- `transcript-export` — export a Copilot CLI session to a single self-contained HTML file.

## Adding a skill

Create `dot-agents/skills/<name>/SKILL.md` with YAML frontmatter:

```markdown
---
name: my-skill
description: >
  What it does and when the agent should use it. This text is what the agent
  matches against, so mention the triggering phrasings.
---

# My Skill

Instructions for the agent...
```

Keep skills generic: no employer-internal tools, hostnames, or links, since this repo is
public.

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
