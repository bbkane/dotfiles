-- rust-analyzer overrides. Deep-merged over nvim-lspconfig's base
-- lsp/rust_analyzer.lua (cmd = { "rust-analyzer" }, filetypes = rust,
-- root_markers = Cargo.toml/.git) when vim.lsp.enable("rust_analyzer") runs.
-- Only the keys here override; everything else comes from lspconfig.
-- Settings reference: https://rust-analyzer.github.io/book/configuration.html
return {
    settings = {
        ["rust-analyzer"] = {
            -- Use clippy (not just `cargo check`) for on-save diagnostics.
            check = { command = "clippy" },
        },
    },
}
