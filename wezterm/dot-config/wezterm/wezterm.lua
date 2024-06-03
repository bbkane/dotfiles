-- https://wezfurlong.org/wezterm/troubleshooting.html#debug-overlay

-- Pull in the wezterm API
local wezterm = require("wezterm")

local font = require("font")
local format_tab_title = require("format_tab_title")

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
config.color_scheme = "Solarized Dark Higher Contrast"
-- config.color_scheme = 'Modus-Vivendi'
config.color_scheme = 'MaterialDarker'
config.color_scheme = 'Nucolors (terminal.sexy)'

config.font_size = 18.0
-- config.freetype_load_flags = 'NO_HINTING'
-- config.freetype_render_target = "HorizontalLcd"
-- config.freetype_load_target = "Light"
config.cell_width = 0.9

config.font = wezterm.font_with_fallback(font.font())

-- https://wezfurlong.org/wezterm/config/appearance.html?h=tab#tab-bar-appearance-colors
config.window_frame = {
	font_size = 15.0,
}

-- stop lagging on "Mission Contro" zoom out
-- https://github.com/wez/wezterm/issues/2669
config.window_decorations = "TITLE|RESIZE|MACOS_FORCE_DISABLE_SHADOW"

-- https://github.com/wez/wezterm/issues/253#issuecomment-672007120
config.keys = {
	-- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
	{ key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
	-- Make Option-Right equivalent to Alt-f; forward-word
	{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
}

-- https://wezfurlong.org/wezterm/config/lua/config/term.html
-- config.term = 'wezterm'

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
wezterm.on("format-tab-title", format_tab_title.format_tab_title)

-- and finally, return the configuration to wezterm
return config
