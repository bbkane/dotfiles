# cmux

# Install

Install: https://cmux.com/docs/getting-started

```bash
brew tap manaflow-ai/cmux
brew install --cask cmux

# From the dotfiles repository root. Ignore cmux documentation files.
fling link -s cmux
```

# Copilot CLI notifications

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

Open Issues:


- [notification for copilot cli agent · Issue #2523 · manaflow-ai/cmux](https://github.com/manaflow-ai/cmux/issues/2523)
  - [Feature Request: Add awaitingUserInput hook type · Issue #1128 · github/copilot-cli](https://github.com/github/copilot-cli/issues/1128)
    - These track native support for notifying specifically when Copilot needs user input.
- [[copilot] PreToolUse feed hook hangs for 120s and never gates tool execution · Issue #6574 · manaflow-ai/cmux](https://github.com/manaflow-ai/cmux/issues/6574)
  - Avoid the affected feed-hook path if hook execution stalls.
- [cmux hooks copilot install: hooks get wiped by Copilot CLI on next session start · Issue #4374 · manaflow-ai/cmux](https://github.com/manaflow-ai/cmux/issues/4374)
  - The manual `settings.json` integration above avoids this installer issue.

All four issues were still open on 2026-08-05.

# Continue running CMUX/Copilot when screen is locked

1. Plug in the MacBook and keep the lid open.
2. Activate KeepingYouAwake from the menu bar.
3. Enable **Allow display sleep** in KeepingYouAwake so the locked display can turn off while the system remains awake.
4. Press `Control-Command-Q` to lock the screen. Do not put the Mac to sleep.

Locking the screen does not stop cmux, Copilot CLI, or their network activity. KeepingYouAwake prevents idle system sleep; VPNs and remote services may still enforce their own session timeouts.

To confirm the sleep-prevention assertion is active:

```bash
pmset -g assertions
```

Look for `PreventUserIdleSystemSleep` owned by [KeepingYouAwake](https://formulae.brew.sh/cask/keepingyouawake#default) or `caffeinate`.

# Copilot CLI skills

The reviewed CMUX skills and their install instructions live in the
[agents package](../agents/README.md#cmux-skills).

# Settings Locations

| File | Holds |
|---|---|
| `~/.config/cmux/cmux.json` | Main cmux settings |
| `~/.config/cmux/dock.json` | Dock (right-sidebar) terminal/browser controls |
| `~/.config/cmux/sidebars/*.swift` | Custom SwiftUI sidebars (beta) |

Also: `~/.config/ghostty/config` — terminal rendering, symlinked from
`cmux/dot-config/ghostty/config` by `fling`.

```bash
cmux settings path        # print the active cmux.json path
cmux docs settings        # docs URL, schema, cmux.json locations, reload cmd
cmux reload-config        # reload cmux.json + Ghostty config live (no restart)
```

`shortcuts.bindings.findInDirectory` and `shortcuts.bindings.globalSearch` have empty key definitions, disabling both shortcuts so they do not conflict [Rectangle](https://formulae.brew.sh/cask/rectangle) shortcuts

# macOS UI preferences

Some settings changed through the cmux UI are stored in
`~/Library/Preferences/com.cmuxterm.app.plist` instead of `cmux.json`. These
commands reproduce the current values:

```bash
defaults write com.cmuxterm.app appearanceMode -string dark
defaults write com.cmuxterm.app globalFontMagnificationPercent -int 130
defaults write com.cmuxterm.app browserOpenTerminalLinksInCmuxBrowser -bool false
defaults write com.cmuxterm.app browserInterceptTerminalOpenCommandInCmuxBrowser -bool false
```

Read them back with:

```bash
defaults read com.cmuxterm.app # dump all keys
defaults read com.cmuxterm.app appearanceMode
defaults read com.cmuxterm.app globalFontMagnificationPercent
defaults read com.cmuxterm.app browserOpenTerminalLinksInCmuxBrowser
defaults read com.cmuxterm.app browserInterceptTerminalOpenCommandInCmuxBrowser
```

Restart cmux after changing plist-backed UI preferences.

`~/Library/Preferences/com.cmuxterm.app.plist`
