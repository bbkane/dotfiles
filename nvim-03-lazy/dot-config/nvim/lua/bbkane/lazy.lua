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
        "bluz71/vim-moonfly-colors",
        lazy = false,
        name = "moonfly",
        priority = 1000,
    },
    {
        "embark-theme/vim",
        lazy = false,
        priority = 1000,
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        opts = {},
        priority = 1000,
    },
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "rose-pine/neovim",
        lazy = false,
        priority = 1000,
    },
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
        "sainnhe/gruvbox-material",
        config = function()
            -- Optionally configure and load the colorscheme
            -- directly inside the plugin declaration.
            vim.g.gruvbox_material_enable_italic = true
            vim.g.gruvbox_material_background = 'medium' -- 'hard', 'medium', 'soft'
            vim.g.gruvbox_material_foreground = 'mix' -- 'material', 'mix', 'original'
        end,
        lazy = false,
        priority = 1000,
    },

    -- end color schemes

    -- https://github.com/cappyzawa/trim.nvim
    {
        "cappyzawa/trim.nvim",
        opts = {
            highlight = true,
            trim_last_line = false,
        },
    },

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
    },


    -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#lazynvim
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")
            configs.setup({
                ensure_installed = {"bash", "go", "python", "sql"},
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

    {
        "saghen/blink.cmp",
        opts = {
            fuzzy = { implementation = "lua" },
            completion = {
                menu = {
                    auto_show = false,
                },
            },
            keymap = { preset = 'default' },
        },
    },

})

-- let's set the colorscheme here since I have two to chose from, and they come from plugins
-- vim.cmd 'colorscheme embark'
-- vim.cmd 'colorscheme everforest'
-- vim.cmd 'colorscheme kanagawa'
-- vim.cmd 'colorscheme gruvbox-material'
-- vim.cmd 'colorscheme rose-pine-moon'
-- vim.cmd 'colorscheme tokyonight-moon'
vim.cmd 'colorscheme moonfly'
