local util = {}

-- https://github.com/wbthomason/packer.nvim/blob/213ed031490ab5318e7996a594b52131e5c1c06f/lua/packer/util.lua#L38
if jit ~= nil then
  util.is_windows = jit.os == 'Windows'
else
  util.is_windows = package.config:sub(1, 1) == '\\'
end

if util.is_windows and vim.o.shellslash then
  util.use_shellslash = true
else
  util.use_shallslash = false
end

util.get_separator = function()
  if util.is_windows and not util.use_shellslash then
    return '\\'
  end
  return '/'
end

util.join_paths = function(...)
  local separator = util.get_separator()
  return table.concat({ ... }, separator)
end

return util
