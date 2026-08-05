# cmux

# Install

Install: https://cmux.com/docs/getting-started

```
brew tap manaflow-ai/cmux
brew install --cask cmux

# From the dotfiles repository root. Ignore cmux documentation files.
fling link -i '.*\.md' -s cmux
```

## Copilot CLI notifications

Copy this script to `~/.copilot/hooks/notify-cmux.py` rather than symlinking it.
Copilot CLI file edits can replace symlinks with regular files.

```python
#!/usr/bin/env python3
"""Send a bounded notification to the originating cmux surface."""

from __future__ import annotations

import logging
import os
import subprocess
import sys
import time
from logging.handlers import RotatingFileHandler
from pathlib import Path

surface_id = os.environ.get("CMUX_SURFACE_ID", "")
if not surface_id:
    sys.exit(0)

(Path.home() / ".copilot" / "logs").mkdir(parents=True, exist_ok=True)
logging.Formatter.converter = time.gmtime
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)sZ %(levelname)s %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
    handlers=[
        RotatingFileHandler(
            Path.home() / ".copilot" / "logs" / "notify_permission.log",
            maxBytes=256 * 1024,
            backupCount=2,
            encoding="utf-8",
            delay=True,
        )
    ],
)
logger = logging.getLogger(__name__)

try:
    result = subprocess.run(
        [
            "cmux",
            "notify",
            "--surface",
            surface_id,
            "--title",
            "Copilot",
            "--body",
            "Needs your attention",
        ],
        stdin=subprocess.DEVNULL,
        capture_output=True,
        check=False,
        text=True,
        timeout=0.75,
    )
except (OSError, subprocess.TimeoutExpired):
    logger.exception("failed to run cmux notification")
else:
    if result.returncode != 0:
        logger.error(
            "cmux notification failed: returncode=%d stdout=%r stderr=%r",
            result.returncode,
            result.stdout,
            result.stderr,
        )
```

Make the copied script executable:

```bash
chmod +x ~/.copilot/hooks/notify-cmux.py
```

Add the cmux handlers to the top-level `hooks` object in
`~/.copilot/settings.json`. Merge these entries with any existing handlers for
the same events:

```json
{
  "hooks": {
    "notification": [
      {
        "type": "command",
        "bash": "$HOME/.copilot/hooks/notify-cmux.py",
        "timeoutSec": 1
      }
    ],
    "agentStop": [
      {
        "type": "command",
        "bash": "$HOME/.copilot/hooks/notify-cmux.py",
        "timeoutSec": 1
      }
    ]
  }
}
```

Restart Copilot CLI after changing hook configuration.

## Keep cmux and Copilot running while the screen is locked

1. Plug in the MacBook and keep the lid open.
2. Activate KeepingYouAwake from the menu bar.
3. Enable **Allow display sleep** in KeepingYouAwake so the locked display can turn off while the system remains awake.
4. Press `Control-Command-Q` to lock the screen. Do not put the Mac to sleep.

Locking the screen does not stop cmux, Copilot CLI, or their network activity. KeepingYouAwake prevents idle system sleep; VPNs and remote services may still enforce their own session timeouts.

To confirm the sleep-prevention assertion is active:

```bash
pmset -g assertions
```

Look for `PreventUserIdleSystemSleep` owned by KeepingYouAwake or `caffeinate`.

## Copilot integration issues

- [notification for copilot cli agent · Issue #2523 · manaflow-ai/cmux](https://github.com/manaflow-ai/cmux/issues/2523)
  - [Feature Request: Add awaitingUserInput hook type · Issue #1128 · github/copilot-cli](https://github.com/github/copilot-cli/issues/1128)
    - This is why I'm not getting consistent prompts for copilot
- [[copilot] PreToolUse feed hook hangs for 120s and never gates tool execution · Issue #6574 · manaflow-ai/cmux](https://github.com/manaflow-ai/cmux/issues/6574)
  - This is why it's taking so long
- [cmux hooks copilot install: hooks get wiped by Copilot CLI on next session start · Issue #4374 · manaflow-ai/cmux](https://github.com/manaflow-ai/cmux/issues/4374)
  - this refers to the JSONC issue and the fact that `cmux hooks setup` works with `config.json` instead of `settings.json`

As of Fri 2026-07-24 I've got another hook thing going, we'll see how reliable that is.

## Install skills manually for auditing

```bash
cd ~/.copilot/skills   # or: cd .../bkane_dotfiles/copilot-cli/dot-copilot/skills
raw="https://raw.githubusercontent.com/manaflow-ai/cmux/main/skills"

# --- cmux (core) ---
mkdir -p cmux/references
curl -fsSL "$raw/cmux/SKILL.md"                               -o cmux/SKILL.md
curl -fsSL "$raw/cmux/references/handles-and-identify.md"     -o cmux/references/handles-and-identify.md
curl -fsSL "$raw/cmux/references/panes-surfaces.md"           -o cmux/references/panes-surfaces.md
curl -fsSL "$raw/cmux/references/trigger-flash-and-health.md" -o cmux/references/trigger-flash-and-health.md
curl -fsSL "$raw/cmux/references/windows-workspaces.md"       -o cmux/references/windows-workspaces.md

# --- cmux-workspace ---
mkdir -p cmux-workspace/references
curl -fsSL "$raw/cmux-workspace/SKILL.md"              -o cmux-workspace/SKILL.md
curl -fsSL "$raw/cmux-workspace/references/commands.md" -o cmux-workspace/references/commands.md

# --- cmux-customization ---
mkdir -p cmux-customization/references
curl -fsSL "$raw/cmux-customization/SKILL.md"              -o cmux-customization/SKILL.md
curl -fsSL "$raw/cmux-customization/references/examples.md" -o cmux-customization/references/examples.md

# --- cmux-markdown ---
mkdir -p cmux-markdown/references
curl -fsSL "$raw/cmux-markdown/SKILL.md"                 -o cmux-markdown/SKILL.md
curl -fsSL "$raw/cmux-markdown/references/commands.md"   -o cmux-markdown/references/commands.md
curl -fsSL "$raw/cmux-markdown/references/live-reload.md" -o cmux-markdown/references/live-reload.md

# --- cmux-settings (has script) ---
mkdir -p cmux-settings/references cmux-settings/scripts
curl -fsSL "$raw/cmux-settings/SKILL.md"                     -o cmux-settings/SKILL.md
curl -fsSL "$raw/cmux-settings/references/all-keys.md"       -o cmux-settings/references/all-keys.md
curl -fsSL "$raw/cmux-settings/references/shortcut-actions.md" -o cmux-settings/references/shortcut-actions.md
curl -fsSL "$raw/cmux-settings/scripts/cmux-settings"        -o cmux-settings/scripts/cmux-settings

# --- cmux-diagnostics (has script) ---
mkdir -p cmux-diagnostics/scripts
curl -fsSL "$raw/cmux-diagnostics/SKILL.md"              -o cmux-diagnostics/SKILL.md
curl -fsSL "$raw/cmux-diagnostics/scripts/cmux-diagnostics" -o cmux-diagnostics/scripts/cmux-diagnostics

# --- cmux-browser (has templates) ---
mkdir -p cmux-browser/references cmux-browser/templates
curl -fsSL "$raw/cmux-browser/SKILL.md"                          -o cmux-browser/SKILL.md
curl -fsSL "$raw/cmux-browser/references/authentication.md"      -o cmux-browser/references/authentication.md
curl -fsSL "$raw/cmux-browser/references/commands.md"            -o cmux-browser/references/commands.md
curl -fsSL "$raw/cmux-browser/references/proxy-support.md"       -o cmux-browser/references/proxy-support.md
curl -fsSL "$raw/cmux-browser/references/session-management.md"  -o cmux-browser/references/session-management.md
curl -fsSL "$raw/cmux-browser/references/snapshot-refs.md"       -o cmux-browser/references/snapshot-refs.md
curl -fsSL "$raw/cmux-browser/references/video-recording.md"     -o cmux-browser/references/video-recording.md
curl -fsSL "$raw/cmux-browser/templates/authenticated-session.sh" -o cmux-browser/templates/authenticated-session.sh
curl -fsSL "$raw/cmux-browser/templates/capture-workflow.sh"     -o cmux-browser/templates/capture-workflow.sh
curl -fsSL "$raw/cmux-browser/templates/form-automation.sh"      -o cmux-browser/templates/form-automation.sh

# make scripts/templates executable
chmod +x cmux-settings/scripts/cmux-settings cmux-diagnostics/scripts/cmux-diagnostics cmux-browser/templates/*.sh
```

Did this on Mon 2026-07-13 - :crossed_fingers: they don't change often.

# Settings Locations

| File | Holds |
|---|---|
| `~/.config/cmux/cmux.json` | Main cmux settings |
| `~/.config/cmux/dock.json` | Dock (right-sidebar) terminal/browser controls |
| `~/.config/cmux/sidebars/*.swift` | Custom SwiftUI sidebars (beta) |

Also: `~/.config/ghostty/config` — terminal rendering, symlinked from
`cmux/dot-config/ghostty/config` by `fling`.

```ini
# Copy terminal selections to the clipboard automatically.
copy-on-select = true
```

```bash
cmux settings path        # print the active cmux.json path
cmux docs settings        # docs URL, schema, cmux.json locations, reload cmd
cmux reload-config        # reload cmux.json + Ghostty config live (no restart)
```

`~/Library/Preferences/com.cmuxterm.app.plist`

```bash
defaults read com.cmuxterm.app                                          # dump all keys
defaults read com.cmuxterm.app appearanceMode                          # read one key
defaults write com.cmuxterm.app globalFontMagnificationPercent -int 130 # set UI zoom to 130%
defaults write com.cmuxterm.app browserOpenTerminalLinksInCmuxBrowser -bool false
defaults write com.cmuxterm.app browserInterceptTerminalOpenCommandInCmuxBrowser -bool false
```

And restart cmux



# Settings tweaks

- Set zoom to 130% in preferences (total UI zoom)
- Unset Cmd + Shift + F (directory search) since rectangle uses it for fullscreen
- Using dark theme
