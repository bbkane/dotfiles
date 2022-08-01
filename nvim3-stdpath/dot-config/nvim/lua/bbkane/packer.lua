local path = require("bbkane.path")

-- this must be in packpath (see ../../init.lua)
local packer_install_path = path.join(vim.fn.stdpath('data'), '/site/pack/packer/start/packer.nvim')
if vim.fn.empty(vim.fn.glob(packer_install_path)) > 0 then
  print("Cloning packer to: " .. packer_install_path)
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_install_path})
  vim.cmd [[packadd packer.nvim]]
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost packer_init.lua source <afile> | PackerCompile
  augroup end
]])

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
                ensure_installed = { "markdown", "markdown_inline", "bash", "python", "go" },
                highlight = {
                    enable = true,
                },
            })
        end,
    }

    -- TODO: mv to common.lua
    vim.o.termguicolors = true

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
        -- TODO: can I use a config function for the other ones too?
        config = function()
            require('gitsigns').setup()
        end
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      require('packer').sync()
    end
end)
