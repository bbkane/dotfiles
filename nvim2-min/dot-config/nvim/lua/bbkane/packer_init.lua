-- Packer

-- I want all nvim data in ~/.config/nvim somewhere so I can try different configs by symlinking ONE folder
-- https://neovim.io/doc/user/starting.html - see "Standard Paths"
-- https://www.reddit.com/r/neovim/comments/wacwhy/comment/ii0adg9/?utm_source=share&utm_medium=web2x&context=3
-- https://www.reddit.com/r/neovim/comments/u3z82u/how_to_change_the_installation_path_of_the/?utm_source=share&utm_medium=web2x&context=3

local util = require("bbkane.util")


-- TODO: use join_path
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

use 'tpope/vim-commentary' -- TODO: replace with lua version?

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
