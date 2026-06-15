local bbkane_augroup = vim.api.nvim_create_augroup('bbkane_augroup', { clear = true })

-- Filetype detection. Indentation/options for these filetypes live in
-- ftplugin/<filetype>.lua (e.g. ftplugin/gitconfig.lua for tabs-not-spaces).
vim.filetype.add({
    extension = {
        src = "xml",
        ["code-workspace"] = "jsonc",
    },
    filename = {
        [".gitconfig"] = "gitconfig",
    },
    pattern = {
        ["gitconfig_.*"] = "gitconfig",
    },
})

-- " http://stackoverflow.com/a/18444962/2958070
-- " custom file templates
-- augroup templates
--     au!
--     autocmd BufNewFile *.* silent! execute '0r ~/.config/nvim/templates/skeleton.'.expand("<afile>:e")
-- augroup END
vim.api.nvim_create_autocmd({ 'BufNewFile' }, {
    group = bbkane_augroup,
    pattern = { "*.py", "*.pl", "*.html", "*.sh" },
    command = "silent! execute '0r ~/.config/nvim/templates/skeleton.'.expand('<afile>:e')"
})


