Homebrew creates a service file, but not a `systemd` timer to run grabbit weekly.

# Install

Start the service, from homebrew, which just creates the service file

```bash
brew services start grabbit
```

Symlink the timer file:

TODO
Start and enable the timer:

```bash
systemctl --user start homebrew.grabbit.timer
systemctl --user enable homebrew.grabbit.timer
```

# Debug

Check the status of the timer:

```bash
systemctl --user status homebrew.grabbit.timer
```

Check when the timer will run again:

```bash
systemctl --user list-timers
```

See detailed timer configuration

```bash
systemctl --user show homebrew.grabbit.timer
```

See download stdout:

```bash
journalctl --user -u homebrew.grabbit.service
```

# Links

- https://wiki.archlinux.org/title/Systemd/Timers
- TODO: timer article in issues

