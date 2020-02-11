# Dotfiles

##  What I want

I need to redo my backup directory to store dotfiles

Store by application:
- zsh (currently .zshrc_common, not in vcs)
- git (common/.gitconfig)
- sqlite (common/sqliterc)
- bin ( common/bin/scatterplot.py, reply_to_recruiters.py, move log_wake to random-scripts )
-  timux (common/.tmux.conf)

Use gnu stow (with -t arg?)

Prune https://github.com/bbkane/backup

# what I want from backup

## zsh

don't version control .zshrc - instead use that for local settings
Instead version control `~/.zshrc_common` and source that from .zshrc

## bin

Don't version control ~/bin - instead use that for local executables
instead add ~/bin_common and add it to $PATH

## helper

https://writingco.de/blog/how-i-manage-my-dotfiles-using-gnu-stow/
```
# run the stow command for the passed in directory ($2) in location $1
stowit() {
    usr=$1
    app=$2
    # -v verbose
    # -R recursive
    # -t target
    stow -v -R -t ${usr} ${app}
}
```

```
       -d DIR
       --dir=DIR
           Set the stow directory to "DIR" instead of the current
           directory.  This also has the effect of making the default
           target directory be the parent of "DIR".

       -t DIR
       --target=DIR
           Set the target directory to "DIR" instead of the parent of the
           stow directory.
       --dotfiles
           Enable special handling for "dotfiles" (files or folders whose
           name begins with a period) in the package directory. If this
           option is enabled, Stow will add a preprocessing step for each
           file or folder whose name begins with "dot-", and replace the
           "dot-" prefix in the name by a period (.). This is useful when
           Stow is used to manage collections of dotfiles, to avoid having
           a package directory full of hidden files.

           For example, suppose we have a package containing two files,
           stow/dot-bashrc and stow/dot-emacs.d/init.el. With this option,
           Stow will create symlinks from .bashrc to stow/dot-bashrc and
           from .emacs.d/init.el to stow/dot-emacs.d/init.el. Any other
           files, whose name does not begin with "dot-", will be processed
           as usual.
       -v
       --verbose[=N]
           Send verbose output to standard error describing what Stow is
           doing. Verbosity levels are from 0 to 5; 0 is the default.
           Using "-v" or "--verbose" increases the verbosity by one; using
        -n
       --no
           Do not perform any operations that modify the filesystem;
           merely show what would happen.          `--verbose=N' sets it to N.
```

This worked: `$ stow -n --dotfiles -vvv -t $HOME sqlite3`

It doesn't show the changing directories but it works

TODO: mv zsh stuff to this, update README, make stow script

## Stuff I might want on mac later

```
# brew tap caskroom/fonts
# brew cask install font-source-code-pro
# openemu is a one shop stop emulator frontend for SNES, GBA, etc
#brew cask install openemu
```
