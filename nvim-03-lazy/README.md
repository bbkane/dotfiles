I'm trying to keep this config deliberately small so things break less over time, but I'm also using Claude to get the things I miss from VS Code into NeoVim.

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

# Actions

To see every mapping (fuzzy, searchable, with the definition location in the preview): `:Pick keymaps`. To find where a specific key was set: `:verbose nmap <key>` (e.g. `:verbose nmap <leader>d`). To list every user-defined command: `:command` (or `:command Diagnostics` for one).

`<leader>` is `<Space>`.

## Pickers (mini.pick)

Generic finders. The LSP-specific pickers (diagnostics, symbols, outline) are in the LSP section below.

| Description | Action | Notes |
| --- | --- | --- |
| Find files | `<leader>ff` | |
| Find by grep (live) | `<leader>fg` | |
| Find buffers | `<leader>fb` | |
| Find help | `<leader>fh` | |
| Resume last picker | `<leader>fr` | |
| Find picker (registry of all pickers) | `<leader>fp` | Custom; `:Pick registry` |

## LSP

"Built-in" = Neovim 0.11+ default active on attach; "Added" = defined in this config; picker rows ("Custom" / "mini.extra") run through mini.pick. The generic file/grep/buffer finders are in the Pickers table above.

| Description | Action | Notes |
| --- | --- | --- |
| Go to definition | `gd` | Added |
| Code action (incl. quickfix auto-fixes) | `gra` | Built-in |
| Rename | `grn` | Built-in |
| References | `grr` | Built-in |
| Go to implementation | `gri` | Built-in |
| Go to type definition | `grt` | Built-in |
| Document symbols | `gO` | Built-in (loclist) |
| Outline / symbols (picker) | `<leader>o` | Custom; LSP document symbols, or Treesitter markdown headings when no LSP. `:Pick outline` |
| Workspace symbols (picker) | `<leader>ws` | mini.extra; shows all symbols to filter down, except gopls (live — type to search, since it returns nothing for an empty query) |
| Hover docs | `K` | Built-in. Hit K a second time to switch focus to the window for scrolling |
| Signature help | `<C-s>` | Built-in; insert mode |
| Previous / next diagnostic | `[d` / `]d` | Built-in |
| Show diagnostic float under cursor | `<C-w>d` | Built-in |
| Set diagnostic display mode | `:Diagnostics` | Added; tab-completes `virtual_lines` / `virtual_text` / `current_line` / `no_text` / `disabled` |
| Buffer diagnostics (picker) | `<leader>d` | Custom; this buffer. `:Pick buffer_diagnostics` |
| Project diagnostics (picker) | `<leader>D` | mini.extra; all loaded buffers |
| Open / accept completion | `<C-Space>` / `<C-@>` | Added; insert mode |
| Run code lens under cursor | `<leader>cl` | Added |

## Other

| Description | Action | Notes |
| --- | --- | --- |
| Complete from strings in file | `<C-x><C-n>` | Insert mode. Built-in buffer-keyword completion; `<C-Space>` does LSP completion |
| Format file | n/a | On `:w` — auto-formats on save via the `BufWritePre` autocmd; no manual keymap |
| Go back / forward | `<C-o>` / `<C-i>` | Jumplist (built-in) |
| Split window | `<C-w>s` / `<C-w>v` | Horizontal / vertical (built-in) |
| Move between splits | `<C-w>h` / `<C-w>j` / `<C-w>k` / `<C-w>l` | Built-in |
| Toggle file explorer (tree) | `<leader>e` | Added; nvim-tree. `g?` for help inside the tree |
| Trim trailing whitespace | `:TrimWhitespace` | Added; mini.trailspace |
| Rename the current file | `:RenameFile` | Added; prompts for the new name |
| Print full path of current file | `:FullPath` | Added |
| Insert current date/time at cursor | `:InsertDate` | Added |
| Strip carriage returns (`\r`) | `:Dos2Unix` | Added; range, defaults to whole file |
| Wrap selection in a code fence | `:AddCodeFence` | Added; range |
| Convert Markdown to Jira markup | `:MarkdownToJira` | Added; range, defaults to whole file |
| Format shell command in range | `:FormatShellCmd` | Added; range, pipes through `format_shell_cmd.py` |
| Print lazy.nvim install path | `:LazyPath` | Added |

## File explorer (nvim-tree)

In-tree mappings (open with `<leader>e`; press `g?` inside for the full list). File ops act relative to the directory under the cursor.

| Description | Action | Notes |
| --- | --- | --- |
| Add file / directory | `a` | End name with `/` for a directory; `foo/bar/baz.lua` creates intermediate dirs |
| Rename | `r` | |
| Delete | `d` | |
| Cut | `x` | |
| Copy | `c` | |
| Paste | `p` | Into the selected directory |
| Open file | `<CR>` / `o` | |
| Show all mappings (help) | `g?` | |

## Copilot (copilot.lua)

Inline ghost-text suggestions in insert mode (auto-triggered as you type). Requires Node.js on `$PATH`.

First-time auth: open `nvim` and run `:Copilot auth` — it shows a one-time code and opens GitHub in your browser; paste the code there to sign in. Check status anytime with `:Copilot status`.

| Description | Action | Notes |
| --- | --- | --- |
| Accept suggestion | `<C-l>` | Insert mode. No default insert behavior shadowed |
| Next suggestion | `<C-j>` | Insert mode. Shadows newline (still on `<Enter>`) |
| Previous suggestion | `<C-k>` | Insert mode. Shadows digraph entry (`<C-k>e'` → `é`) |
| Dismiss suggestion | `<C-]>` | Insert mode |

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


