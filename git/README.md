# git

See [Learn Git | Ben's Corner](https://www.bbkane.com/blog/learn-git/#move-a-git-tag) for notes on using git.

## Install

My git config requires `git-credential-manager`, `git-delta` and `neovim`:

```bash
brew install git-delta neovim
```

Install [Git Credential Manager](https://github.com/git-ecosystem/git-credential-manager/tree/release):

MacOS:

```bash
brew install --cask git-credential-manager
```

Debian: follow [this](https://github.com/git-ecosystem/git-credential-manager/blob/release/docs/install.md#debian-package).
Ensure `/usr/local/bin` is in the `PATH`:

```bash
# dpkg puts git-credential-manager here
export PATH="$PATH:/usr/local/bin"
```

Symlink these files from the dotfiles repo root:

```bash
fling link -s ./git
```

## Per-repo setup

A couple of settings are global but only take full effect once enabled per-repo:

- **Background maintenance.** `maintenance.auto = false` only disables ad-hoc
  auto-runs. To get scheduled background optimization (commit-graph, gc, prune),
  run `git maintenance start` inside each repo you care about (e.g. large
  checkouts). It is not global.

  ```bash
  git maintenance start
  ```

- **fsmonitor.** `core.fsmonitor = true` uses Git's built-in fsmonitor daemon
  (no Watchman needed on Git 2.54+). It spins up a `git-fsmonitor--daemon`
  process per repo on the first `git status` — harmless, just expected.

## Architecture

My Git setup is somewhat complicated, but the gist of it is:

`~/.gitconfig` loads common settings

`~/.gitconfig` uses `includeIf` with directories to override / load more git configuration if I'm in that directory and the configuration exists. Some of the files referenced in the `includeIf` exist in my work dotfiles repo, not this one. 

When I'm on my personal laptop, those files don't exist and my work config (things like`user.email = ben@work.com` ) isn't loaded. When I'm on my work laptop, those files DO exist and the git config is set up for work in those directories.

Debug where stuff is set with commands like:

```bash
git config --show-origin --get-regexp '^credential\.'
```
