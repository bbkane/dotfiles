local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- start color schemes
    -- https://vimcolorschemes.com/i/trending
    {
        "sainnhe/everforest",
        config = function()
            -- https://github.com/sainnhe/everforest/blob/master/doc/everforest.txt
            vim.g.everforest_background = 'hard'
        end,
        lazy = false,
        priority = 1000,
    },

    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
    },

    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    -- end color schemes

    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end,
    },

    -- https://github.com/lukas-reineke/indent-blankline.nvim?tab=readme-ov-file#install
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
    }
})

-- let's set the colorscheme here since I have two to chose from, and they come from plugins
vim.cmd 'colorscheme everforest'
-- vim.cmd 'colorscheme kanagawa'
-- vim.cmd 'colorscheme tokyonight-night'

