# Ben's Zsh Customizations and Plugins!!!

# Design Goals

- Don't change how the shell works too much! I `ssh` into other machines installed with `bash`, and it's essential that I don't need to context switch too hard when I do. This config tries to accomplish this by:
  - using `zsh` (fairly `bash` compatible)
  - focusing on making common shell operations easier and faster, not replacing them wholesale. Think "turn the shell prompt into an IDE" - code should be faster to write, but it should look the same as if you didn't have the IDE
- Make my customizations easy to install, easy to play with, and easy to uninstall. This should be easy to "try out". This config tries to accomplish this by:
  - not replacing `~/.zshrc` but instead providing `source <file>` lines to add to it - this lets users keep their own configuration and toggling mine on and off by commenting a line or two
  - putting different functionality in different files to source. Want only one of `zp_prompt` and `zshrc_common`? `source` one but not the other
  - adding `curl` install commands (I actually use `fling` to provide these files so I can easily keep them in Git)
  - noting keyboard shortcuts the tools add I really like in this README and adding screenshots

## Install via [fling](https://github.com/bbkane/fling/)

NOTE: this is not necessary if you use the `curl` commands provided and most people should use those. I use the `fling` method below to keep all my `zsh` config under version control, and you probably don't care about that.

Clone the repo and `fling`. Most people should use the `curl` install methods instead.

## Notes

see [./README_notes.md](./README_notes.md)

# Install [Common Settings](./.zshrc_common.zsh)

Common functions and settings.

Install via curl:

```bash
curl -Lo ~/.zshrc_common.zsh https://raw.githubusercontent.com/bbkane/dotfiles/master/zsh/.zshrc_common.zsh
```

```bash
cat >> "$HOME/.zshrc" << 'EOF'

# See https://github.com/bbkane/dotfiles
source ~/.zshrc_common.zsh

EOF
```

Open a new `zsh` shell.

# Install [`zp_prompt`](./dot-zshrc_prompt.zsh)

Change prompt colors on the fly!

![](./README_img/zp_prompt.png)

Install via `curl`

```
curl -Lo ~/.zshrc_prompt.zsh https://raw.githubusercontent.com/bbkane/dotfiles/master/zsh/.zshrc_prompt.zsh
```

```
brew install pastel  # Optional but highly recommended
```

```
cat >> "$HOME/.zshrc" << 'EOF'
# See https://github.com/bbkane/dotfiles
source ~/.zshrc_prompt.zsh
zp_prompt_pastel dodgerblue lightgreen

EOF
```

Open a new `zsh` shell.

# Install [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)

Add auto-complete based on history. Accept suggestions with `<Ctrl><Space>` or right arrow key.

![](./README_img/zsh-autosuggestions.png)

```
brew install zsh-autosuggestions
```

I used [HTML Color Picker: #c0c0c0](https://imagecolorpicker.com/color-code/c0c0c0) to get the highlight color.

```
cat >> "$HOME/.zshrc" << 'EOF'
# NOTE: this source location might change if brew changes how it installs
# See `brew info zsh-autosuggestions`
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept  # also use Ctrl+Space to accept
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#737373'

EOF
```

Open a new `zsh` shell.

# Install [fzf](https://github.com/junegunn/fzf)

- Search through shell history interactively (`<Ctrl>r`)
- Search through file names (`<Ctrl>t`). Example: `cat <Ctrl>t`
- Search through file names (`**<Tab>`). Example `cat ./project/**<Tab>`
- Adds autocomplete with `<Tab>` to `kill`
- SSH with completion from `/etc/hosts` and `~/.ssh/config` with `ssh **<Tab>`
- `unset`, `export`, and `unalias` with completion with `unset **<Tab>`

![History search](./README_img/fzf.png)

```
brew install fzf
```

Run the install script it prints on install (`/usr/local/opt/fzf/install` for me).

This modifies `~/.zshrc` for you

# Install [fzf-tab](https://github.com/Aloxaf/fzf-tab)

Add fuzzy completion to tab-complete. Very useful when there's a bunch of similarly named things in a directory (like ticket notes).

![fzf-tab](./README_img/fzf-tab.png)

Clone the repo:

```bash
git clone https://github.com/Aloxaf/fzf-tab ~/Git-GH/fzf-tab
```

Add to zshrc:

```bash
# https://github.com/Aloxaf/fzf-tab
source ~/Git-GH/fzf-tab/fzf-tab.plugin.zsh
# Can run `build-fzf-tab-module` to get some colors ( https://github.com/Aloxaf/fzf-tab#binary-module )
# fzf-tab completions settings - not sure how much I need these :)
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
```

Install `exa` for directory previews:

```bash
brew install exa
```

Build the `ff-tab-module` to get colors (requires C compliation toolchain):

```bash
build-fzf-tab-module
```



# Install [`zoxide`](https://github.com/ajeetdsouza/zoxide)

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
echo '
eval "$(zoxide init zsh)"
' >> "$HOME/.zshrc"
```

# Install [`fast-syntax-highlighting`](https://github.com/zdharma/fast-syntax-highlighting)

Add syntax highglighting while typing

![](./README_img/fast-syntax-highlighting.png)

I clone into `~/Git`. Change this name if you want to clone somewhere else!

```
git clone https://github.com/zdharma/fast-syntax-highlighting ~/Git-GH/fast-syntax-highlighting
```

```
cat >> "$HOME/.zshrc" << 'EOF'
source ~/Git-GH/fast-syntax-highlighting/F-Sy-H.plugin.zsh

EOF
```

Open a new `zsh` shell.

# Install [warhol.plugin.zsh](https://github.com/unixorn/warhol.plugin.zsh)

Colorize command output using grc and lscolors

![](./README_img/warhol.plugin.zsh.png)

```bash
brew install grc
```

```bash
git clone https://github.com/unixorn/warhol.plugin.zsh.git  ~/Git-GH/warhol.plugin.zsh
```

```bash
printf '
# https://github.com/unixorn/warhol.plugin.zsh
source ~/Git-GH/warhol.plugin.zsh/warhol.plugin.zsh
' >> ~/.zshrc
```

# Install [carapace-bin](https://github.com/rsteube/carapace-bin)

Add nice auto-completion for common commands witha smaller startup-time penalty than  [zsh-completions](https://github.com/zsh-users/zsh-completions).

```bash
brew install rsteube/tap/carapace
```

```bash
cat >> "$HOME/.zshrc" << 'EOF'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)
EOF
```

# TODO

- url auto-complete, tetris: https://matt.blissett.me.uk/linux/zsh/zshrc

- autocomplete: https://unix.stackexchange.com/a/214699/185953
- mess with vim mode? http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets
