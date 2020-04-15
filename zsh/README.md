# Ben's Zsh Customizations and Plugins!!!

- I recommend using `~/.zshrc` for computer-specific settings and simply sourcing these files from it.
- Alternate way to install common and prompt zsh scripts (in this folder): clone the repo and `../stow.sh`. This keeps these files under version control. Most people should use the `curl` commands instead

## Install common stuff

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

## Install prompt

Change prompt colors on the fly!

![](./README_img/zp_prompt.png)

### Install via Curl

```
curl -Lo ./.zshrc_prompt.zsh https://raw.githubusercontent.com/bbkane/dotfiles/master/zsh/.zshrc_prompt.zsh
```

```
brew install pastel  # Optional: for extra colors
```

```
cat >> "$HOME/.zshrc" << 'EOF'
# See https://github.com/bbkane/dotfiles
source ~/.zshrc_prompt.zsh
zp_prompt "$(pastel gradient -n 7 dodgerblue lightgreen | pastel format hex)"

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
