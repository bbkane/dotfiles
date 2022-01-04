# Dotfiles

TODO: change links curl files :)

Store configuration for common apps.

Use [`fling`](https://github.com/bbkane/fling/) to manage most app configs.

## Install/Uninstall a config

### Apps that cannot be installed with stow.sh

- vscode has an install script in the subfolder

### Install/Symlink

```
fling --ignore 'README.*' --src-dir <dirname> link
```

flign will prompt before symlinking

### Uninstall/Unlink

```
fling --ignore 'README.*' --src-dir <dirname> unlink
```

flign will prompt before unlinking

## Add a stowable config to the repo

- make a directory with the name of an app
- mirror app config's file structure from `~` into `./<app>/`, replacing leading `.` with `dot-`. For example, if your app's config is stored at `~/.myapp/config`, then make `./dot-myapp/config`

# Notes

Why store config per app rather than per platform?

- I can easily see which apps have configs stored in this repo
- I want to target which configs are deployed
- Most of my work is on Mac, not the various Linux distros I used to play with

---

The `cat` commands need to quote `'EOF'` to not expand variables. See
https://stackoverflow.com/a/27921346/2958070

---

# TODO

- Maybe get a better git prompt and tmux conf from https://github.com/mathiasbynens/dotfiles
- zsh compinstall
- zsh fasd
- zsh typeahead - in ~/.zshrc for now
