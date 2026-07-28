I'm trying to keep this config deliberately small so things break less over time, but I'm also using Claude to get the things I miss from VS Code into NeoVim.

# Features

- **[lazy.nvim](https://github.com/folke/lazy.nvim)** plugin manager
- **[mini.nvim](https://github.com/nvim-mini/mini.nvim)** suite: clue (which-key), icons, pick (fuzzy finder), extra pickers, diff (git signs), pairs (auto-brackets), trailspace (trim on save)
- **Custom pickers** (all under `<leader>f` / `<leader>d` / `<leader>o`):
  - `<leader>ff` — files, `<leader>fg` — live grep, `<leader>fb` — buffers, `<leader>fh` — help, `<leader>fr` — resume
  - `<leader>fp` — picker registry (pick a picker)
  - `<leader>fz` — zoxide directories (frecency-sorted, updates score on selection)
  - `<leader>d` — buffer diagnostics (severity-colored rows + source-line previews)
  - `<leader>D` — project-wide diagnostics (all loaded buffers)
  - `<leader>ws` — workspace symbols (two-column: kind icon + name / path:line)
  - `<leader>o` — outline (LSP document symbols, falls back to Treesitter headings in Markdown)
- **LSP** via nvim-lspconfig: bash, Go, Lua, Python (ruff/ty), Rust (rust-analyzer)
- **Treesitter** syntax highlighting for bash, Go, Markdown, Python, Rust, SQL, YAML, and more
- **[nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)** file explorer (`<leader>e`)
- **[GitHub Copilot](https://github.com/zbirenbaum/copilot.lua)** inline ghost-text suggestions
- **[vim-table-mode](https://github.com/dhruvasagar/vim-table-mode)** auto-aligns Markdown tables as you type
- **[indent-blankline](https://github.com/lukas-reineke/indent-blankline.nvim)** indent guides
- **[vim-rsi](https://github.com/tpope/vim-rsi)** Readline keybindings in insert/command mode
- **[image.nvim](https://github.com/3rd/image.nvim)** inline images in Markdown/HTML buffers (and when opening an image file directly). Needs a terminal that speaks the Kitty graphics protocol — see [Inline images](#inline-images)
- **[img-clip.nvim](https://github.com/HakonHarnes/img-clip.nvim)** paste an image from the clipboard into a file's `.assets/` dir and insert a link — see [Pasting images](#pasting-images)
- **OSC52 clipboard** support (works over SSH / WezTerm remote mux)

# Install

How to back up current nvim files before installing (thanks https://www.lazyvim.org/installation ):

```bash
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
```

Or just delete them:

```bash
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

## Symlink

Symlink nvim config directory (from root `dotfiles` directory):

```bash
fling link -s nvim-03-lazy -i README.md
```

## Install dependencies

On Linux, `xsel` (X11) or `wl-clipboard` (Wayland) is needed for clipboard interaction
(pasting images additionally needs `xclip` on X11 — see [Pasting images](#pasting-images)):

```bash
sudo apt install wl-clipboard  # or xsel
```

Install other dependencies:

```bash
# LSPs and tree-sitter
# bash-language-server auto-uses shellcheck + shfmt
brew install bash-language-server gopls lua-language-server ruff shellcheck shfmt tree-sitter-cli ty

# rust-analyzer ships as a rustup component (needs https://rustup.rs)
rustup component add rust-analyzer

# image.nvim needs ImageMagick to scale/crop images (see "Inline images" below)
brew install imagemagick

# img-clip.nvim needs pngpaste to read images off the clipboard (macOS only;
# on Linux it uses wl-clipboard/xclip - see "Pasting images" below)
brew install pngpaste
```

See other tree-sitter requirements [here](https://github.com/nvim-treesitter/nvim-treesitter/tree/main#requirements) (most likely pre-installed)

Open `nvim` - note that it'll freeze for a tad the first time because it's cloning `lazy.nvim` with git and setting up treesitter. Wait for that and then it'll all work out......

# Inline images

[image.nvim](https://github.com/3rd/image.nvim) draws Markdown/HTML images in the buffer
(and renders `.png`/`.jpg`/`.gif`/`.webp` files as images when opened directly).

Requirements:

1. **A terminal that implements the [Kitty graphics
   protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/)** — kitty (see the
   `kitty/` package in this repo) or Ghostty. WezTerm's implementation is partial and
   isn't supported by image.nvim, so images won't show there.
2. **ImageMagick** — `brew install imagemagick`. The config uses the `magick_cli`
   processor, which shells out to the `magick` binary, so no LuaRocks setup is needed.

Gotchas:

- **tmux**: images don't render unless tmux sets `allow-passthrough on`. That's
  intentionally not in `tmux/dot-tmux.conf`, so run Neovim outside tmux for images.
- Images are hidden while in insert mode, when another window overlaps them, and when
  the editor loses focus — the terminal draws them over Neovim's UI otherwise.
- The plugin spec sets `build = false` so lazy.nvim doesn't build image.nvim's rockspec
  (which would drag in hererocks and a Lua 5.1 toolchain we don't need).

Quick check that it works:

```bash
mkdir -p /tmp/imgtest && cd /tmp/imgtest
magick -size 240x120 gradient:blue-orange test.png
printf '# Image test\n\n![a test image](test.png)\n' > test.md
kitty nvim test.md   # or open test.md in Ghostty
```

# Pasting images

[img-clip.nvim](https://github.com/HakonHarnes/img-clip.nvim) saves whatever image is on
the clipboard next to the current file and inserts a link to it:

```
notes.md
notes.assets/2026-07-28-14-28-14.png
```
```markdown
![](notes.assets/2026-07-28-14-28-14.png)
```

Trigger it with `:PasteImage`, or `<M-v>` (Alt-v) in insert mode — `<C-v>` is Vim's
literal-insert, so it's left alone. image.nvim then renders the pasted image right away.

It handles three kinds of clipboard content:

| Clipboard holds | Result |
|---|---|
| Raw image data (a screenshot) | saved as `<timestamp>.png` |
| A file path (copied file, drag and drop) | copied in, keeping its own extension |
| An image URL | downloaded |

Requirements, by platform — the plugin picks the right one automatically:

| Platform | Needs |
|---|---|
| macOS | `brew install pngpaste` |
| Linux (Wayland) | `wl-clipboard` (uses `wl-paste`; needs `$WAYLAND_DISPLAY` set) |
| Linux (X11) | `xclip` (note: `xsel` is *not* enough — that's only for Neovim's own clipboard) |

Verify with `:checkhealth img-clip`. The plugin is lazy-loaded, so run `:Lazy load
img-clip.nvim` first or the healthcheck reports as missing.

# Edit config

NOTE: need to expand `$VIMRUNTIME` to put `.luarc.json`  so VS Code can read it ($VIMRUNTIME is only set when Neovim is started, so not in VS Code process)

```bash
nvim --headless -u NONE -i NONE --clean +'echo $VIMRUNTIME' +q
```

# Config layout

Neovim treats `~/.config/nvim` (this directory) as a "runtimepath" entry, and a few subfolder names are **special**: Neovim auto-loads files from them at specific moments. Everything else is only loaded if some Lua file explicitly `require`s it. Here's what this config uses and when each is loaded:

| Path | Loaded when | Holds |
| --- | --- | --- |
| `init.lua` | First, at startup | Entry point. Just `require`s the `bbkane.*` modules in order: `common` → `autocmds` → `cmds` → `lazy` |
| `lua/bbkane/*.lua` | On demand, when `require`d | The actual config modules. The `lua/` dir is on Lua's package path, so it is **not** auto-run — `init.lua` pulls these in explicitly, top to bottom |
| `lsp/<name>.lua` | When that server is enabled (Neovim 0.11+) | Per-server LSP config (one file per server: `gopls.lua`, `ruff.lua`, …). Auto-read when `vim.lsp.enable("<name>")` runs |
| `ftplugin/<filetype>.lua` | On the `FileType` event, every time a buffer's filetype is set | Buffer-local settings for that filetype (e.g. `ftplugin/gitconfig.lua` forces real tabs). Runs once per matching buffer |
| `templates/` | Never auto-loaded | Skeleton files for new buffers. **Not** a special dir — the `BufNewFile` autocmd in `autocmds.lua` reads them by hand |
| `.luarc.json` | Read by lua-language-server | Lua LSP settings for editing this config (not used by Neovim itself) |
| `lazy-lock.json` | Read/written by lazy.nvim | Plugin version lockfile |

Filetype **detection** (which extensions/filenames map to which filetype) is set in `lua/bbkane/autocmds.lua` via `vim.filetype.add()`; the per-filetype **settings** that detection triggers live in `ftplugin/`.

Other special folders Neovim auto-loads but this config doesn't currently use: `plugin/` (run once at startup, after plugins), `ftdetect/` (older alternative to `vim.filetype.add`), `indent/`, `syntax/`, and `after/` (same names, sourced last to override).

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

