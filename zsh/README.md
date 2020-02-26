## zsh

don't version control `~.zshrc` - use that for local settings.
Instead version control `~/.zshrc_common.zsh` and source that from `~.zshrc`

```
cat >> "$HOME/.zshrc" << 'EOF'

# See https://github.com/bbkane/dotfiles
source ~/.zshrc_common.zsh
source ~/.zshrc_prompt.zsh

# brew install zsh-autosuggestions
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
EOF
```

Should also `brew install fzf`, then run the install script printed at the end which modifies `~/.zshrc`

I think `fzf` does everything `fasd` does, maybe consider retrying `fasd` at some point

TODO: make cheatsheet of stuff this provides.
