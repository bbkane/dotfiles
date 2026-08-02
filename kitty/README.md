# kitty

[kitty](https://sw.kovidgoyal.net/kitty/) terminal config.

I mostly use WezTerm, but kitty's [graphics
protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/) is why I keep it
around. Ghostty implements the same protocol too; WezTerm's support is partial.

## Install

```bash
brew install --cask kitty
fling --src-dir kitty link
```

## Uninstall

```bash
fling --src-dir kitty unlink
```

## Notes

- Reload config in a running kitty with `ctrl+cmd+,` (macOS).
- Font and scrollback intentionally mirror the WezTerm config so switching
  terminals isn't jarring.
- `macos_option_as_alt left` keeps left-Option sending `<M-...>`, which
  readline word-motions and Neovim Alt maps depend on. Right Option stays a
  compose key.
- Images do **not** render inside tmux unless tmux has `allow-passthrough on`.
  That's deliberately not enabled in `tmux/dot-tmux.conf`.
