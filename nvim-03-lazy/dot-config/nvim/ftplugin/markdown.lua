-- Markdown buffer-local settings.

-- Markdown link helpers. Insert a "[desc](url)" link, taking the url from the
-- clipboard (only if it looks like a URL). In insert mode the description is the
-- word under the cursor (or empty if not on a word); in visual mode it's the
-- selection. Cursor lands: inside [] when there's no description, after ) when
-- there's a link, or inside () when there's a description but no link.

-- Clipboard -> link target, but only when it looks like a URL.
local function clipboard_url()
    local s = vim.fn.getreg("+"):gsub("^%s+", ""):gsub("%s+$", "")
    if s:match("^%a[%w%+%.%-]*://") or s:match("^www%.") or s:match("^mailto:") then
        return s
    end
    return ""
end

-- Replace the 0-based, end-exclusive range with the link, returning the 0-based
-- row/col where the cursor should go.
local function replace_with_link(srow, scol, erow, ecol, desc)
    local link = clipboard_url()
    local text = "[" .. desc .. "](" .. link .. ")"
    vim.api.nvim_buf_set_text(0, srow, scol, erow, ecol, { text })
    local col
    if desc == "" then
        col = scol + 1 -- inside the brackets: [<here>](...)
    elseif link ~= "" then
        col = scol + #text -- after the closing paren: [desc](link)<here>
    else
        col = scol + #("[" .. desc .. "](") -- inside the empty parens: [desc](<here>)
    end
    return srow, col
end

-- Insert mode: description is the word under the cursor (empty if not on a word).
local function insert_link()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local is_word = function(i)
        local c = line:sub(i, i)
        return c ~= "" and c:match("[%w_]") ~= nil
    end
    local s, e = col, col
    while s > 0 and is_word(s) do s = s - 1 end -- char left of boundary s
    while e < #line and is_word(e + 1) do e = e + 1 end -- char right of boundary e
    local r, c = replace_with_link(row - 1, s, row - 1, e, line:sub(s + 1, e))
    vim.api.nvim_win_set_cursor(0, { r + 1, c }) -- already in insert mode
end

-- Visual mode: description is the selection (its end of the link, then insert).
local function visual_link()
    local sp, ep = vim.fn.getpos("v"), vim.fn.getpos(".")
    local srow, scol = sp[2] - 1, sp[3] - 1
    local erow, ecol = ep[2] - 1, ep[3] - 1
    if srow > erow or (srow == erow and scol > ecol) then
        srow, scol, erow, ecol = erow, ecol, srow, scol
    end
    local end_line = vim.api.nvim_buf_get_lines(0, erow, erow + 1, false)[1] or ""
    local eend = math.min(ecol + 1, #end_line) -- inclusive selection -> exclusive end
    local desc = table.concat(vim.api.nvim_buf_get_text(0, srow, scol, erow, eend, {}), " ")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
    local r, c = replace_with_link(srow, scol, erow, eend, desc)
    vim.cmd("startinsert")
    vim.api.nvim_win_set_cursor(0, { r + 1, c })
end

-- <C-k> (Cmd+k doesn't reach Neovim in a terminal). Buffer-local to markdown;
-- free since Copilot uses Alt-based keys (lazy.lua). Insert mode wraps the word
-- under the cursor; visual mode wraps the selection.
vim.keymap.set("i", "<C-k>", insert_link, { buffer = true, desc = "Insert markdown link from clipboard" })
vim.keymap.set("x", "<C-k>", visual_link, { buffer = true, desc = "Wrap selection in a markdown link" })
