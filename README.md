# Dotfiles

My personal dotfiles! I use [`fling`](https://github.com/bbkane/fling/) to manage most app configs.

## Install/Symlink

```bash
fling --ignore 'README.*' --src-dir <dirname> link
```

fling will prompt before symlinking

## Uninstall/Unlink

```bash
fling --ignore 'README.*' --src-dir <dirname> unlink
```

fling will prompt before unlinking

## Apps that cannot be installed with fling

- vscode has an install script in the subfolder

## Add a flingable config to the repo

- make a directory with the name of an app
- mirror app config's file structure from `~` into `./<app>/`, replacing leading `.` with `dot-`. For example, if your app's config is stored at `~/.myapp/config`, then make `./dot-myapp/config`

# Notes

Why store config per app rather than per platform?

- I can easily see which apps have configs stored in this repo
- I want to target which configs are deployed
- Most of my work is on Mac, not the various Linux distros I used to play with

---

The `cat` commands need to quote `'EOF'` to not expand variables. See
https://stackoverflow.com/a/27921346/2958070

---

Use https://levelup.gitconnected.com/how-to-update-fork-repo-from-original-repo-b853387dd471 to fork this repo, add features, make PRs, and keep it all synced.

Basically, fork, clone locally, and:

```bash
# add original repo to git config
$ git remote add upstream https://github.com/bbkane/dotfiles.git
$ git pull upstream master
$ git push origin <branch_name>
```
