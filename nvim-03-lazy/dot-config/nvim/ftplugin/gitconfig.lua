-- gitconfig wants real tabs, not spaces.
-- https://stackoverflow.com/a/1878992
-- https://gist.github.com/LunarLambda/4c444238fb364509b72cfb891979f1dd#tabs-only
vim.bo.expandtab = false
vim.bo.tabstop = 8
vim.bo.shiftwidth = 0
vim.bo.softtabstop = 0
vim.opt_local.smarttab = true
