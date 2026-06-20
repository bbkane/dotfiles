Homebrew installs grabbit as a cask, so the old `brew services start grabbit` flow does not apply.

2026-06-20 - TODO: test this on Mac

# Install

Make sure you know your `grabbit` binary path:

```bash
which grabbit
```

Symlink the launchd plist file:

```bash
fling link -s grabbit-launchctl
```

Load and enable the agent:

```bash
launchctl unload ~/Library/LaunchAgents/com.bbkane.grabbit.plist || true
launchctl load -w ~/Library/LaunchAgents/com.bbkane.grabbit.plist
launchctl list | grep com.bbkane.grabbit
```

This runs at login and every Monday at 10:00.

# Debug

Lint the plist:

```bash
plutil -lint ~/Library/LaunchAgents/com.bbkane.grabbit.plist
```

Check current job state:

```bash
launchctl print gui/$(id -u)/com.bbkane.grabbit
```

Run immediately for testing:

```bash
launchctl kickstart -k gui/$(id -u)/com.bbkane.grabbit
```

Inspect logs:

```bash
tail -n 200 /tmp/com.bbkane.grabbit.stdout.log
tail -n 200 /tmp/com.bbkane.grabbit.stderr.log
```

# Links

- https://www.launchd.info/
- https://github.com/zerowidth/launched
- https://www.peterborgapps.com/lingon/
