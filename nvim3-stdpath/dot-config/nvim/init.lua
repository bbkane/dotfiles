path = require("bbkane.path")

-- Put all nvim files under ~/.config/nvim

-- :h standard-paths
vim.env.XDG_DATA_HOME = vim.fn.expand('~/.config/nvim/stdpath_data')

-- print(vim.fn.stdpath("data"))
-- Default: /Users/bbkane/.local/share/nvim
-- After env change: /Users/bbkane/.config/nvim/stdpath_data/nvim

-- Add a location to packpath
-- one thing on the packpath, is, by default, "/Users/bbkane/.local/share/nvim/site"
-- which was, vim.fn.stdpath("data") .. "/site", and now we need to just set
-- that again now that we've modified the data dir

-- this is needed for packer, but it's global so keep it here
vim.opt.packpath:append(path.join(vim.fn.stdpath("data"), "site"))

require("bbkane.common")

-- install packer

local packer_install_path = path.join(vim.fn.stdpath('data'), '/site/pack/packer/start/packer.nvim')
if vim.fn.empty(vim.fn.glob(packer_install_path)) > 0 then
  print("Cloning packer to: " .. packer_install_path)
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_install_path})
  vim.cmd [[packadd packer.nvim]]
end


return require('packer').startup(function(use)

  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
