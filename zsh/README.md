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

## TODO

- make blog post of zsh/fasd/fzf/zsh-autosuggestions
- prompt: consider indicating username when logged into a remote host
- url auto-complete, tetris: https://matt.blissett.me.uk/linux/zsh/zshrc
- autocomplete: https://unix.stackexchange.com/a/214699/185953
- mess with vim mode? http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets
