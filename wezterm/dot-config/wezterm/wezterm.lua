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

-- https://github.com/wez/wezterm/discussions/4728
local is_darwin <const> = wezterm.target_triple:find("darwin") ~= nil
local is_linux <const> = wezterm.target_triple:find("linux") ~= nil

-- We use Neovim to open files
local nvim_path = "nvim"
if is_darwin then
	nvim_path = "/opt/homebrew/bin/nvim"
elseif is_linux then
	nvim_path = "/home/linuxbrew/.linuxbrew/bin/nvim"
end

-- This is where you actually apply your config choices

-- config.color_scheme = 'kanagawabones'
-- config.color_scheme = 'OneHalfBlack (Gogh)'
-- config.color_scheme = 'Scarlet Protocol'
-- config.color_scheme = "Solarized Dark Higher Contrast"
-- config.color_scheme = 'Modus-Vivendi'
-- config.color_scheme = 'MaterialDarker'
config.color_scheme = 'Nucolors (terminal.sexy)'

if is_darwin then
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
end

-- stop lagging on "Mission Contro" zoom out
-- https://github.com/wez/wezterm/issues/2669
config.window_decorations = "TITLE|RESIZE|MACOS_FORCE_DISABLE_SHADOW"

local window_frame_border_color <const> = "#484848"
config.window_frame = {
	-- Specify border thickness (e.g., '1px', '0.5cell')
	border_left_width = '1px',
	border_right_width = '1px',
	border_bottom_height = '1px',
	border_top_height = '1px',
	-- Specify border colors
	border_left_color = window_frame_border_color,
	border_right_color = window_frame_border_color,
	border_bottom_color = window_frame_border_color,
	border_top_color = window_frame_border_color,
}

config.enable_scroll_bar = true

-- Use the default hyperlink rules as a base
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Rule to match absolute file paths starting with / (Linux/macOS)
table.insert(config.hyperlink_rules, {
	regex = [[(/[^\s:"\<\>|?*]+)]],
	format = "file://$1",
})

-- Rule to match paths starting with ~ (home directory)
table.insert(config.hyperlink_rules, {
	regex = [[~(/[^\s:"\<\>|?*]+)]],
	format = "file://" .. wezterm.home_dir .. "$1",
})

-- Rule to match relative file paths that look like a file reference (e.g., ./file.txt or ../dir/file.txt)
table.insert(config.hyperlink_rules, {
	regex = [[(\.\./[^\s:"\<\>|?*]+|\./[^\s:"\<\>|?*]+)]],
	format = "file://$1",
})

config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = 'NONE',
		action = wezterm.action.ScrollByLine(-5)
	},
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = 'NONE',
		action = wezterm.action.ScrollByLine(5)
	},

	-- Disable the default behavior of opening links on simple click
	{
		event = { Up = { streak = 1, button = 'Left' } },
		mods = 'NONE',
		action = wezterm.action.DisableDefaultAssignment,
	},

	-- Use CMD-click (Command on macOS, Ctrl/Win on others) to open the link
	{
		event = { Up = { streak = 1, button = 'Left' } },
		mods = 'CMD', -- Use 'CMD' for Command key on macOS/Super key elsewhere
		action = wezterm.action.OpenLinkAtMouseCursor,
	},

	-- Optional: Disable the 'Down' event of the modifier-click to avoid
	-- unexpected behavior in some programs
	{
		event = { Down = { streak = 1, button = 'Left' } },
		mods = 'CMD',
		action = wezterm.action.Nop,
	},
}

-- https://github.com/wez/wezterm/issues/253#issuecomment-672007120
config.keys = {
	-- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
	{ key = "LeftArrow",  mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
	-- Make Option-Right equivalent to Alt-f; forward-word
	{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
}

-- https://wezfurlong.org/wezterm/config/lua/window-events/format-tab-title.html
wezterm.on("format-tab-title", format_tab_title.format_tab_title)

-- https://wezfurlong.org/wezterm/config/lua/window-events/open-uri.html?h=%27open+uri%27
wezterm.on("open-uri", function(window, pane, uri)
	-- see these logs with ctrl + shift + l
	wezterm.log_info("Opening URI: " .. uri)

	if uri:match("^file://") then
		local file_path = uri:gsub("^file://", "")
		wezterm.log_info("Opening file: " .. file_path)

		-- wezterm.open_with(file_path, 'code')
		window:perform_action(
			wezterm.action.SpawnCommandInNewWindow {
				args = { nvim_path, file_path },
			},
			pane
		)

		return false
	end

	if uri:match("^https?://") then
		-- Use Firefox instead of the default browser
		wezterm.open_with(uri, 'firefox')
		-- prevent the default option of opening the URI in the default browser
		return false
	end
end)

-- https://news.ycombinator.com/item?id=45753978
-- Hide the scrollbar when there is no scrollback or alternate screen is active
wezterm.on("update-status", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local dimensions = pane:get_dimensions()

	overrides.enable_scroll_bar = dimensions.scrollback_rows > dimensions.viewport_rows and
		not pane:is_alt_screen_active()

	window:set_config_overrides(overrides)
end)

-- and finally, return the configuration to wezterm
return config
