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

-- Python is split across two Astral servers (https://docs.astral.sh/):
--   ruff -> lint / format / code actions   ty -> type checking / hover / nav
vim.lsp.enable({ "lua_ls", "gopls", "ruff", "ty" })

local augroup = vim.api.nvim_create_augroup("bbkane_lsp", { clear = true })

-- Native completion (built in since 0.11, no completion plugin needed).
-- On LSP attach omnifunc is auto-set, so <C-x><C-o> already works; this autocmd
-- upgrades that to autotrigger - the menu pops automatically as you type.
-- Navigate with <C-n>/<C-p>, accept with <C-y>, dismiss with <C-e>.
vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end,
})

-- Run the `source.organizeImports` code action synchronously for every attached
-- client that offers it (gopls and ruff both do). Source actions apply to the
-- whole file regardless of the range, so a cursor-position range is fine.
local function organize_imports(bufnr, timeout_ms)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client:supports_method("textDocument/codeAction") then
            local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
            params.context = { only = { "source.organizeImports" }, diagnostics = {} }
            local resp = client:request_sync("textDocument/codeAction", params, timeout_ms, bufnr)
            for _, action in pairs((resp or {}).result or {}) do
                local edit = action.edit
                -- Some servers defer the edit until codeAction/resolve.
                if not edit and action.data then
                    local resolved = client:request_sync("codeAction/resolve", action, timeout_ms, bufnr)
                    edit = resolved and resolved.result and resolved.result.edit
                end
                if edit then
                    vim.lsp.util.apply_workspace_edit(edit, client.offset_encoding)
                end
            end
        end
    end
end

-- On save: organize imports first, then format. Both run synchronously (no
-- async = true) so the write includes the result, and both are no-ops when no
-- attached server supports them. (Lua format style is set in .luarc.json.)
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    callback = function(args)
        organize_imports(args.buf, 2000)
        vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 2000 })
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
