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

## Architecture

My Git setup is somewhat complicated, but the gist of it is:

`~/.gitconfig` loads common settings

`~/.gitconfig` uses `includeIf` with directories to override / load more git configuration if I'm in that directory and the configuration exists. Some of the files referenced in the `includeIf` exist in my work dotfiles repo, not this one. 

When I'm on my personal laptop, those files don't exist and my work config (things like`user.email = ben@work.com` ) isn't loaded. When I'm on my work laptop, those files DO exist and the git config is set up for work in those directories.

