# nvim
My Neovim Config. Should also work for Vim, but no promises :)

## Install

- Back up old config

```
mv ~/.config/nvim ~/.config/nvim.$(date +%Y-%m-%d)
```

- Clone the repository

```
git clone https://github.com/bbkane/nvim.git ~/.config/nvim
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
ln -s ~/.config/nvim/ ~/.vim/
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
