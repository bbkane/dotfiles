local wezterm = require 'wezterm'

local module = {}

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
-- https://wezfurlong.org/wezterm/config/lua/PaneInformation.html

-- this one produces short hashes and they always seem to be the same shade of blue or red
local GHhash = function(str)
    -- https://gist.github.com/scheler/26a942d34fb5576a68c111b05ac3fabe
    -- also try https://github.com/lancelijade/qqwry.lua/blob/master/crc32.lua
    -- https://wezfurlong.org/wezterm/config/files.html#making-your-own-lua-modules
    local h = 5381;
    for c in str:gmatch "." do
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
    for c in str:gmatch "." do
        hash = hash * a + string.byte(c)
        a = a * b
    end
    return hash
end

-- this makes 'less` and 'nvim' look a very similar (army green)
local JSHash = function(str)
    local hash = 1315423911
    for c in str:gmatch "." do
        hash = hash ~ (((hash << 5) + string.byte(c) + (hash >> 2)))
    end
    return hash
end

-- this is my favorite so far. zsh, nvim, and less look good
local ELFHash = function(str)
    local hash = 0
    local x = 0
    for c in str:gmatch "." do
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
    local hex = string.format('%x', hash_int)
    hex = hex .. hex -- make it long enough
    local truncated = string.sub(hex, 1, 6)
    -- https://wezfurlong.org/wezterm/config/lua/wezterm.color/parse.html
    return wezterm.color.parse('#' .. truncated)
end

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
local basename = function(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end


-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
function module.format_tab_title(tab, tabs, panes, config, hover, max_width)
    -- https://wezfurlong.org/wezterm/config/lua/pane/index.html
    local pane = tab.active_pane
    local process = basename(pane.foreground_process_name)

    local cwd = pane.current_working_dir
    -- cwd is nil if I pull up the Debug Overlay for example
    if cwd == nil then
        cwd = "<unknown>"
        -- assume process is nil as well
        process = "<unknown>"
    else
        cwd = string.gsub(cwd.file_path, wezterm.home_dir, '~')
    end

    local title = process .. ' ' .. cwd
    -- TODO: use the whole args? https://wezfurlong.org/wezterm/config/lua/LocalProcessInfo.html
    local color = hash_to_color(hash(process))
    local intensity = 'Normal'
    if tab.is_active then
        intensity = 'Bold'
    end


    -- https://wezfurlong.org/wezterm/config/lua/wezterm/format.html
    return {
        { Background = { Color = 'black' } },
        { Foreground = { Color = color } },
        { Attribute = { Intensity = intensity } },
        { Text = ' ' .. title .. ' ' },
    }
end

return module
