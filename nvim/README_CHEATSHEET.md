TODO: Mon 2026-06-22: Claude generated; review and refine the working with projects notes; also pick a session picker
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

copilot.lua's Alt-based defaults (these work because left-Option sends `<M-…>` in WezTerm):

| Description | Action | Notes |
| --- | --- | --- |
| Accept suggestion | `<M-l>` | Insert mode |
| Next suggestion | `<M-]>` | Insert mode |
| Previous suggestion | `<M-[>` | Insert mode |
| Dismiss suggestion | `<C-]>` | Insert mode |

## Markdown

Buffer-local to markdown (`ftplugin/markdown.lua`). Tables auto-align as you type (vim-table-mode).

| Description | Action | Notes |
| --- | --- | --- |
| Insert link from clipboard | `<C-k>` | Insert mode. `[](url)`, or wraps the word under the cursor; url comes from the clipboard if it's a URL |
| Wrap selection in a link | `<C-k>` | Visual mode. `[selection](url)` |
| Realign table | `:TableModeRealign` | vim-table-mode |

# Working with projects

Notes for living in Neovim across many files instead of editing one and quitting.

## The core abstractions

Keep these three straight — most confusion comes from conflating them:

| Thing | What it is | Mental model |
| --- | --- | --- |
| **Buffer** | A file loaded into memory | The *content*. Editing happens here. Many can exist hidden, with no window showing them |
| **Window** | A viewport onto a buffer | The *frame*. Splits create more windows; closing one doesn't touch the buffer |
| **Tab** | A layout of windows | The *workspace arrangement*, **not** a file tab. One tab can hold many split windows |
| **Float / popup** | A transient window drawn over the grid | Hover docs (`K`), pickers, diagnostics, completion. Dismiss and the layout underneath is untouched |

Key insight: a buffer and a window are independent. You can have 30 buffers open but only 2 windows. Closing a window (`<C-w>q`) keeps the buffer; deleting a buffer (`:bd`) frees the file.

## Buffers (the open files)

| Description | Action | Notes |
| --- | --- | --- |
| Find / switch buffer (picker) | `<leader>fb` | Fuzzy list of open buffers |
| Jump to a buffer by name | `:b <partial><Tab>` | `:b foo` matches any open buffer with "foo" in its path |
| Toggle to previous buffer | `<C-^>` | The "alternate" file; flip-flops between two files fast |
| Next / previous buffer | `:bnext` / `:bprev` | No default keymap; via command |
| Close buffer (keep window) | `:bd` | Removes from buffer list |
| List buffers | `:ls` or `<leader>fb` | `:ls` shows numbers + flags |

- Buffers accumulate silently as you jump around (`gd`, grep results, picker opens). That's fine — they're cheap. Use `<leader>fb` to navigate them rather than tracking them in your head.
- `<C-^>` is the single most useful "living-in-nvim" key: bounce between the two files you're actively comparing without a picker.

## Windows / splits (viewing multiple things at once)

| Description | Action | Notes |
| --- | --- | --- |
| Split horizontal / vertical | `<C-w>s` / `<C-w>v` | Both show the *same* buffer until you switch one |
| Move between splits | `<C-w>h/j/k/l` | Directional |
| Close this split | `<C-w>q` | Buffer stays loaded |
| Close all *other* splits | `<C-w>o` | "Only" — back to one window |
| Open a file in a split | `:vsplit <file>` / `:split <file>` | Or split, then `<leader>ff` to pick a file |
| Cycle / rotate splits | `<C-w>w` / `<C-w>r` | |
| Resize | `<C-w>=` / `<C-w>+` `<C-w>-` `<C-w>>` `<C-w><` | Equalize / grow / shrink |
| Move split to its own tab | `<C-w>T` | |

- `<C-w>` is clued — press it and pause to see the menu (mini.clue).
- Workflow: open file A, `<C-w>v`, then `gd` or `<leader>ff` in the right split to view a definition/second file beside it. `<C-w>o` collapses back when done.
- There's no "maximize/zoom this split" plugin here; `<C-w>o` (only) or moving to a tab (`<C-w>T`) is the closest.

## Tabs (whole layouts)

A tab is a saved arrangement of splits — use one per *task* or *context*, not per file.

| Description | Action | Notes |
| --- | --- | --- |
| New tab | `:tabnew` | |
| Next / previous tab | `gt` / `gT` | |
| Go to tab N | `<N>gt` | e.g. `2gt` |
| Close tab | `:tabclose` | Splits inside it close; buffers survive |
| Move current window into a new tab | `<C-w>T` | |

- Example: tab 1 = feature code (2 splits), tab 2 = the test file + a terminal, tab 3 = docs. Switch context with `gt`.

## Project-wide navigation

| Description | Action | Notes |
| --- | --- | --- |
| Find files in project | `<leader>ff` | |
| Live grep across project | `<leader>fg` | Find a thing when you don't know the file |
| Resume last picker | `<leader>fr` | |
| File tree | `<leader>e` | nvim-tree; `g?` for help |
| Go to definition / references | `gd` / `grr` | Jumps may open new buffers |
| Jump back / forward | `<C-o>` / `<C-i>` | Jumplist — retrace your path across files |
| Project diagnostics (picker) | `<leader>D` | All loaded buffers |

## Quickfix & location lists (batch results)

A scratchpad of file:line results you step through — grep hits, references, diagnostics. The thing that makes multi-file edits tractable.

| Description | Action | Notes |
| --- | --- | --- |
| Open / close quickfix | `:copen` / `:cclose` | |
| Next / previous entry | `:cnext` / `:cprev` | Jumps to the file+line |
| References → loclist | `gO` | Document symbols populate the loclist |

- Pattern: grep (`<leader>fg`) or `grr` to gather hits → `:copen` → walk them with `:cnext`, editing as you go.

## Things you're probably missing

Moving from single-file to "living in it":

- **`<C-^>` (alternate file)** — flip between your two active files instantly. Underused, highest payoff.
- **Jumplist (`<C-o>` / `<C-i>`)** — every `gd`/grep/picker jump is recorded; `<C-o>` retraces backward across files. You rarely need to manually re-find where you were.
- **Marks** — `ma` sets mark `a`, `` `a `` jumps back (even across files with capital `mA`). Anchor spots you'll return to.
- **Don't `:q` per file** — `:q` closes a *window*. With one window it quits nvim. To put a file away, just navigate elsewhere (`<C-^>`, picker); the buffer stays. Quit nvim only when you're actually done.
- **`:bd` vs `:q`** — `:q` closes the viewport; `:bd` unloads the file. You almost never need either day-to-day — leave buffers loaded.
- **Sessions** — no session plugin is configured here. The built-in `:mksession ~/proj.vim` saves your tabs/splits/buffers; reload with `nvim -S proj.vim`. Worth adding a plugin (e.g. `persisted.nvim`) if you want this automatic per-directory.
- **`:cd` / `:lcd`** — set the working dir so `<leader>ff` and `<leader>fg` scope to your project. `:lcd` scopes it to the current window only.
- **Buffers don't auto-save** — switching away from a modified buffer keeps it dirty (not lost). `:wa` writes all; formatting runs on each `:w`.
