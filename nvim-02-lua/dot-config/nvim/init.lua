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
-- :lua =vim.opt.packpath:get()
vim.opt.packpath:append(path.join(vim.fn.stdpath("data"), "site"))

require("bbkane.common")

require("bbkane.packer")
