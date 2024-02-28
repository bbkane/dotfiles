local wezterm = require("wezterm")

local module = {}

-- Can also use: https://www.programmingfonts.org/
-- https://www.codingfont.com/
function module.font()
	return {
		-- 'IBM Plex Mono',  # not quite what I want
		-- 'Iosevka Term Extended', -- Pretty close to iA Writer Mono S...
		-- 'Inconsolata', -- also, ok but not better
		-- 'Monocraft', -- MineCraft font, not really what I'm looking for
		-- 'Terminus (TTF)', -- this is actually pretty good, different and thinner looking
		-- 'Source Code Pro', -- this is good as well
		"Hack", -- also quite good
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
end

return module
