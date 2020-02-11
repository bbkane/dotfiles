# Dotfiles

Store configuration for common apps.

Use `stow` to manage most app configs. See [`./stow.sh`](./stow.sh).

Why store config per app rather than per platform?

- I can easily see which apps have configs stored in this repo
- I want to target which configs are deployed
- Most of my work is on Mac, not the various Linux distros I used to play with

To add a config:

- make a directory with the name of an app
- mirror app config's file structure from `~` into `./<app>/`, replacing leading `.` with `dot-`. For example, if your app's config is stored at `~/.myapp/config`, then make `./dot-myapp/config`
- run `./stow.sh <app>` then the app and make sure it picks up the config
- Add info about app in '# Apps' section below

# Apps


## bash

This only has my bash prompt. I've moved most of the important things into zsh. I might make a `bash_zsh` folder if I find myself needing both again.

```
./stow.sh bash
```

```
cat >> "$HOME/.bashrc" << EOF

# See https://github.com/bbkane/dotfiles
source ~/.bashrc_common.zsh
EOF
```

## bin_common

Don't version control `~/bin` - instead use that for local executables.
Stow `~/bin_common` and add it to the `$PATH`

```
./stow.sh bin_common
```

Assumes `zsh` is the current sell

```
cat >> "$HOME/.zshrc" << EOF

# See https://github.com/bbkane/dotfiles
export PATH="$HOME/bin_common:$PATH"
EOF
```

## git

Add `~/.gitconfig.local` to override any settings in this common one

```
./stow.sh git
```

## nvim/vim

See my [repo](https://github.com/bbkane/nvim)

## sqlite3

Alternatively, check out [`litecli`](https://github.com/dbcli/litecli)

```
./stow.sh sqlite3
```

## tmux

TODO: audit these settings

```
./stow.sh tmux
```

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
./stow.sh zsh
```

```
cat >> "$HOME/.zshrc" << EOF

# See https://github.com/bbkane/dotfiles
source ~/.zshrc_common.zsh
EOF
```

