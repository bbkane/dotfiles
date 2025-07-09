Homebrew creates a service file, but not a `systemd` timer to run grabbit weekly.

# Install

Start the service, from homebrew, which just creates the service file

```bash
brew services start grabbit
```

Symlink the timer file:

```bash
fling link -s grabbit-systemd
```

Start and enable the timer:

```bash
systemctl --user start homebrew.grabbit.timer
systemctl --user enable homebrew.grabbit.timer
```

# Debug

Analyze service/timer for errors:

```bash
systemd-analyze --user verify homebrew.grabbit.time
```

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

Check the time format:

```bash
$ systemd-analyze calendar Weekly
  Original form: Weekly
Normalized form: Mon *-*-* 00:00:00
    Next elapse: Mon 2025-03-17 00:00:00 PDT
       (in UTC): Mon 2025-03-17 07:00:00 UTC
       From now: 7h left
```

# Links

- https://wiki.archlinux.org/title/Systemd/Timers
- https://documentation.suse.com/smart/systems-management/html/systemd-working-with-timers/index.html

