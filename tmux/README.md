## tmux

Deployed as `~/.tmux.conf` (Stow-style `dot-` prefix).

- Prefix remapped to `C-a` (screen-style)
- `R` reloads the config
- Mouse mode on
- Truecolor enabled for WezTerm + Neovim (`tmux-256color` + `Tc` overrides)
- Low `escape-time` (10ms) to avoid `<Esc>` lag in Neovim
- `focus-events on` for Neovim autoread
- Windows/panes start at 1, with `renumber-windows`
- 50k-line scrollback
