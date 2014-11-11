## Ben's great backup!!

The configs for all of my dotfiles (and a few other config files) are
here. Use with *gnu stow*. I'm using gnu stow in a folder named
**backup**. **backup** has directories like *mac*, *tower*, and
*common*. Clone backup into my home folder, then enter it, and use the
command `stow <folder name>` to make symlinks to everything in the
*parent of the current directory*- in this case `$HOME`. To specify a
target, for the symlinks, use `stow <folder name> -t <destination for
symlinks`. 
