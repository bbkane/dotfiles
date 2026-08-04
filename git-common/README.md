# Git common configuration

This package contains settings shared by personal and work machines. Link it
together with exactly one machine profile, which owns `~/.gitconfig`.

See [Learn Git | Ben's Corner](https://www.bbkane.com/blog/learn-git/#move-a-git-tag)
for notes on using Git.

## Install shared tools

The common configuration requires `git-delta` for paging and `neovim` for the
`git vimdiff` alias.


```bash
brew install git-delta neovim
```

The legacy `git` package targets some of the same paths. Unlink it before
linking `git-common` and a machine profile.

## Per-repo setup

A couple of settings are global but only take full effect once enabled per
repository:

- **Background maintenance.** `maintenance.auto = false` only disables ad-hoc
  auto-runs. To schedule background commit-graph, garbage collection, and prune
  operations, run this in each repository that should use them:

  ```bash
  git maintenance start
  ```

- **fsmonitor.** `core.fsmonitor = true` uses Git's built-in fsmonitor daemon
  on Git 2.54 and newer. A `git-fsmonitor--daemon` process starts for a
  repository on its first `git status`.

## Architecture

The selected machine profile owns `~/.gitconfig` and includes the shared
`~/.config/gitconfig_common`. Machine- or environment-specific packages can
add identities, credential helpers, and conditional includes without putting
those details in this package.

Inspect the effective configuration with:

```bash
git config --show-origin --get-regexp '^(user|credential|url)\.'
```
