-- ruff overrides. Deep-merged over nvim-lspconfig's base lsp/ruff.lua
-- (cmd = { "ruff", "server" }, filetypes = python, root_markers).
-- ruff handles lint / format / code actions; let the type checker (ty) own
-- hover, so disable ruff's hover here to avoid it answering K with nothing.
-- https://docs.astral.sh/ruff/editors/
return {
    on_attach = function(client)
        client.server_capabilities.hoverProvider = false
    end,
}
