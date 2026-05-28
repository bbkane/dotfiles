-- Native LSP, using the Neovim 0.11+/0.12 APIs (vim.lsp.config / vim.lsp.enable).
-- The nvim-lspconfig plugin ships the base lsp/<name>.lua data files (cmd,
-- filetypes, root_markers); we just enable the servers we want and turn on
-- native completion. Per-server overrides live in their own lsp/<name>.lua:
--   - lsp/gopls.lua  (gopls settings)
--   - lua_ls         needs no overrides; its settings (runtime, vim global,
--                    workspace library) come from .luarc.json in this directory.
--
-- The server binaries are NOT installed here - install them yourself (see
-- README.md "LSP Install"); this assumes they're on $PATH.

vim.lsp.enable({ "lua_ls", "gopls" })

-- Native completion (built in since 0.11, no completion plugin needed).
-- On LSP attach omnifunc is auto-set, so <C-x><C-o> already works; this autocmd
-- upgrades that to autotrigger - the menu pops automatically as you type.
-- Navigate with <C-n>/<C-p>, accept with <C-y>, dismiss with <C-e>.
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("bbkane_lsp", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end,
})

-- Neovim 0.11+ already provides default LSP keymaps on attach:
--   grn  rename            gra  code action        grr  references
--   gri  implementation    grt  type definition    gO   document symbols
--   K    hover             <C-s> signature help (insert mode)
--   [d / ]d  prev/next diagnostic
-- go-to-definition isn't a default, so add it:
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: go to definition" })

vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
})
