# tmux

Note: this config is made by Claude and I haven't tested it

- `R` reloads the config
- Mouse mode on
- Truecolor enabled for WezTerm + Neovim (`tmux-256color` + `Tc` overrides)
- Low `escape-time` (10ms) to avoid `<Esc>` lag in Neovim
- `focus-events on` for Neovim autoread
- Windows/panes start at 1, with `renumber-windows`
- 50k-line scrollback

## Keyboard shortcuts

NOTE: in Wezterm, holding shift means I can select things as well as click links!

| Action | Shortcut |
| --- | --- |
| Detach | `Ctrl+b`, `d` |
| Create new window | `Ctrl+b`, `c` |
| Next window | `Ctrl+b`, `n` |
| Previous window | `Ctrl+b`, `p` |

