local function apply_default_markdown_heading_colors()
    vim.api.nvim_set_hl(0, '@markup.heading.1.markdown', { fg = '#b3f6c0', bold = true }) -- green
    vim.api.nvim_set_hl(0, '@markup.heading.2.markdown', { fg = '#a6dbff', bold = true }) -- blue
    vim.api.nvim_set_hl(0, '@markup.heading.3.markdown', { fg = '#8cf8f7', bold = true }) -- teal
    vim.api.nvim_set_hl(0, '@markup.heading.4.markdown', { fg = '#ffc0b9', bold = true }) -- red
    vim.api.nvim_set_hl(0, '@markup.heading.5.markdown', { fg = '#fce094', bold = true }) -- yellow
    vim.api.nvim_set_hl(0, '@markup.heading.6.markdown', { fg = '#9b9ea4', bold = true }) -- gray
end

if vim.g.colors_name == nil or vim.g.colors_name == "default" then
    apply_default_markdown_heading_colors()
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("bbkane_default_markdown_headings", { clear = true }),
    pattern = "default",
    callback = apply_default_markdown_heading_colors,
})
