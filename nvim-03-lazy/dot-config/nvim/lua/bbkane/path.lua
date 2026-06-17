local M = {}

-- https://github.com/wbthomason/packer.nvim/blob/213ed031490ab5318e7996a594b52131e5c1c06f/lua/packer/M.lua#L38
if jit ~= nil then
    M.is_windows = jit.os == 'Windows'
else
    M.is_windows = package.config:sub(1, 1) == '\\'
end

if M.is_windows and vim.o.shellslash then
    M.use_shellslash = true
else
    M.use_shellslash = false
end

M.get_separator = function()
    if M.is_windows and not M.use_shellslash then
        return '\\'
    end
    return '/'
end

M.join = function(...)
    local separator = M.get_separator()
    return table.concat({ ... }, separator)
end

-- Return `path` relative to `root` (both absolute, same separator) when `path`
-- is inside `root`; otherwise nil. A trailing separator on `root` is ignored.
M.relative_to = function(path, root)
    if not root or root == "" then
        return nil
    end
    local sep = M.get_separator()
    root = (root:gsub(sep .. "$", "")) -- drop a trailing separator
    if path == root then
        return "."
    end
    local prefix = root .. sep
    if path:sub(1, #prefix) == prefix then
        return path:sub(#prefix + 1)
    end
    return nil
end

-- Truncate `s` from the LEFT to fit `width` display cells, prefixing the kept
-- tail with "…" (counted in the width). Returns `s` unchanged if it already fits.
M.truncate_left = function(s, width)
    if width <= 0 then
        return ""
    end
    if vim.fn.strdisplaywidth(s) <= width then
        return s
    end
    local ellipsis = "…"
    local budget = width - vim.fn.strdisplaywidth(ellipsis)
    local chars = vim.fn.split(s, "\\zs") -- per-character (multibyte-safe)
    local tail, used = {}, 0
    for i = #chars, 1, -1 do
        local w = vim.fn.strdisplaywidth(chars[i])
        if used + w > budget then
            break
        end
        used = used + w
        table.insert(tail, 1, chars[i])
    end
    return ellipsis .. table.concat(tail)
end

return M
