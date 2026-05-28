I'm tired of things breaking and constant updating, so I'm giving up on smart stuff - formatters, LSPs, Treesitter...

If I need to edit any of that, I'm just going to use VS Code - including for nvim configs, which need formatting, etc...

Let's keep my NeoVim config focused on quick text edits and as stable as I can make it.

As part of this, I'm not modifying standard vim locations.

# Install

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

For tree-sitter I need the `tree-sitter-cli` (see [here](https://github.com/nvim-treesitter/nvim-treesitter/tree/main#requirements))

```bash
brew install tree-sitter-cli
```

Open `nvim` - note that it'll freeze for a tad the first time because it's cloning `lazy.nvim` with git. Wait for that and then it'll all work out......

# LSP Install

The `nvim-lspconfig` plugin installs automatically via `lazy.nvim`, but the
language server binaries do not - install them yourself onto `$PATH`:

```bash
# lua_ls (Lua, incl. this config)
brew install lua-language-server

# gopls (Go)
go install golang.org/x/tools/gopls@latest
```

# Edit config

```bash
code ./dot-config/nvim  # uses .luarc.json there
```

NOTE: need to expand `$VIMRUNTIME` to put `.luarc.json`  so VS Code can read it ($VIMRUNTIME is only set when Neovim is started, so not in VS Code process)

```bash
nvim --headless -u NONE -i NONE --clean +'echo $VIMRUNTIME' +q
```



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

