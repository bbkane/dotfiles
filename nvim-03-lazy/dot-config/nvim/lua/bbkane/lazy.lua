local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.api.nvim_create_user_command(
    "LazyPath",
    function(args)
        print(lazypath)
    end,
    { bang = true }
)

---@diagnostic disable-next-line: undefined-field
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
            vim.g.gruvbox_material_foreground = 'mix'    -- 'material', 'mix', 'original'
        end,
        lazy = false,
        priority = 1000,
    },

    -- end color schemes

    -- https://github.com/nvim-mini/mini.clue
    {
        'nvim-mini/mini.clue',
        version = '*',
        config = function()
            local miniclue = require('mini.clue')
            miniclue.setup({
                triggers = {
                    -- Leader triggers
                    { mode = 'n', keys = '<Leader>' },
                    { mode = 'x', keys = '<Leader>' },

                    -- Built-in completion
                    { mode = 'i', keys = '<C-x>' },

                    -- `g` key
                    { mode = 'n', keys = 'g' },
                    { mode = 'x', keys = 'g' },

                    -- Marks
                    { mode = 'n', keys = "'" },
                    { mode = 'n', keys = '`' },
                    { mode = 'x', keys = "'" },
                    { mode = 'x', keys = '`' },

                    -- Registers
                    { mode = 'n', keys = '"' },
                    { mode = 'x', keys = '"' },
                    { mode = 'i', keys = '<C-r>' },
                    { mode = 'c', keys = '<C-r>' },

                    -- Window commands
                    { mode = 'n', keys = '<C-w>' },

                    -- `z` key
                    { mode = 'n', keys = 'z' },
                    { mode = 'x', keys = 'z' },
                },

                clues = {
                    -- Enhance this by adding descriptions for <Leader> mapping groups
                    miniclue.gen_clues.builtin_completion(),
                    miniclue.gen_clues.g(),
                    miniclue.gen_clues.marks(),
                    miniclue.gen_clues.registers(),
                    miniclue.gen_clues.windows(),
                    miniclue.gen_clues.z(),
                },
            })
        end,
    },

    -- 2025-11-30: I was using cappyzawa/trim.nvim but it caused an issue with markdown files. When I scroll down rapidly with 'j', the first character of the line turns dark.
    -- this seems to work better.
    -- https://github.com/nvim-mini/mini.trailspace
    {
        'nvim-mini/mini.trailspace',
        version = '*',
        config = function()
            require('mini.trailspace').setup()

            vim.api.nvim_create_user_command(
                "TrimWhitespace",
                function(args)
                    -- MiniTrailspace added by `require('mini.trailspace').setup()`
                    ---@diagnostic disable-next-line: undefined-global
                    MiniTrailspace.trim()
                end,
                { bang = true }
            )
        end,
    },

    -- https://nvim-mini.org/mini.nvim/readmes/mini-diff
    -- does a bit less than gitsigns (so hopefully faster) and part of mini ecosystem
    {
        'nvim-mini/mini.diff',
        version = '*' ,

        config = function()
            require('mini.diff').setup()
        end,
    },

    -- I tried mini.indentscope but I prefer the static lines to the dynamic animated ones
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
                ensure_installed = { "bash", "go", "markdown", "python", "rust", "sql" },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

})

-- let's set the colorscheme here since I have two to chose from, and they come from plugins
-- vim.cmd 'colorscheme embark'
vim.cmd 'colorscheme everforest'
-- vim.cmd 'colorscheme kanagawa'
-- vim.cmd 'colorscheme gruvbox-material'
-- vim.cmd 'colorscheme rose-pine-moon'
-- vim.cmd 'colorscheme tokyonight-moon'
-- vim.cmd 'colorscheme moonfly'
