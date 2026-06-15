I'm tired of things breaking and constant updating, so I'm giving up on smart stuff - formatters, LSPs, Treesitter...

If I need to edit any of that, I'm just going to use VS Code - including for nvim configs, which need formatting, etc...

Let's keep my NeoVim config focused on quick text edits and as stable as I can make it.

As part of this, I'm not modifying standard vim locations.

# Install

## Backup

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

# Keybindings

To see every mapping (fuzzy, searchable, with the definition location in the preview): `:Pick keymaps`. To find where a specific key was set: `:verbose nmap <key>` (e.g. `:verbose nmap <leader>d`).

`<leader>` is `<Space>`.

## Pickers (mini.pick)

| Action | Keybinding | Notes |
| --- | --- | --- |
| Find files | `<leader>ff` | |
| Find by grep (live) | `<leader>fg` | |
| Find buffers | `<leader>fb` | |
| Find help | `<leader>fh` | |
| Resume last picker | `<leader>fr` | |
| Find picker (registry of all pickers) | `<leader>fp` | |
| Buffer diagnostics | `<leader>d` | LSP picker |
| Project diagnostics | `<leader>D` | LSP picker |
| Workspace symbols | `<leader>ws` | LSP picker |

## LSP

"Built-in" = Neovim 0.11+ default active on attach; "Added" = defined in this config. (LSP pickers live in the Pickers table above.)

| Action | Keybinding | Notes |
| --- | --- | --- |
| Go to definition | `gd` | Added |
| Code action (incl. quickfix auto-fixes) | `gra` | Built-in |
| Rename | `grn` | Built-in |
| References | `grr` | Built-in |
| Go to implementation | `gri` | Built-in |
| Go to type definition | `grt` | Built-in |
| Document symbols | `gO` | Built-in |
| Hover docs | `K` | Built-in |
| Signature help | `<C-s>` | Built-in; insert mode |
| Previous / next diagnostic | `[d` / `]d` | Built-in |
| Show diagnostic float under cursor | `<C-w>d` | Built-in |
| Open / accept completion | `<C-Space>` / `<C-@>` | Added; insert mode |
| Run code lens under cursor | `<leader>cl` | Added |

## Other

Equivalents in *this* config. A few actions have no dedicated binding here — marked accordingly.

| Action | Keybinding | Notes |
| --- | --- | --- |
| Complete from strings in file | `<C-x><C-n>` | Insert mode. Built-in buffer-keyword completion; `<C-Space>` does LSP completion |
| Format file | n/a | On `:w` — auto-formats on save via the `BufWritePre` autocmd; no manual keymap |
| Go back / forward | `<C-o>` / `<C-i>` | Jumplist (built-in) |
| Navigate symbols in current file | `gO` | Document symbols (built-in) |
| Split window | `<C-w>s` / `<C-w>v` | Horizontal / vertical (built-in) |
| Move between splits | `<C-w>h` / `<C-w>j` / `<C-w>k` / `<C-w>l` | Built-in |
| Toggle file explorer (tree) | `<leader>e` | Added; nvim-tree. `g?` for help inside the tree |

## File explorer (nvim-tree)

In-tree mappings (open with `<leader>e`; press `g?` inside for the full list). File ops act relative to the directory under the cursor.

| Action | Keybinding | Notes |
| --- | --- | --- |
| Add file / directory | `a` | End name with `/` for a directory; `foo/bar/baz.lua` creates intermediate dirs |
| Rename | `r` | |
| Delete | `d` | |
| Cut | `x` | |
| Copy | `c` | |
| Paste | `p` | Into the selected directory |
| Open file | `<CR>` / `o` | |
| Show all mappings (help) | `g?` | |

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

