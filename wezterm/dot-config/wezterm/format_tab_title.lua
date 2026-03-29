local wezterm = require("wezterm")
local mux = wezterm.mux

local module = {}

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
-- https://wezfurlong.org/wezterm/config/lua/PaneInformation.html

-- this one produces short hashes and they always seem to be the same shade of blue or red
local GHhash = function(str)
	-- https://gist.github.com/scheler/26a942d34fb5576a68c111b05ac3fabe
	-- also try https://github.com/lancelijade/qqwry.lua/blob/master/crc32.lua
	-- https://wezfurlong.org/wezterm/config/files.html#making-your-own-lua-modules
	local h = 5381
	for c in str:gmatch(".") do
		h = ((h << 5) + h) + string.byte(c)
	end

	return h
end

-- the following hash functions ported from https://www.partow.net/programming/hashfunctions/

-- this works pretty well, but nvim is now a dark somewhat hard to read purple
-- my favorite so far
local RSHash = function(str)
	local b = 378551
	local a = 63689
	local hash = 0
	for c in str:gmatch(".") do
		hash = hash * a + string.byte(c)
		a = a * b
	end
	return hash
end

-- this makes 'less` and 'nvim' look a very similar (army green)
local JSHash = function(str)
	local hash = 1315423911
	for c in str:gmatch(".") do
		hash = hash ~ ((hash << 5) + string.byte(c) + (hash >> 2))
	end
	return hash
end

-- this is my favorite so far. zsh, nvim, and less look good
local ELFHash = function(str)
	local hash = 0
	local x = 0
	for c in str:gmatch(".") do
		hash = (hash << 4) + string.byte(c)
		x = hash & 0xF0000000
		if x ~= 0 then
			hash = hash ~ (x >> 24)
		end
		hash = hash & ~x
	end
	return hash
end

-- let's assign a hash function here
local hash = ELFHash

local hash_to_color = function(hash_int)
	local hex = string.format("%x", hash_int)
	hex = hex .. hex -- make it long enough
	local truncated = string.sub(hex, 1, 6)
	-- https://wezfurlong.org/wezterm/config/lua/wezterm.color/parse.html
	local color = wezterm.color.parse("#" .. truncated)
	color = color:saturate(0.2)
	color = color:lighten(0.2)
	return color
end

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
local basename = function(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

---@param process string
---@param cwd string
---@param is_active boolean
---@return table
local build_title = function(process, cwd, is_active)
	local sep = " "
	if process == "" or cwd == "" then
		sep = ""
	end

	local icon = is_active and "✨" or "💤"
	local title = icon .. process .. sep .. cwd
	-- if zsh is the process, hash the cwd so the color is relevant to me
	-- otherwise, hash the process name
	local string_to_color = process == "zsh" and cwd or process
	local color = hash_to_color(hash(string_to_color))

	-- https://wezfurlong.org/wezterm/config/lua/wezterm/format.html
	return {
		{ Background = { Color = color } },
		{ Foreground = { Color = "black" } },
		{ Text = title },
	}
end

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
function module.format_tab_title(tab, tabs, panes, config, hover, max_width)
	-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
	-- if the tab title is explicitly set, take that
	-- set title: wezterm cli set-tab-title 'alice'
	local title = tab.tab_title
	if title and #title > 0 then
		return build_title(title, "", tab.is_active)
	end

	-- https://wezfurlong.org/wezterm/config/lua/pane/index.html
	local pane_info = tab.active_pane
	local cwd = pane_info.current_working_dir

	-- cwd is nil if I pull up the Debug Overlay for example
	if cwd == nil then
		-- assume process is also nil
		return build_title("<unknown>", "<unknown>", tab.is_active)
	end

	-- https://wezfurlong.org/wezterm/config/lua/wezterm.mux/get_pane.html
	local pane = mux.get_pane(pane_info.pane_id)
	-- https://wezfurlong.org/wezterm/config/lua/pane/get_foreground_process_info.html
    local process_name = "<unknown>"
	local process_info = pane:get_foreground_process_info()
    if process_info ~= nil then
	    process_name = process_info.executable
	    process_name = basename(process_name)
    end

	-- for SSH, use the hostname as the title
	if process_name == "ssh" and #process_info.argv == 2 then
		local hostname = process_info.argv[2]
		local dot = hostname:find '[.]'
		if dot then
			local truncated_hostname = hostname:sub(1, dot - 1)
			if truncated_hostname ~= '' then
				hostname = truncated_hostname
			end
		end
		return build_title(hostname, "", tab.is_active)
	end

	cwd = basename(cwd.file_path)
	return build_title(process_name, cwd, tab.is_active)
end

return module
