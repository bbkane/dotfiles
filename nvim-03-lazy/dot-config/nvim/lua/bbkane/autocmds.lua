local bbkane_augroup = vim.api.nvim_create_augroup('bbkane_augroup', { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = bbkane_augroup,
    pattern = { ".gitconfig,", "gitconfig_*" },
    -- https://stackoverflow.com/a/1878992
    -- https://gist.github.com/LunarLambda/4c444238fb364509b72cfb891979f1dd#tabs-only
    command = "set filetype=gitconfig noexpandtab tabstop=8 shiftwidth=0 softtabstop=0 smarttab"
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = bbkane_augroup,
    pattern = "*.src",
    command = "set filetype=xml"
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = bbkane_augroup,
    pattern = "*.code-workspace",
    command = "set filetype=jsonc"
})

-- " http://stackoverflow.com/a/18444962/2958070
-- " custom file templates
-- augroup templates
--     au!
--     autocmd BufNewFile *.* silent! execute '0r ~/.config/nvim/templates/skeleton.'.expand("<afile>:e")
-- augroup END
vim.api.nvim_create_autocmd({ 'BufNewFile' }, {
    group = bbkane_augroup,
    pattern = "*.*",
    command = "silent! execute '0r ~/.config/nvim/templates/skeleton.'.expand('<afile>:e')"
})

