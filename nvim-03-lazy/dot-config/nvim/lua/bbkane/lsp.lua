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

-- Extra <leader> maps (mini.clue shows these under <leader>):
--   <leader>D   project diagnostics (all loaded buffers), VS Code "Problems"-ish
--   <leader>ws  workspace symbol search (VS Code Ctrl+T) via mini.extra
--   <leader>cl  run the code lens under the cursor (e.g. gopls "run test")
-- (Diagnostic float for the line under the cursor is the built-in <C-w>d.)
-- (THIS buffer's diagnostics picker, <leader>d, lives in lua/bbkane/pickers.lua.)
-- Note: project diagnostics only cover servers' loaded buffers, not a full
-- workspace scan like VS Code's Problems panel.
vim.keymap.set("n", "<leader>D", function()
    require("mini.extra").pickers.diagnostic({ scope = "all" })
end, { desc = "LSP: project diagnostics (picker)" })
-- Compact 3-column display for the workspace-symbol picker. mini.extra prepends
-- the full absolute path to every row ("path│lnum│col│ [Kind] name"), which is
-- very noisy. This custom `show` (passed via opts, which mini.extra merges over
-- its defaults) re-renders each row as aligned columns:
--     basename │ line │ <kind icon> name
-- The basename/line columns are dimmed (Comment) and the kind icon is colored
-- with its mini.icons highlight. Matching still runs on the full item.text, so
-- filtering by name (or path) is unchanged.
local ws_symbol_ns = vim.api.nvim_create_namespace("bbkane_ws_symbols")
local function workspace_symbol_show(buf_id, items, _query)
    local MiniIcons = require("mini.icons")

    local rows, base_w, lnum_w = {}, 0, 0
    for i, item in ipairs(items) do
        -- Only the symbol suffix uses "│ " (pipe + space); position separators
        -- are bare "│", so this grabs "[Kind] name in Container (deprecated)".
        local sym = item.text:match("│ (.-)$") or item.text
        local kind = sym:match("^%[(.-)%]") or "Unknown"
        local name = sym:gsub("^%[.-%]%s*", "")
        local base = item.path and vim.fn.fnamemodify(item.path, ":t") or ""
        local lnum = tostring(item.lnum or 1)
        local icon, icon_hl = MiniIcons.get("lsp", kind)
        rows[i] = { base = base, lnum = lnum, icon = icon or "", icon_hl = icon_hl, name = name }
        base_w = math.max(base_w, vim.fn.strdisplaywidth(base))
        lnum_w = math.max(lnum_w, #lnum)
    end

    local sep = " │ "
    local lines, marks = {}, {}
    for i, r in ipairs(rows) do
        local base_field = r.base .. string.rep(" ", base_w - vim.fn.strdisplaywidth(r.base))
        local lnum_field = string.rep(" ", lnum_w - #r.lnum) .. r.lnum
        local prefix = base_field .. sep .. lnum_field .. sep
        lines[i] = prefix .. r.icon .. " " .. r.name
        marks[i] = { prefix_end = #prefix, icon_len = #r.icon, icon_hl = r.icon_hl }
    end
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

    vim.api.nvim_buf_clear_namespace(buf_id, ws_symbol_ns, 0, -1)
    for i, m in ipairs(marks) do
        -- Dim the basename + line columns so the symbol name stands out.
        vim.api.nvim_buf_set_extmark(buf_id, ws_symbol_ns, i - 1, 0,
            { end_col = m.prefix_end, hl_group = "Comment" })
        -- Color the kind icon with its mini.icons highlight.
        if m.icon_hl and m.icon_len > 0 then
            vim.api.nvim_buf_set_extmark(buf_id, ws_symbol_ns, i - 1, m.prefix_end,
                { end_col = m.prefix_end + m.icon_len, hl_group = m.icon_hl })
        end
    end
end

-- Workspace symbols. The plain "workspace_symbol" scope sends an empty query:
-- lua_ls (and most servers) answer with ALL symbols, so you get the full list to
-- filter down in the picker - which is what we want. gopls is the exception: it
-- needs a non-empty query to match and returns nothing for an empty one, so for
-- gopls fall back to "workspace_symbol_live" (sends your typed text as you go).
vim.keymap.set("n", "<leader>ws", function()
    local scope = "workspace_symbol"
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if client.name == "gopls" then
            scope = "workspace_symbol_live"
            break
        end
    end
    require("mini.extra").pickers.lsp({ scope = scope }, { source = { show = workspace_symbol_show } })
end, { desc = "LSP: workspace symbols (picker)" })
vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, { desc = "LSP: run code lens" })

vim.diagnostic.config({
    -- virtual_text = true,
    virtual_lines = true,
    severity_sort = true,
})

-- :Diagnostics <mode> switches how diagnostics are shown (tab-completes):
--   virtual_lines  full messages on their own wrapped line(s) below the code
--   virtual_text   short message inline, to the right of the code
--   current_line   virtual_lines, but only for the line under the cursor
--   no_text        squiggles/underlines + signs only, no inline message
--   disabled       turn diagnostics off entirely
-- Underlines, signs, and severity_sort stay on for every display mode.
local diagnostic_modes = {
    virtual_lines = { virtual_lines = true, virtual_text = false },
    virtual_text  = { virtual_lines = false, virtual_text = true },
    current_line  = { virtual_lines = { current_line = true }, virtual_text = false },
    no_text       = { virtual_lines = false, virtual_text = false },
}
local function set_diagnostic_mode(mode)
    if mode == "disabled" then
        vim.diagnostic.enable(false)
        vim.notify("Diagnostics: disabled")
        return
    end
    local opts = diagnostic_modes[mode]
    if not opts then
        vim.notify("Unknown diagnostic mode: " .. mode, vim.log.levels.ERROR)
        return
    end
    vim.diagnostic.enable(true)
    vim.diagnostic.config(vim.tbl_extend("force", {
        severity_sort = true,
        underline = true,
        signs = true,
    }, opts))
    vim.notify("Diagnostics: " .. mode)
end
vim.api.nvim_create_user_command("Diagnostics", function(args)
    set_diagnostic_mode(args.args)
end, {
    nargs = 1,
    complete = function(arg_lead)
        local names = vim.tbl_keys(diagnostic_modes)
        table.insert(names, "disabled")
        table.sort(names)
        return vim.tbl_filter(function(m) return m:find(arg_lead, 1, true) == 1 end, names)
    end,
    desc = "Set diagnostic display mode",
})
