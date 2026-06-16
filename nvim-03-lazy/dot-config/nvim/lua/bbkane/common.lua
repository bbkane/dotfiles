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
local in_ssh = vim.env.SSH_CONNECTION ~= nil or vim.env.WEZTERM_REMOTE_MUX ~= nil
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

-- Make markdown headings stand out: the default colorscheme colors every heading
-- level like body text (just bold). Give each level its own hue (the default
-- theme's Diagnostic colors). Set directly since this config uses the default
-- colorscheme - running `:colorscheme` would reset these.
vim.api.nvim_set_hl(0, '@markup.heading.1.markdown', { fg = '#b3f6c0', bold = true }) -- green
vim.api.nvim_set_hl(0, '@markup.heading.2.markdown', { fg = '#a6dbff', bold = true }) -- blue
vim.api.nvim_set_hl(0, '@markup.heading.3.markdown', { fg = '#8cf8f7', bold = true }) -- teal
vim.api.nvim_set_hl(0, '@markup.heading.4.markdown', { fg = '#ffc0b9', bold = true }) -- red
vim.api.nvim_set_hl(0, '@markup.heading.5.markdown', { fg = '#fce094', bold = true }) -- yellow
vim.api.nvim_set_hl(0, '@markup.heading.6.markdown', { fg = '#9b9ea4', bold = true }) -- gray

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

-- Neovide (GUI) settings. `vim.g.neovide` is set only when running under Neovide;
-- terminal Neovim ignores guifont and the neovide_* globals. https://neovide.dev
if vim.g.neovide then
    vim.o.guifont = "Hack:h18" -- match the WezTerm font (Hack, size 18)

    -- Left Option sends <M-...>, so the Alt-based Copilot keys (lazy.lua) work -
    -- the Neovide equivalent of the WezTerm send_composed setup.
    vim.g.neovide_input_macos_option_key_is_meta = "only_left"

    -- Zoom / window
    vim.g.neovide_scale_factor = 1.0
    vim.g.neovide_remember_window_size = true
    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_confirm_quit = true

    -- Zoom the whole UI with Ctrl-= / Ctrl-- (Ctrl-+ too, for the shifted key).
    local function change_scale(delta)
        vim.g.neovide_scale_factor = math.max(0.3, vim.g.neovide_scale_factor + delta)
    end
    vim.keymap.set("n", "<C-=>", function() change_scale(0.1) end, { desc = "Neovide: zoom in" })
    vim.keymap.set("n", "<C-+>", function() change_scale(0.1) end, { desc = "Neovide: zoom in" })
    vim.keymap.set("n", "<C-->", function() change_scale(-0.1) end, { desc = "Neovide: zoom out" })
end
