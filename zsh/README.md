# Ben's Zsh Customizations and Plugins!!!

## Design Goals

- Don't change how the shell works too much! I `ssh` into other machines installed with `bash`, and it's essential that I don't need to context switch too hard when I do. This config tries to accomplish this by:
  - using `zsh` (fairly `bash` compatible)
  - focusing on making common shell operations easier and faster, not replacing them wholesale. Think "turn the shell prompt into an IDE" - code should be faster to write, but it should look the same as if you didn't have the IDE
- Make my customizations easy to install, easy to play with, and easy to uninstall. This should be easy to "try out". This config tries to accomplish this by:
  - not replacing `~/.zshrc` but instead providing `source <file>` lines to add to it - this lets users keep their own configuration and toggling mine on and off by commenting a line or two
  - putting different functionality in different files to source. Want only one of `zp_prompt` and `zshrc_common`? `source` one but not the other
  - adding `curl` install commands (I actually use `stow` to provide these files so I can easily keep them in Git)
  - noting keyboard shortcuts the tools add I really like in this README and adding screenshots

## Install via GNU Stow

NOTE: this is not necessary if you use the `curl` commands provided and most people should use those. I use the `stow` method below to keep all my `zsh` config under version control, and you probably don't care about that

Clone the repo and `../stow.sh`. Most people should use the `curl` install methods instead.

## Install [Common Settings](./.zshrc_common.zsh)

Common functions and settings.

### Install via Curl

```
curl -Lo ~/.zshrc_common.zsh https://raw.githubusercontent.com/bbkane/dotfiles/master/zsh/.zshrc_common.zsh
```

```
cat >> "$HOME/.zshrc" << 'EOF'

# See https://github.com/bbkane/dotfiles
source ~/.zshrc_common.zsh

EOF
```

## Install [`zp_prompt`](./.zshrc_prompt.zsh)

Change prompt colors on the fly!

![](./README_img/zp_prompt.png)

### Install via Curl

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

## Install [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)

Add auto-complete based on history. Accept suggestions with `<Ctrl><Space>` or right arrow key.

![](./README_img/zsh-autosuggestions.png)

```
brew install zsh-autosuggestions
```

```
cat >> "$HOME/.zshrc" << 'EOF'
# NOTE: this source location might change if brew changes how it installs
# See `brew info zsh-autosuggestions`
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept  # also use Ctrl+Space to accept

EOF
```

## Install [fzf](https://github.com/junegunn/fzf)

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

## Install [fasd](https://github.com/clvv/fasd)

`fasd` lets you:
- Open recently/frequently used files with `v <fuzzy-term><Tab>`
- `cd` to recent/frequent directories with `z <fuzzy-term><Tab>`
- Trigger completion with `<Ctrl>x<Ctrl>a` - example `vim <Ctrl>x<Ctrl>a`

```
brew install fasd
```

```
cat >> "$HOME/.zshrc" << 'EOF'
# NOTE: this has to build a database of frecently used files and dirs
# so it won't be useful for a while. Once it has a list, use `z <fuzzyname>`
# to cd into a directory or `v <fuzzyname>` to nvim it. Push <TAB> to complete from list
eval "$(fasd --init auto)"
alias v='f -e nvim' # quick opening files with nvim
bindkey '^X^A' fasd-complete

EOF
```

## Install [`fast-syntax-highlighting`](https://github.com/zdharma/fast-syntax-highlighting)

Add syntax highglighting while typing

![](./README_img/fast-syntax-highlighting.png)

I clone into `~/Git`. Change this name if you want to clone somewhere else!

```
git clone https://github.com/zdharma/fast-syntax-highlighting ~/Git/fast-syntax-highlighting
```

```
cat >> "$HOME/.zshrc" << 'EOF'
source ~/Git/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

EOF
```

## TODO

- make blog post of zsh/fasd/fzf/zsh-autosuggestions
- prompt: consider indicating username when logged into a remote host
- url auto-complete, tetris: https://matt.blissett.me.uk/linux/zsh/zshrc
- autocomplete: https://unix.stackexchange.com/a/214699/185953
- mess with vim mode? http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets
- https://github.com/romkatv/powerlevel10k
