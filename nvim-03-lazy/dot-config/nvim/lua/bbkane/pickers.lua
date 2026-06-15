-- mini.pick setup + custom pickers. Required from the mini.pick `config` in
-- lua/bbkane/lazy.lua, so mini.pick is already loaded when this runs (and the
-- `MiniPick` global is set by the setup() call below). Holds the picker window
-- config, list line-wrap, the <leader>f finder keymaps, and the custom
-- `registry` (pick-a-picker) and `outline` (symbols/headings) pickers.

require('mini.pick').setup({
    -- Big centered float (~90% of the editor) so long diagnostic
    -- messages have room. window.config may be a function for
    -- responsiveness; recomputed when the picker (re)opens.
    window = {
        config = function()
            local height = math.floor(0.9 * vim.o.lines)
            local width = math.floor(0.9 * vim.o.columns)
            return {
                anchor = 'NW',
                height = height,
                width = width,
                row = math.floor(0.5 * (vim.o.lines - height)),
                col = math.floor(0.5 * (vim.o.columns - width)),
            }
        end,
    },
})

-- Wrap long lines in the picker list so full messages are readable
-- (the diagnostic picker rows are "severity | path | message" and
-- would otherwise run off the right edge). MiniPickStart fires once
-- the list window exists; flip 'wrap' on it.
vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniPickStart',
    callback = function()
        local win = require('mini.pick').get_picker_state().windows.main
        if win then vim.wo[win].wrap = true end
    end,
})

-- Fuzzy-finder keymaps (leader is Space). mini.pick sets none by
-- default; these follow the Telescope/kickstart <leader>f convention
-- and show up under <leader>f via mini.clue.
vim.keymap.set("n", "<leader>ff", "<cmd>Pick files<cr>",     { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Pick grep_live<cr>", { desc = "Find by grep (live)" })
vim.keymap.set("n", "<leader>fb", "<cmd>Pick buffers<cr>",   { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Pick help<cr>",      { desc = "Find help" })
vim.keymap.set("n", "<leader>fr", "<cmd>Pick resume<cr>",    { desc = "Resume last picker" })

-- "Picker picker": list every registered picker (mini.pick builtins
-- + all mini.extra pickers, which auto-register into the registry)
-- and run the chosen one. Recipe from MiniPick's own docs.
MiniPick.registry.registry = function()
    local items = vim.tbl_keys(MiniPick.registry)
    table.sort(items)
    local chosen = MiniPick.start({ source = { items = items, name = "Pickers", choose = function() end } })
    if chosen == nil then return end
    return MiniPick.registry[chosen]()
end
vim.keymap.set("n", "<leader>fp", "<cmd>Pick registry<cr>", { desc = "Find picker (registry)" })

-- Custom current-buffer diagnostics picker (<leader>d / :Pick buffer_diagnostics).
-- mini.extra's diagnostic picker always prefixes each row with the file path; for
-- a single buffer that path is redundant and eats horizontal room, so this builds
-- the items by hand and formats each row as "severity | line | message". Choosing
-- an item jumps to it (default_choose uses bufnr/lnum/col); rows are tinted by
-- severity and show the offending source line as a virtual line below each row.
-- (Below, not above: Neovim won't render virt_lines above the first buffer line,
-- so the top row would silently lose its source line.)
local diag_ns = vim.api.nvim_create_namespace("bbkane_diag_picker")
local diag_hl = {
    [vim.diagnostic.severity.ERROR] = "DiagnosticFloatingError",
    [vim.diagnostic.severity.WARN] = "DiagnosticFloatingWarn",
    [vim.diagnostic.severity.INFO] = "DiagnosticFloatingInfo",
    [vim.diagnostic.severity.HINT] = "DiagnosticFloatingHint",
}
MiniPick.registry.buffer_diagnostics = function()
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
    -- Tint each row by severity (line_hl_group covers the whole line, wrap-safe),
    -- and show the offending source line as a virtual line below each row.
    local show = function(buf_id, items_to_show, query)
        pick.default_show(buf_id, items_to_show, query)
        vim.api.nvim_buf_clear_namespace(buf_id, diag_ns, 0, -1)
        local win = vim.fn.bufwinid(buf_id)
        local width = win ~= -1 and vim.api.nvim_win_get_width(win) or 80
        local sep = string.rep("─", width)
        for i, item in ipairs(items_to_show) do
            local opts = { line_hl_group = diag_hl[item.severity] }
            if item.bufnr and item.lnum then
                local src = vim.api.nvim_buf_get_lines(item.bufnr, item.lnum - 1, item.lnum, false)[1]
                if src then
                    opts.virt_lines = {
                        { { vim.trim(src), "Comment" } },
                        { { sep, "NonText" } },
                    }
                end
            end
            vim.api.nvim_buf_set_extmark(buf_id, diag_ns, i - 1, 0, opts)
        end
    end
    pick.start({ source = { name = "Buffer diagnostics", items = items, show = show } })
end
vim.keymap.set("n", "<leader>d", "<cmd>Pick buffer_diagnostics<cr>", { desc = "LSP: buffer diagnostics (picker)" })

-- Treesitter markdown-headings source, used as the fallback for the
-- `outline` picker below when no LSP document symbols are available.
-- Queries the `markdown` parser for ATX (`#`-style) heading markers -
-- so `#` inside fenced code blocks is naturally excluded (not a
-- heading node) - and lists them indented by level. Choosing one
-- jumps to it (default_choose uses bufnr/lnum/col). (Setext
-- `===`/`---` underlined headings aren't matched by this query.)
local heading_query
local function markdown_headings(bufnr)
    -- Resolve to a concrete buffer id: items carry this as item.bufnr
    -- and mini.pick's default_choose needs a real buffer (not 0) to
    -- switch to and jump on choose.
    if not bufnr or bufnr == 0 then
        bufnr = vim.api.nvim_get_current_buf()
    end
    if not heading_query then
        local ok_q, q = pcall(vim.treesitter.query.parse, "markdown", [[
            [
              (atx_h1_marker)
              (atx_h2_marker)
              (atx_h3_marker)
              (atx_h4_marker)
              (atx_h5_marker)
              (atx_h6_marker)
            ] @marker
        ]])
        if not ok_q then
            return {}
        end
        heading_query = q
    end
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown")
    if not ok or not parser then
        return {}
    end
    local tree = parser:parse()[1]
    if not tree then
        return {}
    end
    local items = {}
    for _, node in heading_query:iter_captures(tree:root(), bufnr, 0, -1) do
        local level = tonumber(node:type():match("atx_h(%d)_marker"))
        local row = node:start()
        -- Heading text = the whole atx_heading node minus the opening
        -- marker and any closing ATX `##` (only stripped when it's a
        -- space-separated run, so content like `C#` survives).
        local text = vim.treesitter.get_node_text(node:parent(), bufnr)
        text = text:gsub("^#+%s*", ""):gsub("%s+#+%s*$", "")
        table.insert(items, {
            text = string.rep("  ", level - 1) .. vim.trim(text),
            bufnr = bufnr,
            lnum = row + 1,
            col = 1,
        })
    end
    return items
end

-- `:Pick outline` (and <leader>o): a document outline that works
-- everywhere. Prefers LSP document symbols (classes / functions /
-- methods / ... in code, via mini.extra) and falls back to the
-- Treesitter markdown headings above when the buffer has no
-- symbol-providing LSP. Both jump on choose and close the picker.
MiniPick.registry.outline = function()
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if client:supports_method("textDocument/documentSymbol") then
            return require("mini.extra").pickers.lsp({ scope = "document_symbol" })
        end
    end
    local items = markdown_headings(0)
    if vim.tbl_isempty(items) then
        vim.notify("No document symbols or markdown headings found", vim.log.levels.INFO)
        return
    end
    return MiniPick.start({ source = { name = "Outline", items = items } })
end
vim.keymap.set("n", "<leader>o", "<cmd>Pick outline<cr>", { desc = "Outline (LSP symbols / md headings)" })
