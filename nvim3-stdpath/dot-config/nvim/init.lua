-- :h standard-paths
vim.env.XDG_DATA_HOME = vim.fn.expand('~/.config/nvim/stdpath_data')

-- print(vim.fn.stdpath("data"))
-- Default: /Users/bbkane/.local/share/nvim
-- After env change: /Users/bbkane/.config/nvim/stdpath_data/nvim

-- Add a location to packpath
-- one thing on the packpath, is, by default, "/Users/bbkane/.local/share/nvim/site"
-- which was, vim.fn.stdpath("data") .. "/site", and now we need to just set
-- that again now that we've modified the data dir

vim.opt.packpath:append(vim.fn.stdpath("data") .. "/site")

-- install packer

local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  print("Cloning packer to: " .. install_path)
  packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end


return require('packer').startup(function(use)

  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  -- My plugins here
  -- use 'foo1/bar1.nvim'
  -- use 'foo2/bar2.nvim'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
