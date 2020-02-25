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

- Install [vim-plug](https://github.com/junegunn/vim-plug).

```
:InstallVimPlug
```

- Restart editor

- Install Plugins

```
:PlugInstall
```

## Install IDE components

I'd like to have the following functionality:

- ncm2 replacement without the bugs ( auto-complete from buffer, filesystem )
- run flake8 and black on Python code
- run shellcheck on bash code

But I need to figure out an easy way to install Python first... (probably using conda with an Install function to create an env)

## Vim QuickInstall

Just the basic `~/.vimrc`- no plugins or anything. Useful for servers

```
curl https://raw.githubusercontent.com/bbkane/nvim/master/init.vim > ~/.vimrc
```

[Vim-commentary](https://github.com/tpope/vim-commentary) is one plugin I feel like I can't do without. Manually install it with:

```
curl --create-dirs -fLo ~/.vim/plugin/commentary.vim https://raw.githubusercontent.com/tpope/vim-commentary/master/plugin/commentary.vim
```

