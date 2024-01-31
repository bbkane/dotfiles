-- https://wezfurlong.org/wezterm/troubleshooting.html#debug-overlay

-- Pull in the wezterm API
local wezterm = require 'wezterm'

local font = require 'font'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- config.color_scheme = 'kanagawabones'
-- config.color_scheme = 'OneHalfBlack (Gogh)'
-- config.color_scheme = 'Scarlet Protocol'
config.color_scheme = 'Solarized Dark Higher Contrast'
-- config.color_scheme = 'Modus-Vivendi'

config.font_size = 18.0
-- config.freetype_load_flags = 'NO_HINTING'
-- config.freetype_render_target = "HorizontalLcd"
-- config.freetype_load_target = "Light"
config.cell_width = 0.9


config.font = wezterm.font_with_fallback(font.font())

-- https://wezfurlong.org/wezterm/config/appearance.html?h=tab#tab-bar-appearance-colors
config.window_frame = {
    font_size = 15.0
}

-- stop lagging on "Mission Contro" zoom out
-- https://github.com/wez/wezterm/issues/2669
config.window_decorations = 'TITLE|RESIZE|MACOS_FORCE_DISABLE_SHADOW'

-- https://github.com/wez/wezterm/issues/253#issuecomment-672007120
config.keys = {
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    { key = "LeftArrow", mods = "OPT", action = wezterm.action { SendString = "\x1bb" } },
    -- Make Option-Right equivalent to Alt-f; forward-word
    { key = "RightArrow", mods = "OPT", action = wezterm.action { SendString = "\x1bf" } },
}


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

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
wezterm.on(
    'format-tab-title',
    function(tab, tabs, panes, config, hover, max_width)
        -- https://wezfurlong.org/wezterm/config/lua/pane/index.html
        local pane = tab.active_pane
        local process = basename(pane.foreground_process_name)

        local cwd = pane.current_working_dir
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

        return {
            { Background = { Color = bg } },
            { Foreground = { Color = fg } },
            { Attribute = { Intensity = "Bold" } },
            { Text = ' ' .. title .. ' ' },
        }
    end
)

-- and finally, return the configuration to wezterm
return config
