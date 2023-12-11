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

local home_dir_url = "file://" .. wezterm.home_dir

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
-- https://wezfurlong.org/wezterm/config/lua/PaneInformation.html

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
function basename(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on(
    'format-tab-title',
    function(tab, tabs, panes, config, hover, max_width)
        local pane = tab.active_pane
        local process = basename(pane.foreground_process_name)
        -- NOTE: in the nightly, this will return a URL object, not a string
        -- TODO: this shoes file:// for paths above ~
        local cwd = string.gsub(pane.current_working_dir, home_dir_url, '~')
        local title = process .. ' ' .. cwd
        return {
            { Text = ' ' .. title .. ' ' },
        }
    end
)

-- and finally, return the configuration to wezterm
return config