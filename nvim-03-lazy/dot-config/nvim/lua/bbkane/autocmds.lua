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

-- Surface LSP progress so I can tell when a server is done loading/indexing
-- (gopls "Loading packages", rust_analyzer "Indexing", ...). The $/progress
-- value has kind = begin | report | end. Only "begin"/"end" are notified - the
-- frequent "report" (percentage) updates would flood :messages.
vim.api.nvim_create_autocmd('LspProgress', {
    group = bbkane_augroup,
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local val = ev.data.params.value
        if not client or type(val) ~= 'table' then
            return
        end
        if val.kind == 'begin' then
            vim.notify(client.name .. ': ' .. (val.title or 'working') .. '…', vim.log.levels.INFO)
        elseif val.kind == 'end' then
            vim.notify(client.name .. ': ' .. (val.title or '') .. ' done', vim.log.levels.INFO)
        end
    end,
})


