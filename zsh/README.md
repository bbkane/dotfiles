# Ben's Zsh Customizations and Plugins!!!

# Design goals

- Don't change how the shell works too much! I `ssh` into other machines installed with `bash`, and it's essential that I don't need to context switch too hard when I do. This config tries to accomplish this by:
  - using `zsh` (fairly `bash` compatible)
  - focusing on making common shell operations easier and faster, not replacing them wholesale. Think "turn the shell prompt into an IDE" - code should be faster to write, but it should look the same as if you didn't have the IDE
- Make my customizations easy to install, easy to play with, and easy to uninstall. This should be easy to "try out". This config tries to accomplish this by:
  - not replacing `~/.zshrc` but instead providing `source <file>` lines to add to it - this lets users keep their own configuration and toggling mine on and off by commenting a line or two
  - putting different functionality in different files to source. Want only one of `zp_prompt` and `zshrc_common`? `source` one but not the other
  - adding `curl` install commands (I actually use `fling` to provide these files so I can easily keep them in Git)
  - noting keyboard shortcuts the tools add I really like in this README and adding screenshots

## Installation notes

It's possible to install my settings with `curl` using commands similar to the following:

```bash
curl -Lo ~/.zshrc_common.zsh https://raw.githubusercontent.com/bbkane/dotfiles/master/zsh/.zshrc_common.zsh
```

However, I install my dotfiles via cloning this repo and using [`fling`](https://github.com/bbkane/fling/) to create symlinks to the appropriate places.

Like a river, Installation instructions for plugins tend to wend slowly over time, so I'm trying to add "last updated" sections to each header here.

Also note that these should be installed in order... in particular, completions need to be added to `fpath`  BEFORE calling `compinit` and `fzf-tab` needs to be loaded AFTER `compinit`.

## Random Notes

see [./README_notes.md](./README_notes.md)

# Add autoloads

I'm trying to put all `autoload -Uz <thing>` at the top of `~/.zshrc` to keep them together and reduce startup times. As of 2024-06-02, so far I have:

```zsh
autoload -Uz add-zsh-hook # zp_prompt , envelope
autoload -Uz bashcompinit  # completions
autoload -Uz compinit  # completions
autoload -Uz edit-command-line  # common settings
```

https://unix.stackexchange.com/a/33898/185953 has a great explanation of what the `-Uz` flags

> "What is the -Uz about?", you ask? Well, that's just a set of options that will cause `autoload' to do the right thing, no matter what options are being set otherwise. The `U' disables alias expansion while the function is being loaded and the `z' forces zsh-style autoloading even if `KSH_AUTOLOAD' is set for whatever reason.

# Get zsh completions working

## Install [zsh-completions](https://github.com/zsh-users/zsh-completions)

> last updated: Fri 2024-10-11

NOTE: this can add startup time, so inspect this if that slows down (see [./README_notes.md](./README_notes.md)).

This particularly helps with `openssl` completion.

```
brew install zsh-completions
```

Add the following to `~/.zshrc`:

```bash
# zsh-completions
FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
```

If getting an `zsh compinit: insecure directories` warning, see the output of `brew info zsh-completions`.

## Add zsh function files to `$FPATH` in `~/.zshrc`

```zsh
# Add Homebrew completions not from zsh-completions
FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
# Add spot to put local completions
FPATH="$HOME/fbin:$FPATH"
```

## Run `compinit` to build completions

This needs to be done AFTER all modifications to `$FPATH`, but before some of the plugins below.

See https://stackoverflow.com/a/67161186/2958070 for more details

```bash
compinit
bashcompinit
```

## `zsh` Completions `~/.zshrc` summary

At the end, this part of `~/.zshrc` should look like this:

```zsh
# zsh-completions
FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
# Add Homebrew completions not from zsh-completions
FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
# Add spot to put local completions
FPATH="$HOME/fbin:$FPATH"

compinit
bashcompinit
```

# Install [Common Settings](./.zshrc_common.zsh)

Install into `~/.zshrc_common.zsh`, then use the following command to source it from `~/.zshrc`.

Requires `autoload -Uz add-zsh-hook` (see above)

```bash
# See https://github.com/bbkane/dotfiles
source ~/.zshrc_common.zsh
```

Open a new `zsh` shell.

# Install [`zp_prompt`](./dot-zshrc_prompt.zsh)

![](./README_img/zp_prompt.png)

Requires `autoload -Uz add-zsh-hook`, see above.

Install into `~/.zshrc_prompt.zsh`, then use the following command to source it from `~/.zshrc`

```bash
brew install pastel  # Optional but highly recommended
```

```bash
# See https://github.com/bbkane/dotfiles
source ~/.zshrc_prompt.zsh
zp_prompt_pastel dodgerblue lightgreen
```

Open a new `zsh` shell.

# Install [fzf](https://github.com/junegunn/fzf)

> Last updated: 2024-04-02

- Search through shell history interactively (`<Ctrl>r`)
- Search through file names (`<Ctrl>t`). Example: `cat <Ctrl>t`
- Search through file names (`**<Tab>`). Example `cat ./project/**<Tab>`
- Adds autocomplete with `<Tab>` to `kill`
- SSH with completion from `/etc/hosts` and `~/.ssh/config` with `ssh **<Tab>`
- `unset`, `export`, and `unalias` with completion with `unset **<Tab>`

![History search](./README_img/fzf.png)

```bash
brew install fzf
```

Add the following to `~/.zshrc`:

```bash
eval "$(fzf --zsh)"
```

# Install [fzf-tab](https://github.com/Aloxaf/fzf-tab)

> Last updated: 2024-04-02

Add fuzzy completion to tab-complete. Very useful when there's a bunch of similarly named things in a directory (like ticket notes).

![fzf-tab](./README_img/fzf-tab.png)

Warning from the README:

> 1. make sure [fzf](https://github.com/junegunn/fzf)  is installed
> 2. fzf-tab needs to be loaded after `compinit`, but before plugins which will wrap widgets, such as [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) or [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)

```bash
git clone https://github.com/Aloxaf/fzf-tab ~/Git-GH/fzf-tab
```

Add to zshrc:

```bash
# https://github.com/Aloxaf/fzf-tab
# NOTE: fzf-tab should be installed before most other things. See the README
source ~/Git-GH/fzf-tab/fzf-tab.plugin.zsh

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
```

Install `eza` for directory previews:

```bash
brew install eza
```

NOTE: the README suggests using `build-ff-tab-module` to speed up colorizing files, but the build failed for me and I'm not currently having a speed problem

# Install [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)

> Last updated: 2024-04-02

Add auto-complete based on history. Accept suggestions with `<Ctrl><Space>` or right arrow key.

![](./README_img/zsh-autosuggestions.png)

```bash
brew install zsh-autosuggestions
```

I used [HTML Color Picker: #c0c0c0](https://imagecolorpicker.com/color-code/c0c0c0) to get the highlight color.

```bash
# NOTE: this source location might change if brew changes how it installs
# See `brew info zsh-autosuggestions`
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept  # also use Ctrl+Space to accept
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#737373'
```

Open a new `zsh` shell.

# Install [`zoxide`](https://github.com/ajeetdsouza/zoxide)

> Last updated: 2024-04-02

`zoxide` is a replacement for `fasd`, which has been deprecated in Homebrew :(

It has some differences:

- doesn't support frecently used files with `v`
- **requires** a space after z to trigger fancy autocompletion: `z startofname<SPACE><TAB>`
- It does let you edit the database.

I think my favorite use is `zi` to open a fzf picker for frecently used files.

```bash
brew install zoxide
```

Also see notes about `compinit` in the [README](https://github.com/ajeetdsouza/zoxide).

```bash
eval "$(zoxide init zsh)"
```

# Install [`fast-syntax-highlighting`](https://github.com/z-shell/F-Sy-H)

> Last updated: 2024-04-02

Add syntax highglighting while typing

![](./README_img/fast-syntax-highlighting.png)

I clone into `~/Git-GH`. Change this name if you want to clone somewhere else!

```bash
git clone https://github.com/z-shell/F-Sy-H ~/Git-GH/F-Sy-H
```

```bash
source ~/Git-GH/F-Sy-H/F-Sy-H.plugin.zsh
```

Open a new `zsh` shell.

# Install [warhol.plugin.zsh](https://github.com/unixorn/warhol.plugin.zsh)

> Last updated: 2024-04-02

Colorize command output using grc and lscolors

![](./README_img/warhol.plugin.zsh.png)

```bash
brew install grc
```

```bash
git clone https://github.com/unixorn/warhol.plugin.zsh.git  ~/Git-GH/warhol.plugin.zsh
```

```bash
# https://github.com/unixorn/warhol.plugin.zsh
source ~/Git-GH/warhol.plugin.zsh/warhol.plugin.zsh
```

