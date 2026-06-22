I'm trying to keep this config deliberately small so things break less over time, but I'm also using Claude to get the things I miss from VS Code into NeoVim.

# Features

- **[lazy.nvim](https://github.com/folke/lazy.nvim)** plugin manager
- **[mini.nvim](https://github.com/nvim-mini/mini.nvim)** suite: clue (which-key), icons, pick (fuzzy finder), extra pickers, diff (git signs), pairs (auto-brackets), trailspace (trim on save)
- **Custom pickers** (all under `<leader>f` / `<leader>d` / `<leader>o`):
  - `<leader>ff` — files, `<leader>fg` — live grep, `<leader>fb` — buffers, `<leader>fh` — help, `<leader>fr` — resume
  - `<leader>fp` — picker registry (pick a picker)
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

On Linux, `xsel` (X11) or `wl-clipboard` (Wayland) is needed for clipboard interaction:

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
```

See other tree-sitter requirements [here](https://github.com/nvim-treesitter/nvim-treesitter/tree/main#requirements) (most likely pre-installed)

Open `nvim` - note that it'll freeze for a tad the first time because it's cloning `lazy.nvim` with git and setting up treesitter. Wait for that and then it'll all work out......

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

