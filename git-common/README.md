# Git common configuration

This package contains settings shared by personal and work machines. Personal
machine profiles set the `bbkane` identity globally; work profiles provide
their own identities. Link this package together with exactly one machine
profile, which owns `~/.gitconfig`.

Personal macOS:

```bash
mkdir -p ~/.config
fling -i 'README.*' link -s ./git-common -s ./git-mac-personal
```

Personal Debian with a GUI:

```bash
mkdir -p ~/.config
fling -i 'README.*' link -s ./git-common -s ./git-linux-gui-personal
```

The legacy `git` package and these packages target some of the same paths.
Unlink the legacy package before linking the new packages.

Inspect the effective configuration with:

```bash
git config --show-origin --get-regexp '^(user|credential|url)\.'
```
