-- Packer

-- I want all nvim data in ~/.config/nvim somewhere so I can try different configs by symlinking ONE folder
-- https://neovim.io/doc/user/starting.html - see "Standard Paths"
-- https://www.reddit.com/r/neovim/comments/wacwhy/comment/ii0adg9/?utm_source=share&utm_medium=web2x&context=3
-- https://www.reddit.com/r/neovim/comments/u3z82u/how_to_change_the_installation_path_of_the/?utm_source=share&utm_medium=web2x&context=3

local util = require("bbkane.util")


-- TODO: use join_paths
local new_packpath = vim.fn.stdpath('config') .. '/packer_packpath'
vim.opt.packpath:append(new_packpath)

-- ~/.config/nvim/packer_packpath .. /pack/packer/start/packer.nvim
local packer_install_path = new_packpath .. '/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(packer_install_path)) > 0 then
    packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_install_path})
    vim.cmd [[packadd packer.nvim]]
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost packer_init.lua source <afile> | PackerCompile
  augroup end
]])

local packer = require("packer")

packer.init({
    -- Leaving this default
    snapshot_path = util.join_paths(vim.fn.stdpath 'cache', 'packer.nvim'),
    package_root   = util.join_paths(new_packpath, 'pack'),
    compile_path = util.join_paths(vim.fn.stdpath('config'), 'plugin', 'packer_compiled.lua'),
})
packer.reset()

local use = packer.use

use 'wbthomason/packer.nvim'

use {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
}

-- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
}

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
}

vim.o.termguicolors = true

use 'marko-cerovac/material.nvim'
vim.g.material_style = "palenight"
-- vim.cmd 'colorscheme material'

-- use 'folke/tokyonight.nvim'
-- vim.g.tokyonight_style = "day"
-- vim.cmd[[colorscheme tokyonight]]

-- I really like this one for markdown, but not so much for Lua code
use "rebelot/kanagawa.nvim"
vim.cmd("colorscheme kanagawa")

-- use { "ellisonleao/gruvbox.nvim" }
-- require("gruvbox").setup({
--     italic = false,
--     contrast = "",
-- })
-- vim.o.background = "dark" -- or "light" for light mode
-- vim.cmd([[colorscheme gruvbox]])

use {
  'lewis6991/gitsigns.nvim',
  -- TODO: can I use a config function for the other ones too?
  config = function()
    require('gitsigns').setup()
  end
}

use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
}

local new_mason_install_root_dir = util.join_paths(vim.fn.stdpath('config'), '/mason_install_root_dir')
require("mason").setup({
    install_root_dir = new_mason_install_root_dir,
})
require('mason-lspconfig').setup()

-- TODO: nvim-cmp this?
-- https://github.com/neovim/nvim-lspconfig#suggested-configuration

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

require('lspconfig')['gopls'].setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
