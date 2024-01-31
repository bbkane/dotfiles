local wezterm = require 'wezterm'

local module = {}

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
-- https://wezfurlong.org/wezterm/config/lua/PaneInformation.html

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
local basename = function(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

local hash = function(str)
    -- https://gist.github.com/scheler/26a942d34fb5576a68c111b05ac3fabe
    -- also try https://github.com/lancelijade/qqwry.lua/blob/master/crc32.lua
    -- https://wezfurlong.org/wezterm/config/files.html#making-your-own-lua-modules
    local h = 5381;
    for c in str:gmatch "." do
        h = ((h << 5) + h) + string.byte(c)
    end

    -- turn into a 6 digit hex value prefixed with '#'
    local hex = string.format("%x", h)
    hex = hex .. hex -- this should be long enough...
    local truncated = string.sub(hex, 1, 6)
    return '#' .. truncated
end

function module.format_tab_title(tab, tabs, panes, config, hover, max_width)
    -- https://wezfurlong.org/wezterm/config/lua/pane/index.html
    local pane = tab.active_pane
    local process = basename(pane.foreground_process_name)

    local cwd = pane.current_working_dir
    -- cwd is nil if I pull up the Debug Overlay for example
    if cwd == nil then
        cwd = ""
    else
        cwd = string.gsub(cwd.file_path, wezterm.home_dir, '~')
    end
    local title = process .. ' ' .. cwd

    -- https://wezfurlong.org/wezterm/config/lua/wezterm.color/parse.html
    -- TODO: use the whole args? https://wezfurlong.org/wezterm/config/lua/LocalProcessInfo.html
    local bg = wezterm.color.parse(hash(process))
    local fg = bg:complement_ryb():saturate_fixed(0.6)

    -- TODO: what if I just always made the background black? I think most things would be more readable
    return {
        { Background = { Color = bg } },
        { Foreground = { Color = fg } },
        { Attribute = { Intensity = "Bold" } },
        { Text = ' ' .. title .. ' ' },
    }
end

return module
