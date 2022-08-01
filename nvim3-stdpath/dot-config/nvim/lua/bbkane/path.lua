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
  M.use_shallslash = false
end

M.get_separator = function()
  if M.is_windows and not util.use_shellslash then
    return '\\'
  end
  return '/'
end

M.join = function(...)
  local separator = M.get_separator()
  return table.concat({ ... }, separator)
end

return M
