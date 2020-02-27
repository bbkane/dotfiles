## zsh

don't version control `~.zshrc` - use that for local settings.
Instead version control `~/.zshrc_common.zsh` and source that from `~.zshrc`

```
cat >> "$HOME/.zshrc" << 'EOF'

# See https://github.com/bbkane/dotfiles
source ~/.zshrc_common.zsh

source ~/.zshrc_prompt.zsh
# NOTE: this needs pastel
zp_prompt "$(zp_gen_colors_pastel pink gold)"

# brew install zsh-autosuggestions
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept  # also use Ctrl+Space to accept
EOF
```

Should also `brew install fzf`, then run the install script printed at the end - it modifies `~/.zshrc`

I think `fzf` does everything `fasd` does, maybe consider retrying `fasd` at some point

TODO: make cheatsheet of stuff this provides.
TODO: optionally replace pastel with printf
