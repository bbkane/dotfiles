-- gopls overrides. Deep-merged over nvim-lspconfig's base lsp/gopls.lua
-- (which supplies cmd / filetypes / root_markers) when vim.lsp.enable("gopls")
-- runs. Only the keys here override; everything else comes from lspconfig.
-- Settings reference: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
return {
    settings = {
        gopls = {
            analyses = { unusedparams = true },
            staticcheck = true,
            -- Limit workspace/symbol (<leader>ws) to this module's own code
            -- instead of all dependencies/stdlib, so the live search is faster
            -- and less noisy. ("all" is the gopls default.)
            symbolScope = "workspace",
        },
    },
}
