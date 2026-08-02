local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.api.nvim_create_user_command(
    "LazyPath",
    function(_)
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
    -- {
    --     "bluz71/vim-moonfly-colors",
    --     lazy = false,
    --     name = "moonfly",
    --     priority = 1000,
    -- },
    -- {
    --     "embark-theme/vim",
    --     lazy = false,
    --     priority = 1000,
    -- },
    -- {
    --     "folke/tokyonight.nvim",
    --     lazy = false,
    --     opts = {},
    --     priority = 1000,
    -- },
    -- {
    --     "rebelot/kanagawa.nvim",
    --     lazy = false,
    --     priority = 1000,
    -- },
    -- {
    --     "rose-pine/neovim",
    --     lazy = false,
    --     priority = 1000,
    -- },
    -- {
    --     "sainnhe/everforest",
    --     config = function()
    --         -- https://github.com/sainnhe/everforest/blob/master/doc/everforest.txt
    --         vim.g.everforest_background = 'hard'
    --     end,
    --     lazy = false,
    --     priority = 1000,
    -- },
    -- {
    --     "sainnhe/gruvbox-material",
    --     config = function()
    --         -- Optionally configure and load the colorscheme
    --         -- directly inside the plugin declaration.
    --         vim.g.gruvbox_material_enable_italic = true
    --         vim.g.gruvbox_material_background = 'medium' -- 'hard', 'medium', 'soft'
    --         vim.g.gruvbox_material_foreground = 'mix'    -- 'material', 'mix', 'original'
    --     end,
    --     lazy = false,
    --     priority = 1000,
    -- },

    -- end color schemes

    -- https://github.com/MeanderingProgrammer/render-markdown.nvim
    -- Makes reading super convenient, but can disturb editong. Disable if needed with :RenderMarkdown disable
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' }, -- if you use standalone mini plugins
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            completions = {
                lsp = {
                    -- 2026-07-26 - this throws a stacktrace when enabled
                    enabled = false,
                },
            },
            anti_conceal = {
                enabled = false,
            },
            code = {
                enabled = false,
            },
            heading = {
                enabled = false,
            },
            latex = { enabled = false },
            paragraph = { enabled = false },
            dash = { enabled = false },
            document = { enabled = false },
            bullet = { enabled = true },
            checkbox = { enabled = true },
            quote = { enabled = true },
            -- Rendered pipe-table borders do not support true cell wrapping.
            -- Keep raw markdown tables so normal line wrapping stays readable.
            pipe_table = { enabled = false },
            link = { enabled = true },
            sign = { enabled = false },
            inline_highlight = { enabled = false },
            html = { enabled = false },
            yaml = { enabled = false },
        },

    },

    -- https://github.com/ice345/markdown-table-wrap.nvim
    -- Wraps long markdown table cell content while preserving rendered table UX.
    {
        'ice345/markdown-table-wrap.nvim',
        ft = { 'markdown', 'md', 'quarto', 'rmarkdown' },
        opts = {
            -- Keep a render-markdown-like in-buffer experience.
            preview_mode = 'inline',
            auto_preview = true,
            render_all = true,
            -- Avoid source line leakage under overlays on wrapped terminals.
            inline_wrap_scope = 'always',
            inline_disable_wrap = true,
            inline_viewport_scrolling = false,
            fit_to_window = true,
            dim_source = false,
            highlight_preset = 'auto',
        },
        keys = {
            { '<leader>mt', '<cmd>MarkdownTableTogglePreview<CR>',        desc = 'Toggle markdown table preview' },
            { '<leader>mr', '<cmd>MarkdownTableToggleReader<CR>',         desc = 'Toggle markdown table reader/source' },
            { '<leader>mi', '<cmd>MarkdownTableToggleInline<CR>',         desc = 'Toggle markdown table inline view' },
            { '<leader>me', '<cmd>MarkdownTableEditSource<CR>',           desc = 'Edit markdown source' },
            { '<leader>mq', '<cmd>MarkdownTableToggleInlineViewport<CR>', desc = 'Toggle table inline viewport' },
        },
    },

    -- Save an image from the system clipboard next to the current file and
    -- insert a link to it: notes.md -> notes.assets/2026-07-28-14-30-00.png
    -- Markdown only: loaded by filetype, and the <M-v> keymap is buffer-local in
    -- ftplugin/markdown.lua.
    -- Needs pngpaste (macOS), wl-clipboard (Wayland) or xclip (X11); the plugin
    -- picks the right one. `:checkhealth img-clip` verifies it.
    -- https://github.com/HakonHarnes/img-clip.nvim
    {
        "HakonHarnes/img-clip.nvim",
        ft = "markdown",
        opts = {
            default = {
                dir_path = function()
                    return vim.fn.expand("%:t:r") .. ".assets"
                end,
                -- .assets goes next to the file, not the cwd
                relative_to_current_file = true,
                file_name = "%Y-%m-%d-%H-%M-%S",
                prompt_for_file_name = false,
                -- extension is only used for raw clipboard image data; copied
                -- files and drag-and-drop keep their own extension
                extension = "png",
                -- copy pasted file paths into .assets too, instead of linking
                -- to wherever the original happens to live
                copy_images = true,
                drag_and_drop = { insert_mode = true },
            },
        },
    },

    -- https://github.com/nvim-mini/mini.clue
    {
        'nvim-mini/mini.clue',
        version = '*',
        config = function()
            local miniclue = require('mini.clue')
            miniclue.setup({
                window = {
                    config = function(buf_id)
                        -- Get all lines currently populated inside the clue buffer
                        local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)

                        -- Calculate the exact column length of the longest line
                        local max_width = 0
                        for _, line in ipairs(lines) do
                            -- Use strdisplaywidth to accurately count multi-byte or tab characters
                            local line_width = vim.fn.strdisplaywidth(line)
                            if line_width > max_width then
                                max_width = line_width
                            end
                        end

                        -- Enforce a minimum window width of 15 and account for text borders
                        local final_width = math.max(15, max_width + 2)

                        return {
                            -- 'editor' anchors it relative to the global workspace
                            relative = 'editor',
                            -- Adjust width dynamically to match your longest text line
                            width = final_width,
                            -- Keep standard positioning values (adjust row/col coordinates if preferred)
                            row = vim.o.lines - 2,
                            col = vim.o.columns,
                            anchor = 'SE',
                        }
                    end,
                },
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
                    { mode = 'n', keys = '<Leader>c',  desc = '+code' },
                    { mode = 'n', keys = '<Leader>d',  desc = '+diagnostics (buffer)' },
                    { mode = 'n', keys = '<Leader>D',  desc = '+diagnostics (project)' },
                    { mode = 'n', keys = '<Leader>f',  desc = '+find' },
                    { mode = 'n', keys = '<Leader>m',  desc = '+markdown' },
                    { mode = 'n', keys = '<Leader>t',  desc = '+table (vim-table-mode)' },
                    { mode = 'n', keys = '<Leader>td', desc = '+delete (row/col)' },
                    { mode = 'n', keys = '<Leader>tf', desc = '+formula (add/eval)' },
                    { mode = 'n', keys = '<Leader>ti', desc = '+insert (column)' },
                    { mode = 'n', keys = '<Leader>w',  desc = '+window' },
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

    -- Icon provider (file/LSP-kind/etc. glyphs). mini.pick / mini.extra
    -- auto-detect it, and the <leader>ws symbol picker in lsp.lua uses
    -- MiniIcons.get('lsp', kind) for the kind-icon column.
    -- https://github.com/nvim-mini/mini.icons
    {
        'nvim-mini/mini.icons',
        version = '*',
        config = function()
            require('mini.icons').setup()
        end,
    },

    -- Keeping this but need to figure out how to do non-local files (like ~/...)
    {
        'nvim-mini/mini.pick',
        version = '*',
        -- Setup, finder keymaps, and custom pickers live in lua/bbkane/pickers.lua.
        config = function()
            require("bbkane.pickers")
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
                function(_)
                    -- MiniTrailspace added by `require('mini.trailspace').setup()`
                    ---@diagnostic disable-next-line: undefined-global
                    MiniTrailspace.trim()
                end,
                { bang = true }
            )
        end,
    },

    -- Auto-close brackets/quotes ( ) [ ] { } " ' ` as you type.
    -- https://github.com/nvim-mini/mini.pairs
    {
        'nvim-mini/mini.pairs',
        version = '*',
        config = function()
            require('mini.pairs').setup({
                mappings = {
                    ["`"] = false,
                }
            })
        end,
    },

    -- Auto-align Markdown tables as you type (and :TableModeRealign to fix an
    -- existing one). Loaded only for markdown; table_mode_corner = '|' makes the
    -- separator row markdown-style (|---|---| instead of the default |---+---|).
    -- https://github.com/dhruvasagar/vim-table-mode
    {
        "dhruvasagar/vim-table-mode",
        ft = "markdown",
        init = function()
            vim.g.table_mode_corner = "|"
            vim.g.table_mode_disable_mappings = 1
            vim.g.table_mode_disable_tableize_mappings = 1
        end,
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                command = "silent TableModeEnable",
            })

            -- Create mappings with descriptions (since vim-table-mode's are disabled)
            vim.keymap.set('n', '<leader>tm', '<cmd>call tablemode#Toggle()<CR>', { desc = 'Toggle table mode' })
            vim.keymap.set('n', '<leader>tr', '<cmd>call tablemode#table#Realign(".")<CR>', { desc = 'Realign table' })
            vim.keymap.set('n', '<leader>ts', '<cmd>TableSort<CR>', { desc = 'Sort table' })
            vim.keymap.set('n', '<leader>tt', '<cmd>Tableize<CR>', { desc = 'Tableize' })
            vim.keymap.set('x', '<leader>tt', ':<C-u>Tableize<CR>', { desc = 'Tableize' })
            vim.keymap.set('n', '<leader>tfa', '<cmd>TableAddFormula<CR>', { desc = 'Add formula' })
            vim.keymap.set('n', '<leader>tfe', '<cmd>TableEvalFormulaLine<CR>', { desc = 'Eval formula' })
            vim.keymap.set('n', '<leader>tdc', '<cmd>call tablemode#spreadsheet#cell#DeleteColumn()<CR>',
                { desc = 'Delete column' })
            vim.keymap.set('n', '<leader>tdd', '<cmd>call tablemode#spreadsheet#cell#DeleteRow()<CR>',
                { desc = 'Delete row' })
            vim.keymap.set('n', '<leader>tic', '<cmd>call tablemode#spreadsheet#cell#InsertColumn(1)<CR>',
                { desc = 'Insert column after' })
            vim.keymap.set('n', '<leader>tiC', '<cmd>call tablemode#spreadsheet#cell#InsertColumn(0)<CR>',
                { desc = 'Insert column before' })
            vim.keymap.set('n', '<leader>t?', '<cmd>call tablemode#spreadsheet#cell#EchoCell()<CR>',
                { desc = 'Echo cell' })
        end,
    },

    -- https://nvim-mini.org/mini.nvim/readmes/mini-diff
    -- does a bit less than gitsigns (so hopefully faster) and part of mini ecosystem
    {
        'nvim-mini/mini.diff',
        version = '*',

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

    -- https://github.com/tpope/vim-rsi
    {
        "tpope/vim-rsi",
    },

    -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#lazynvim
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        branch = "main",
        config = function()
            local configs = require("nvim-treesitter")
            configs.install({ "bash", "diff", "gitcommit", "go", "markdown", "markdown_inline", "python", "rust", "sql",
                "yaml" }):wait(300000)
        end
    },

    -- File explorer tree sidebar (VS Code-style). netrw is disabled above so it
    -- doesn't conflict. <leader>e toggles it; inside the tree, g? shows help.
    -- https://github.com/nvim-tree/nvim-tree.lua
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            require("nvim-tree").setup({
                view = {
                    side = "right",
                },
            })
            vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "File explorer (nvim-tree)" })
        end,
    },

    -- -- GitHub Copilot inline (ghost-text) suggestions. Needs Node.js on $PATH and
    -- -- a one-time `:Copilot auth` to sign in. Insert-mode keys = copilot's
    -- -- Alt-based defaults, which work now that left-Option sends <M-...> in WezTerm:
    -- --   <M-]>/<M-[> next/prev   <M-l> accept   <C-]> dismiss
    -- -- Set explicitly so they stay put if the plugin's defaults ever change, and so
    -- -- the Ctrl cluster (incl. <C-k> for the markdown link in ftplugin/markdown.lua)
    -- -- stays free.
    -- -- https://github.com/zbirenbaum/copilot.lua
    -- {
    --     "zbirenbaum/copilot.lua",
    --     cmd = "Copilot",
    --     event = "InsertEnter",
    --     config = function()
    --         require("copilot").setup({
    --             suggestion = {
    --                 enabled = true,
    --                 auto_trigger = true, -- show suggestions as you type
    --                 keymap = {
    --                     accept = "<M-l>",
    --                     next = "<M-]>",
    --                     prev = "<M-[>",
    --                     dismiss = "<C-]>",
    --                 },
    --             },
    --             -- Ghost text only; the separate multi-suggestion panel adds UI
    --             -- surface we don't need.
    --             panel = { enabled = false },
    --         })
    --     end,
    -- },

})

-- Using the built-in default colorscheme (no `:colorscheme` call), so the
-- markdown heading highlight overrides in common.lua aren't reset. Re-enable one
-- of these to switch themes (but then move those overrides to a ColorScheme
-- autocmd, since loading a colorscheme resets highlights).
-- vim.cmd 'colorscheme embark'
-- vim.cmd 'colorscheme everforest'
-- vim.cmd 'colorscheme kanagawa'
-- vim.cmd 'colorscheme gruvbox-material'
-- vim.cmd 'colorscheme rose-pine-moon'
-- vim.cmd 'colorscheme tokyonight-moon'
-- vim.cmd 'colorscheme moonfly'
