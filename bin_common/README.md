## bin_common

Don't version control `~/bin` - instead use that for local executables.
Fling `~/bin_common` and add it to the `$PATH`

Assumes `zsh` is the current shell

TODO: this method seems to be broken on zsh? It destroys the path of the current shell instead of appending the lines to the file

```
cat >> "$HOME/.zshrc" << 'EOF'

# See https://github.com/bbkane/dotfiles
export PATH="$HOME/bin_common:$PATH"
EOF
```
