## zsh

don't version control `~.zshrc` - use that for local settings.
Instead version control `~/.zshrc_common.zsh` and source that from `~.zshrc`

## Symlink

```
./stow.sh zsh
```

## Install common stuff

```
cat >> "$HOME/.zshrc" << 'EOF'

# See https://github.com/bbkane/dotfiles
source ~/.zshrc_common.zsh
EOF
```

## Install prompt

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

```
brew install fzf
```

Run the install script it prints on install (`/usr/local/opt/fzf/install` for me).

This modifies `~/.zshrc`

## Install [fasd](https://github.com/clvv/fasd)

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
EOF
```

## TODO

- make blog post of zsh/fasd/fzf/zsh-autosuggestions
- prompt: consider indicating username when logged into a remote host
- url auto-complete, tetris: https://matt.blissett.me.uk/linux/zsh/zshrc
- autocomplete: https://unix.stackexchange.com/a/214699/185953
- mess with vim mode? http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets
