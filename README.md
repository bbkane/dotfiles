# nvim
My Neovim Config. Should also work for Vim, but no promises :)

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

- [Neomake](https://github.com/neomake/neomake)/[Syntastic](https://github.com/scrooloose/syntastic)

Python3: Install [flake8](http://flake8.pycqa.org/en/latest/).

```
python3 -m pip install flake8
```

Others: refer to each project.

- [YouCompleteMe](https://github.com/Valloric/YouCompleteMe/issues)

Install on your own. To see what I've done, look at [ide.vim](ide.vim).

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

