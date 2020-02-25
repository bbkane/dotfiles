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

