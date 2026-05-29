-- True when nvim's clipboard can't reach the local machine directly: either a
-- plain SSH login (SSH_CONNECTION, set by sshd) or a wezterm mux pane on the dev
-- VM. The latter has no SSH_CONNECTION -- panes are children of the persistent
-- wezterm-mux-server, not sshd -- so the ld1 shell rc exports WEZTERM_REMOTE_MUX
-- alongside the forwarded-agent SSH_AUTH_SOCK. Either way, route yanks back via OSC52.
local in_ssh = vim.env.SSH_CONNECTION ~= nil or vim.env.WEZTERM_REMOTE_MUX ~= nil

-- https://github.com/folke/lazy.nvim?tab=readme-ov-file#-installation
-- Example using a list of specs with the default options
vim.g.mapleader = " "       -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\" -- Same for `maplocalleader`

-- inoremap jk <Esc>
vim.keymap.set('i', 'jk', '<Esc>')

-- map j to gj and k to gk, so line navigation ignores line wrap
-- nnoremap j gj
-- nnoremap k gk
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

-- https://stackoverflow.com/a/30691754
-- set clipboard=unnamedplus
vim.o.clipboard = "unnamedplus"

-- set nohlsearch
vim.o.hlsearch = false

-- https://mil.ad/blog/2024/remote-clipboard.html
-- help :clipboard-osc52
if in_ssh then
    vim.g.clipboard = 'osc52'
end

-- set wrap                          " Only use a soft wrap, not a hard one
vim.o.wrap = true
-- set linebreak                     " Break lines at word (requires Wrap lines)
vim.o.linebreak = true

-- https://stackoverflow.com/a/1878984/2958070
-- https://gist.github.com/LunarLambda/4c444238fb364509b72cfb891979f1dd

-- set tabstop=4       " The width of a TAB is set to 4. Still it is a \t. It is just that
vim.o.tabstop = 4

-- set shiftwidth=4    " Indents will have a width of 4
vim.o.shiftwidth = 4

-- set softtabstop=4   " Sets the number of columns for a TAB
vim.o.softtabstop = 4

-- set expandtab       " Expand TABs to spaces
vim.o.expandtab = true

vim.o.termguicolors = true

vim.o.inccommand = "split"

vim.o.smartcase = true

-- How long Neovim waits for a multi-key sequence to complete. mini.clue uses
-- this as its popup delay, so the default 1000 (1s) makes the clue window feel
-- sluggish; 300 makes it pop quickly. Also the window for chords like `jk`->Esc.
vim.o.timeoutlen = 300

-- https://stackoverflow.com/a/65352148/2958070
-- https://www.reddit.com/r/neovim/comments/w1ujir/mouse_enabled_by_default_in_git_master/?utm_source=share&utm_medium=web2x&context=3
vim.o.mouse = ''

-- https://stackoverflow.com/a/5774854
-- this means I can put something like `# vim:set ft=zsh:` in a file
-- It's also a security risk - arbitrary commands can be run on file open...
-- vim.o.modeline = true
-- vim.o.modelines = 5
