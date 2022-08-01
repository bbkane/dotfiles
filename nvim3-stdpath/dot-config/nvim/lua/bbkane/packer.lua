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
        end
    }

    -- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function() 
            require('nvim-treesitter.install').update({ with_sync = true }) 

            require('nvim-treesitter.configs').setup({
                -- A list of parser names, or "all"
                ensure_installed = { "markdown", "markdown_inline", "bash", "python", "go" },
                highlight = {
                    enable = true,
                },
            })
        end,
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
      require('packer').sync()
    end
end)
