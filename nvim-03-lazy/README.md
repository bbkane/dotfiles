I'm tired of things breaking and constant updating, so I'm giving up on smart stuff - formatters, LSPs, Treesitter...

If I need to edit any of that, I'm just going to use VS Code - including for nvim configs, which need formatting, etc...

Let's keep my NeoVim config focused on quick text edits and as stable as I can make it.

As part of this, I'm not modifying standard vim locations.

How to back up current nvim files before installing (thanks https://www.lazyvim.org/installation ):

```bash
# required
mv ~/.config/nvim{,.bak}

# optional but recommended
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
```

Or just delete them:

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

Symlink nvim config directory (from root `dotfiles` directory):

```bash
fling link -s nvim-03-lazy -i .luarc.json -i README.md
```

On Linux, `xsel` (X11) or `wl-clipboard` (Wayland) is needed for clipboard interaction:

```bash
sudo apt install wl-clipboard  # or xsel
```

Open `nvim` - note that it'll freeze for a tad the first time because it's cloning `lazy.nvim` with git. Wait for that and then it'll all work out......

# Colorschemes I like

## Built-in

- darkblue
- default (bad for markdown, great for lua)
- desert
- elflord
- habamax
- industry

stopped here...

- slate
- wildcharm

## Plugin

See [Top Neovim Colorschemes in 2025](https://dotfyle.com/neovim/colorscheme/top)

- tokyonight-night

# Editing this config

Uses `.luarc.json` in VS Code... See [nvim: improve LSP config · Issue #54 · bbkane/dotfiles](https://github.com/bbkane/dotfiles/issues/54) for improvement ideas
