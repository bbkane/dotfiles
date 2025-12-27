-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- add your plugins here
		{ "neovim/nvim-lspconfig" },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	-- checker = { enabled = true },
})

vim.lsp.enable({ "lua_ls" })

vim.diagnostic.config({
	virtual_text = {
		enabled = true, -- Enables virtual text
		prefix = "● ", -- Optional prefix for the message
		-- You can use a custom formatter function for more control
		-- format = function(diagnostic)
		--   return string.format([[ code: %s message: %s ]], diagnostic.code, diagnostic.message)
		-- end,
	},
	signs = true,      -- Show signs in the gutter
	update_in_insert = false, -- Don't update diagnostics in insert mode
	underline = true,  -- Underline problematic code
	severity_sort = true, -- Sort diagnostics by severity
})


vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true }),
	callback = function(args)
		-- Check if an LSP client is attached and supports formatting
		if vim.lsp.buf.format then
			vim.lsp.buf.format({ async = false })
		end
	end,
})
