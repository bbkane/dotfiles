# git

My Git setup is somewhat complicated, but the gist of it is:

`~/.gitconfig` loads common settings

`~/.gitconfig` uses `includeIf` with directories to override / load more git configuration if I'm in that directory and the configuration exists. Some of the files referenced in the `includeIf` exist in my work dotfiles repo, not this one. 

When I'm on my personal laptop, those files don't exist and my work config (things like`user.email = ben@work.com` ) isn't loaded. When I'm on my work laptop, those files DO exist and the git config is set up for work in those directories.

My git config requires `git-credential-manager`, `git-delta` and `neovim`:

```bash
brew install git-credential-manager git-delta neovim
```
Symlink these files from the dotfiles repo root:

```bash
fling link -s ./git
```
