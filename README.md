## Ben's great backup!!

The configs for all of my dotfiles (and a few other config files) are
here. Use with *gnu stow*. I'm using gnu stow in a folder named
**backup**. **backup** has directories like *mac*, *tower*, and
*common*. Clone backup into my home folder, then enter it, and use the
command `stow <folder name>` to make symlinks to everything in the
*parent of the current directory*- in this case `$HOME`. To specify a
target, for the symlinks, use `stow <folder name> -t <destination>` for
symlinks. 

To add the submodules to the common/.janus folder:
If you already cloned the repo, it's:
```
cd common/.janus
git submodule update --init --recursive
```
Otherwise, follow the below instructions


So, if I reset everything on my tower, the steps would be:

Get the prereqs- oh-my-zsh and janus for vim

```
# GNU stow makes this work well
sudo apt-get install stow

# this is untested, but should clone submodules
git clone --recursive <web address>

# cd into the right folder for stow to work properly
cd backup

# get all my cross-platform customizations out of the way
stow common

# get my tower stuff done
stow tower

# symlink monitor.sh into /usr/local/bin
# remember not to depend on shell expansion
ln -s $HOME/backup/other/monitor.sh /usr/local/bin/monitor.sh

```

## TODO

1. Figure out a good way to save files to my path (most notably
   monitor.sh to /usr/local/bin for my tower).
2. make bootstrap scripts that will do all this for me (maybe in a
   backup/setup/ folder).
