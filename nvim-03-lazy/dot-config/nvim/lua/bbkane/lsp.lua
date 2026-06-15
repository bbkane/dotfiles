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
-- bashls -> completion / hover; auto-discovers shellcheck (diagnostics) and
--           shfmt (formatting) on $PATH. Per-server shfmt opts in lsp/bashls.lua.
vim.lsp.enable({ "bashls", "gopls", "lua_ls", "ruff", "rust_analyzer", "ty" })

local augroup = vim.api.nvim_create_augroup("bbkane_lsp", { clear = true })

-- Native completion (built in since 0.11, no completion plugin needed).
-- On LSP attach omnifunc is auto-set, so <C-x><C-o> already works; this autocmd
-- upgrades that to autotrigger - the menu pops automatically as you type.
vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end,
})

-- Completion menu UX: show the menu (even for a single match) and highlight the
-- top match, but do NOT insert it into the buffer (noinsert) until accepted - so
-- typing a trigger like "." opens the list with the best match highlighted, and
-- the highlight follows as you keep typing to fuzzy-narrow. <Tab> accepts the
-- highlighted match, <C-e> dismisses.
vim.o.completeopt = "menu,menuone,noinsert,fuzzy"

-- <C-Space>: open the completion menu, or - if it is already open - accept the
-- highlighted match (selecting the top match first in the rare case none is
-- highlighted). Also mapped to <C-@>, which is what some terminals send for it.
local function complete_or_accept()
    if vim.fn.pumvisible() == 0 then
        return "<C-x><C-o>"
    end
    return vim.fn.complete_info({ "selected" }).selected == -1 and "<C-n><C-y>" or "<C-y>"
end
vim.keymap.set("i", "<C-Space>", complete_or_accept, { expr = true, desc = "Open/accept completion" })
vim.keymap.set("i", "<C-@>", complete_or_accept, { expr = true, desc = "Open/accept completion" })

-- CodeLens (gopls' actionable hints, e.g. "run go mod tidy" on go.mod, generate,
-- govulncheck). Neovim 0.12's codelens is a self-refreshing capability (like
-- inlay hints), so enabling it globally is enough - supporting clients attach
-- automatically and it re-renders on buffer changes. Run the lens under the
-- cursor with <leader>cl. (gopls' "run test" lens is opt-in via lsp/gopls.lua.)
vim.lsp.codelens.enable(true)

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
--   [d / ]d  prev/next diagnostic    <C-w>d  show diagnostic float under cursor
-- go-to-definition isn't a default, so add it:
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: go to definition" })

-- Custom current-buffer diagnostics picker. mini.extra's diagnostic picker
-- always prefixes each row with the file path; for a single buffer that path is
-- redundant and eats horizontal room, so this builds the items by hand and
-- formats each row as just "severity | message". Choosing an item jumps to it
-- (mini.pick's default_choose uses bufnr/lnum/col), and rows are tinted by
-- severity to match mini.extra's look.
local diag_ns = vim.api.nvim_create_namespace("bbkane_diag_picker")
local diag_hl = {
    [vim.diagnostic.severity.ERROR] = "DiagnosticFloatingError",
    [vim.diagnostic.severity.WARN] = "DiagnosticFloatingWarn",
    [vim.diagnostic.severity.INFO] = "DiagnosticFloatingInfo",
    [vim.diagnostic.severity.HINT] = "DiagnosticFloatingHint",
}
local function buffer_diagnostics_picker()
    local pick = require("mini.pick")
    local items = {}
    for _, d in ipairs(vim.diagnostic.get(0)) do
        local sev = (vim.diagnostic.severity[d.severity] or " "):sub(1, 1)
        table.insert(items, {
            text = string.format("%s │ %d │ %s", sev, d.lnum + 1, d.message:gsub("\n", " ")),
            bufnr = d.bufnr,
            -- vim.diagnostic positions are 0-based; mini.pick wants 1-based.
            lnum = d.lnum + 1,
            col = d.col + 1,
            severity = d.severity,
        })
    end
    table.sort(items, function(a, b)
        return (a.severity or 0) < (b.severity or 0) -- ERROR(1) first, HINT(4) last
    end)
    -- Tint each row by severity (line_hl_group covers the whole line, wrap-safe).
    local show = function(buf_id, items_to_show, query)
        pick.default_show(buf_id, items_to_show, query)
        vim.api.nvim_buf_clear_namespace(buf_id, diag_ns, 0, -1)
        for i, item in ipairs(items_to_show) do
            local hl = diag_hl[item.severity]
            if hl then
                vim.api.nvim_buf_set_extmark(buf_id, diag_ns, i - 1, 0, { line_hl_group = hl })
            end
        end
    end
    pick.start({ source = { name = "Buffer diagnostics", items = items, show = show } })
end

-- Extra <leader> maps (mini.clue shows these under <leader>):
--   <leader>d   THIS buffer's diagnostics as "severity | message" (custom, above)
--   <leader>D   project diagnostics (all loaded buffers), VS Code "Problems"-ish
--   <leader>ws  workspace symbol search (VS Code Ctrl+T) via mini.extra
--   <leader>cl  run the code lens under the cursor (e.g. gopls "run test")
-- (Diagnostic float for the line under the cursor is the built-in <C-w>d.)
-- Note: project diagnostics only cover servers' loaded buffers, not a full
-- workspace scan like VS Code's Problems panel.
vim.keymap.set("n", "<leader>d", buffer_diagnostics_picker, { desc = "LSP: buffer diagnostics (picker)" })
vim.keymap.set("n", "<leader>D", function()
    require("mini.extra").pickers.diagnostic({ scope = "all" })
end, { desc = "LSP: project diagnostics (picker)" })
vim.keymap.set("n", "<leader>ws", function()
    require("mini.extra").pickers.lsp({ scope = "workspace_symbol" })
end, { desc = "LSP: workspace symbols (picker)" })
vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, { desc = "LSP: run code lens" })

vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
})

-- Toggle ALL diagnostics (virtual text, underlines, signs) on/off globally.
vim.api.nvim_create_user_command("DiagnosticEnable", function()
    vim.diagnostic.enable(true)
end, { desc = "Enable all diagnostics" })
vim.api.nvim_create_user_command("DiagnosticDisable", function()
    vim.diagnostic.enable(false)
end, { desc = "Disable all diagnostics" })
