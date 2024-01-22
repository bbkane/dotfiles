-- https://wezfurlong.org/wezterm/troubleshooting.html#debug-overlay

-- Pull in the wezterm API
local wezterm = require 'wezterm'

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

-- Can also use: https://www.programmingfonts.org/
-- https://www.codingfont.com/
config.font = wezterm.font_with_fallback {
    -- 'IBM Plex Mono',  # not quite what I want
    -- 'Iosevka Term Extended', -- Pretty close to iA Writer Mono S...
    -- 'Inconsolata', -- also, ok but not better
    -- 'Monocraft', -- MineCraft font, not really what I'm looking for
    -- 'Terminus (TTF)', -- this is actually pretty good, different and thinner looking
    -- 'Source Code Pro', -- this is good as well
    'Hack', -- also quite good
    -- 'Monaspace Argon Var', -- not bad...
    -- 'Monaspace Krypton Var', -- pretty good too
    -- 'Monaspace Xenon Var', -- actually really like this one
    -- 'Cascadia Mono', -- I actually find this less readable
    -- 'Roboto Mono', -- this is pretty clear, really like it
    -- 'Liberation Mono', -- I like this one
    -- 'Ubuntu Mono',
    -- { family = 'iA Writer Mono S', weight = 'Regular' },
    -- { family = 'Fira Code', weight = 'Regular' },
    -- 'Monaco',
}

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



local home_dir_url = "file://" .. wezterm.home_dir

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

        -- NOTE: in the nightly, this will return a URL object, not a string
        -- TODO: this shoes file:// for paths above ~
        local cwd = string.gsub(pane.current_working_dir, home_dir_url, '~')
        local title = process .. ' ' .. cwd

        -- https://wezfurlong.org/wezterm/config/lua/wezterm.color/parse.html
        -- TODO: use the whole args? https://wezfurlong.org/wezterm/config/lua/LocalProcessInfo.html
        local bg = wezterm.color.parse(hash(process))
        local fg = bg:complement_ryb():saturate_fixed(0.6)

        return {
            { Background = { Color = bg } },
            { Foreground = { Color = fg } },
            { Text = ' ' .. title .. ' ' },
        }
    end
)

-- and finally, return the configuration to wezterm
return config
