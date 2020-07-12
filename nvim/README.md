# nvim
My Neovim Config. Also works for Vim.

## NeoVim Install

- Back up old config

```
mv "$HOME/.config/nvim" "$HOME/.config/nvim.$(date +%Y-%m-%d)"
```

- Stow the repository

```
mkdir -p "$HOME/.config"
./stow.sh nvim
```

NOTE: I can't rename `.config` to `dot-config` because of https://github.com/aspiers/stow/issues/33 Hopefully that'll be fixed at some point

## Vim Install

- Backup ~/.vimrc and ~/.vim/

```
mv ~/.vimrc ~/.vimrc.$(date +%Y-%m-%d)
mv ~/.vim ~/.vim.$(date +%Y-%m-%d)
```

- Create symlinks

```
ln -s ~/.config/nvim/init.vim ~/.vimrc
ln -s ~/.config/nvim/ ~/.vim
```

## Install Plugins (from editor)

- Install [vim-plug](https://github.com/junegunn/vim-plug): `:InstallVimPlug`
- Restart editor
- Install Plugins: `:PlugInstall`

## Install linters for Ale

Alternative installation options for Python deps: nvim venv , pipx. nvim venv doesn't expose tools to anything else. pipx (ironically) doesn't have a clean installation method (`python3 -m pip install --user pipx` installs other dependencies (could use homebrew to install it, but...)). Homebrew only works on mac and doesn't have formulas for everything (and some it does have are out of date)

```
brew install black flake8 mypy shellcheck
```

Links:

- https://github.com/dense-analysis/ale/blob/master/doc/ale-python.txt#L160
- https://code.visualstudio.com/docs/python/linting#_specific-linters
- https://docs.brew.sh/Python-for-Formula-Authors

## Vim QuickInstall

Just the basic `~/.vimrc`- no plugins or anything. Useful for servers

```
curl https://raw.githubusercontent.com/bbkane/nvim/master/init.vim > ~/.vimrc
```

[Vim-commentary](https://github.com/tpope/vim-commentary) is one plugin I feel like I can't do without. Manually install it with:

```
curl --create-dirs -fLo ~/.vim/plugin/commentary.vim https://raw.githubusercontent.com/tpope/vim-commentary/master/plugin/commentary.vim
```

## Notes

TODO: move this to blog?

In normal mode: `q:`, `q/`, `q?` open up command and search history in a nice little popup window

## Language Server

### Experimental!!

From: https://github.com/neovim/nvim-lsp#pyls_ms

did the curl script. It put it in ~/.dotnet. Added that to the PATH

```
:LspInstall pyls_ms
```

https://github.com/neovim/nvim-lsp/issues/35#issuecomment-555614914
