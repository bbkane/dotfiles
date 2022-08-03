local path = require("bbkane.path")

-- When in doubt: :PackerSync and :PackerCompile

-- this must be in packpath (see ../../init.lua)
local packer_install_path = path.join(vim.fn.stdpath('data'), '/site/pack/packer/start/packer.nvim')
if vim.fn.empty(vim.fn.glob(packer_install_path)) > 0 then
    print("Cloning packer to: " .. packer_install_path)
    packer_bootstrap = vim.fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
        packer_install_path })
    vim.cmd [[packadd packer.nvim]]
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost packer_init.lua source <afile> | PackerCompile
  augroup end
]])

-- log at:  ~/.cache/nvim/packer.nvim.log
return require('packer').startup(function(use)

    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end,
    }

    -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            require('nvim-treesitter.install').update({ with_sync = true })
        end,
        config = function()
            require('nvim-treesitter.configs').setup({
                -- A list of parser names, or "all"
                ensure_installed = { "markdown", "markdown_inline", "bash", "python", "go", "lua", },
                highlight = {
                    enable = true,
                },
            })
        end,
    }

    use {
        'marko-cerovac/material.nvim',
        config = function()
            vim.g.material_style = "palenight"
            -- vim.cmd 'colorscheme material'
        end,
    }

    -- -- I really like this one for markdown, but not so much for Lua code
    -- use "rebelot/kanagawa.nvim"
    -- vim.cmd("colorscheme kanagawa")
    use {
        "rebelot/kanagawa.nvim",
        config = function()
            vim.cmd 'colorscheme kanagawa'
        end,
    }

    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end,
    }

    -- https://github.com/lukas-reineke/indent-blankline.nvim#with-context-indent-highlighted-by-treesitter
    use {
        "lukas-reineke/indent-blankline.nvim",
        config = function()

            vim.opt.list = true
            vim.opt.listchars:append "space:⋅"
            vim.opt.listchars:append "eol:↴"

            require("indent_blankline").setup({
                space_char_blankline = " ",
                show_current_context = true,
                show_current_context_start = true,
            })
        end,
    }

    use {
        "lukas-reineke/lsp-format.nvim",
        config = function()
            require("lsp-format").setup()
        end,
    }

    use {
        -- :checkhealth mason
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    }

    use {
        "neovim/nvim-lspconfig",
        config = function()
            -- TODO: nvim-cmp this?
            -- https://github.com/neovim/nvim-lspconfig#suggested-configuration

            -- Mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            local opts = { noremap = true, silent = true }
            vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
            vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

            -- Use an on_attach function to only map the following keys
            -- after the language server attaches to the current buffer
            local on_attach = function(client, bufnr)

                require("lsp-format").on_attach(client)

                -- Enable completion triggered by <c-x><c-o>
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                -- Mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local bufopts = { noremap = true, silent = true, buffer = bufnr }
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

            local lspconfig = require("lspconfig")

            lspconfig['gopls'].setup {
                on_attach = on_attach,
            }

            lspconfig['pyright'].setup {
                on_attach = on_attach,
            }
            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
            lspconfig['sumneko_lua'].setup {
                on_attach = on_attach,

                settings = {
                    Lua = {
                        runtime = {
                            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                            version = 'LuaJIT',
                        },
                        diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = { 'vim' },
                        },
                        workspace = {
                            -- Make the server aware of Neovim runtime files
                            library = vim.api.nvim_get_runtime_file("", true),
                        },
                        -- Do not send telemetry data containing a randomized but unique identifier
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            }

        end,
        requires = { "lukas-reineke/lsp-format.nvim" },
    }

    use {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                -- This doesn't seem to work, so just install manually...
                -- NOTE: this ONLY installs lsps, so moving to mason-tool-installer
                -- ensure_installed = { "black", "gopls", "flake8", "pyright", "shellcheck", "sumneko_lua", }
            })
        end,
        requires = { "neovim/nvim-lspconfig", "williamboman/mason.nvim" },
    }

    use {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "black",
                    "flake8",
                    "gopls",
                    "lua-language-server", -- sumneko_lua in lsp
                    "pyright",
                    "shellcheck",
                },
                auto_update = false,
                run_on_start = true, -- Use MasonToolsUpdate to run this
            })
        end,
        requires = { "williamboman/mason.nvim" },
    }

    use {
        -- https://github.com/jose-elias-alvarez/null-ls.nvim/discussions/593
        -- :NullLsInfo
        -- format with :lua vim.lsp.buf.formatting()
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
            -- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save#sync-formatting
            -- Trying lsp-format instead
            local null_ls = require("null-ls")
            null_ls.setup({
                -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
                sources = {
                    null_ls.builtins.formatting.black,
                    null_ls.builtins.diagnostics.flake8,
                    null_ls.builtins.diagnostics.shellcheck,
                },

                -- you can reuse a shared lspconfig on_attach callback here
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        require("lsp-format").on_attach(client)
                    end
                end,

            })
        end,
        requires = { "lukas-reineke/lsp-format.nvim", 'nvim-lua/plenary.nvim' },
    }


    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        print("Boostrap complete. Syncing")
        require('packer').sync()
    end
end)
