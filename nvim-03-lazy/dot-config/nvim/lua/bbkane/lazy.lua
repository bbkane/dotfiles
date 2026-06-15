local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.api.nvim_create_user_command(
    "LazyPath",
    function(args)
        print(lazypath)
    end,
    { bang = true }
)

if not vim.uv.fs_stat(lazypath) then
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

-- nvim-tree recommends disabling netrw to avoid conflicts; must happen before
-- any plugin loads (and before nvim-tree's setup). This means :Ex/:Explore
-- (netrw) no longer work - use <leader>e (nvim-tree) to browse files instead.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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
                    -- Descriptions for <Leader> mapping groups (the <leader>f
                    -- find pickers live in the mini.pick config below).
                    { mode = 'n', keys = '<Leader>f', desc = '+find' },
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

    -- Keeping this but need to figure out how to do non-local files (like ~/...)
    {
        'nvim-mini/mini.pick',
        version = '*' ,
        config = function()
            require('mini.pick').setup({
                -- Big centered float (~90% of the editor) so long diagnostic
                -- messages have room. window.config may be a function for
                -- responsiveness; recomputed when the picker (re)opens.
                window = {
                    config = function()
                        local height = math.floor(0.9 * vim.o.lines)
                        local width = math.floor(0.9 * vim.o.columns)
                        return {
                            anchor = 'NW',
                            height = height,
                            width = width,
                            row = math.floor(0.5 * (vim.o.lines - height)),
                            col = math.floor(0.5 * (vim.o.columns - width)),
                        }
                    end,
                },
            })

            -- Wrap long lines in the picker list so full messages are readable
            -- (the diagnostic picker rows are "severity | path | message" and
            -- would otherwise run off the right edge). MiniPickStart fires once
            -- the list window exists; flip 'wrap' on it.
            vim.api.nvim_create_autocmd('User', {
                pattern = 'MiniPickStart',
                callback = function()
                    local win = require('mini.pick').get_picker_state().windows.main
                    if win then vim.wo[win].wrap = true end
                end,
            })
            -- Fuzzy-finder keymaps (leader is Space). mini.pick sets none by
            -- default; these follow the Telescope/kickstart <leader>f convention
            -- and show up under <leader>f via mini.clue.
            vim.keymap.set("n", "<leader>ff", "<cmd>Pick files<cr>",     { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", "<cmd>Pick grep_live<cr>", { desc = "Find by grep (live)" })
            vim.keymap.set("n", "<leader>fb", "<cmd>Pick buffers<cr>",   { desc = "Find buffers" })
            vim.keymap.set("n", "<leader>fh", "<cmd>Pick help<cr>",      { desc = "Find help" })
            vim.keymap.set("n", "<leader>fr", "<cmd>Pick resume<cr>",    { desc = "Resume last picker" })

            -- "Picker picker": list every registered picker (mini.pick builtins
            -- + all mini.extra pickers, which auto-register into the registry)
            -- and run the chosen one. Recipe from MiniPick's own docs.
            MiniPick.registry.registry = function()
                local items = vim.tbl_keys(MiniPick.registry)
                table.sort(items)
                local chosen = MiniPick.start({ source = { items = items, name = "Pickers", choose = function() end } })
                if chosen == nil then return end
                return MiniPick.registry[chosen]()
            end
            vim.keymap.set("n", "<leader>fp", "<cmd>Pick registry<cr>", { desc = "Find picker (registry)" })
        end,
    },

    -- Extra mini.pick pickers, incl. fuzzy LSP ones (workspace symbols, project
    -- diagnostics, references, etc). Used for the <leader> LSP maps in lsp.lua.
    -- https://github.com/nvim-mini/mini.extra
    {
        'nvim-mini/mini.extra',
        version = '*',
        -- mini.extra registers its pickers into MiniPick.registry only if
        -- mini.pick is already set up, so make that order explicit: lazy.nvim
        -- loads dependencies (and runs their config) before this plugin's config.
        dependencies = { 'nvim-mini/mini.pick' },
        config = function()
            require('mini.extra').setup()
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


    -- Native LSP (Neovim 0.11+ vim.lsp.config/enable APIs). nvim-lspconfig only
    -- ships the per-server lsp/<name>.lua data files; the actual enabling,
    -- completion, and keymaps live in lua/bbkane/lsp.lua.
    -- https://github.com/neovim/nvim-lspconfig
    {
        "neovim/nvim-lspconfig",
        -- lua/bbkane/lsp.lua's <leader>d/<leader>D diagnostics maps call into
        -- mini.pick / mini.extra (lazily, inside the keymap callbacks). Not
        -- strictly required today since both are start plugins, but declaring it
        -- documents the coupling and stays correct if these ever go lazy-loaded.
        dependencies = { 'nvim-mini/mini.pick', 'nvim-mini/mini.extra' },
        config = function()
            require("bbkane.lsp")
        end,
    },

    -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#lazynvim
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        branch = "main",
        config = function()
            local configs = require("nvim-treesitter")
            configs.install({ "bash", "go", "markdown", "markdown_inline", "python", "rust", "sql", "yaml" }):wait(300000)
        end
    },

    -- File explorer tree sidebar (VS Code-style). netrw is disabled above so it
    -- doesn't conflict. <leader>e toggles it; inside the tree, g? shows help.
    -- https://github.com/nvim-tree/nvim-tree.lua
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            require("nvim-tree").setup()
            vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "File explorer (nvim-tree)" })
        end,
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
