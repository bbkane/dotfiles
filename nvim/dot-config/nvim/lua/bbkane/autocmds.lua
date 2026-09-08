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

-- Record opened files in the `frecency` CLI database (see the `frecency` picker
-- in lua/bbkane/pickers.lua, <leader>fR). BufReadPost fires for files read off
-- disk and BufWritePost catches brand-new files once they exist. Skip
-- unnamed/scratch buffers, non-`file` buffers (help, terminals, fugitive, oil,
-- ...) and anything that isn't a readable real file so the db only ever holds
-- paths worth reopening. `frecency add` bumps the score of an existing key, so
-- repeats are fine. Run detached (vim.system, no :wait) to keep opening files
-- fast.
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
    group = bbkane_augroup,
    callback = function(ev)
        if vim.bo[ev.buf].buftype ~= '' then
            return
        end
        local path = vim.fn.fnamemodify(ev.file or '', ':p')
        if path == '' or vim.fn.filereadable(path) ~= 1 then
            return
        end
        if vim.fn.executable('frecency') ~= 1 then
            return
        end
        vim.system({ 'frecency', 'add', '--key', path })
    end,
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


