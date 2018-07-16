# nvim
My Neovim Config. Should also work for Vim, but no promises :)

TODO: check out https://vimawesome.com/

## Install

- Back up old config

```
mv "$HOME/.config/nvim" "$HOME/.config/nvim.$(date +%Y-%m-%d)"
```

- Clone the repository

```
mkdir -p "$HOME/.config"
git clone https://github.com/bbkane/nvim.git "$HOME/.config/nvim"
```

### Vim Extra Steps

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

## Install Plugins

- Start editor

```
nvim # or `vim`
```

- Install [vim-plug](https://github.com/junegunn/vim-plug).

```
:InstallVimPlug
```

- Restart editor

```
:q
nvim # or `vim`
```

- Install Plugins

```
:PlugInstall
```

## Install IDE components

TODO: update this (I've removed a decent amount of this)

These are needed for nvim-completion-manager and Neomake.

### With Anaconda

Anaconda is the preferred method to install these because they can be easily
uninstalled by deleting the conda environment. See [my blog
post](https://bbkane.github.io/2017/05/17/Reproducible-Python-Environments-with-Conda.html).

```bash
cd ~/.config/nvim
conda env create -f environment-<platform>.yaml
```

### Without Anaconda (system Python)

```bash
/usr/bin/python3 -m pip install --user neovim jedi psutil setproctitle
```

## Windows (Experimental)

- Install Neovim according to the [wiki](https://github.com/neovim/neovim/wiki/Installing-Neovim#windows).
- Clone this repo into `$env:USERPROFILE/.config/nvim`
- Make a symlink from `$env:$USERPROFILE/.config/nvim` to `$env:USERPROFILE\AppData\Local\nvim`. I used a [PowerShell Script](https://learn-powershell.net/2013/07/16/creating-a-symbolic-link-using-powershell/) and the following command, but `mklink` has got to be easier.

```
New-SymLink -Path "C:\Users\Ben\.config\nvim" -Symname C:\Users\Ben\AppData\Local\nvim -Directory -Verbose
```

- Manually save [plug.vim](https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim) to `$env:USERPROFILE/.config/nvim/autoload/plug.vim`. (`:InstallVimPlug` isn't working yet for Windows).

- Install Plugins

```
:PlugInstall
```

## Vim QuickInstall

Just the basic `~/.vimrc`- no plugins or anything

```
curl https://raw.githubusercontent.com/bbkane/nvim/master/init.vim > ~/.vimrc
```

[Vim-commentary]() is one plugin I feel like I can't do without. Manually install it with:

```
mkdir -p ~/.vim/plugin
curl -o ~/.vim/plugin/commentary.vim https://raw.githubusercontent.com/tpope/vim-commentary/master/plugin/commentary.vim
```

TODO: this can all be done in one `curl` command
