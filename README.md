# Dotfiles

Store configuration for common apps.

Use `stow` to manage most app configs. See [`./stow.sh`](./stow.sh).

## Add a config to the repo

- make a directory with the name of an app
- mirror app config's file structure from `~` into `./<app>/`, replacing leading `.` with `dot-`. For example, if your app's config is stored at `~/.myapp/config`, then make `./dot-myapp/config`
- run `./stow.sh <app>` then the app and make sure it picks up the config
- Add info about app in '# Apps' section below

## Install/Uninstall a config

Unless otherwise noted, all configs can be symlinked with:

```
./stow.sh <dir>
```

This script will do a dry-run and prompt before symlinking

Uninstall with:

```
./stow.sh -D <dir>
```

# Apps

## bash

This only has my bash prompt. I've moved most of the important things into zsh. I might make a `bash_zsh` folder if I find myself needing both again.

```
cat >> "$HOME/.bashrc" << 'EOF'

# See https://github.com/bbkane/dotfiles
source ~/.bashrc_common.zsh
EOF
```

## bin_common

Don't version control `~/bin` - instead use that for local executables.
Stow `~/bin_common` and add it to the `$PATH`

Assumes `zsh` is the current shell

```
cat >> "$HOME/.zshrc" << 'EOF'

# See https://github.com/bbkane/dotfiles
export PATH="$HOME/bin_common:$PATH"
EOF
```

## git

Add `~/.gitconfig.local` to override any settings in this common one.
`~/.gitconfig.personal` ensures that all repos in `~/Git-personal` use my my
personal email.

## nvim/vim

See my [repo](https://github.com/bbkane/nvim)

## sqlite3

Alternatively, check out [`litecli`](https://github.com/dbcli/litecli)

## tmux

TODO: audit these settings

## VS Code

VS Code has different settings locations per platform, so use the following
script. Unfortunately, there's no way to specify platform specific settings,
so consider copy-pasting settings instead of symlinking.

```
cd vscode/
python3 install_vs_code_settings.py
```

## zsh

don't version control `~.zshrc` - use that for local settings.
Instead version control `~/.zshrc_common.zsh` and source that from `~.zshrc`

```
cat >> "$HOME/.zshrc" << 'EOF'

# See https://github.com/bbkane/dotfiles
source ~/.zshrc_common.zsh
source ~/.zshrc_prompt.zsh
EOF
```

# Notes

Why store config per app rather than per platform?

- I can easily see which apps have configs stored in this repo
- I want to target which configs are deployed
- Most of my work is on Mac, not the various Linux distros I used to play with

---

The `cat` commands need to quote `'EOF'` to not expand variables. See
https://stackoverflow.com/a/27921346/2958070

---

Maybe get a better git prompt and tmux conf from https://github.com/mathiasbynens/dotfiles
