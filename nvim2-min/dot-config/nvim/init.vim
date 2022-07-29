

lua << EOF

-- inoremap jk <Esc>
vim.keymap.set('i', 'jk', '<Esc>')

-- map j to gj and k to gk, so line navigation ignores line wrap
-- nnoremap j gj
-- nnoremap k gk
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

-- https://stackoverflow.com/a/30691754 
-- set clipboard=unnamedplus
vim.o.clipboard = "unnamedplus"

-- set nohlsearch
vim.o.hlsearch = false

-- set wrap                          " Only use a soft wrap, not a hard one
vim.o.wrap = true
-- set linebreak                     " Break lines at word (requires Wrap lines)
vim.o.linebreak = true

-- " https://stackoverflow.com/a/1878984/2958070

-- set tabstop=4       " The width of a TAB is set to 4. Still it is a \t. It is just that
vim.o.tabstop = 4

-- set shiftwidth=4    " Indents will have a width of 4
vim.o.shiftwidth = 4

-- set softtabstop=4   " Sets the number of columns for a TAB
vim.o.softtabstop = 4

-- set expandtab       " Expand TABs to spaces
vim.o.expandtab = true


-- augroup custom_filetype
--     autocmd!
--     autocmd BufNewFile,BufRead *.src set filetype=xml
-- augroup END
local bbkane_augroup = vim.api.nvim_create_augroup('bbkane_augroup', {clear = true})

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    group = bbkane_augroup,
    pattern = "*.src",
    command = "set filetype=xml"
})

-- " http://stackoverflow.com/a/18444962/2958070
-- " custom file templates
-- augroup templates
--     au!
--     autocmd BufNewFile *.* silent! execute '0r ~/.config/nvim/templates/skeleton.'.expand("<afile>:e")
-- augroup END
vim.api.nvim_create_autocmd({'BufNewFile'}, {
    group = bbkane_augroup,
    pattern = "*.*",
    command = "silent! execute '0r ~/.config/nvim/templates/skeleton.'.expand('<afile>:e')"
})

-- " NOTE: add bottom one first to not mess up what's <line2>
-- command! -range=% -nargs=0 -bar AddCodeFence
--     \ :<line2>s:$:\r```:
--     \ | <line1>s:^:```\r:
vim.api.nvim_create_user_command(
    "AddCodeFence",
    [[:<line2>s:$:\r```:
    \ | <line1>s:^:```\r:]],
    {bang = true, bar = true, range = "%", nargs=0}
)

-- " The 'e' on the end of the substitute ignores errors
-- " -range=% means without a visual selection the whole buffer is selected
-- "  Special thanks to a @jfim for the link substitution line
-- "  Note that top level lists can be represented by ^-, not ^*
-- "  TODO: handle ^# substitution in code blocks
-- command! -range=% -nargs=0 -bar MarkdownToJira
--     \ :<line1>,<line2>s:^  - :** :e
--     \ | <line1>,<line2>s:^    - :*** :e
--     \ | <line1>,<line2>s:^```$:{code}:e
--     \ | <line1>,<line2>s:^```\(.\+\):{code\:\1}:e
--     \ | <line1>,<line2>s:^# :h1. :e
--     \ | <line1>,<line2>s:^## :h2. :e
--     \ | <line1>,<line2>s:^### :h3. :e
--     \ | <line1>,<line2>s: `: {{:eg
--     \ | <line1>,<line2>s:^`:{{:e
--     \ | <line1>,<line2>s:` :}} :eg
--     \ | <line1>,<line2>s:`$:}}:eg
--     \ | <line1>,<line2>s:`\.:}}.:eg
--     \ | <line1>,<line2>s:^\d\+\. :# :e
--     \ | <line1>,<line2>s/\v\[([^\]]*)\]\(([^\)]*)\)/[\1|\2]/ge
vim.api.nvim_create_user_command(
    "MarkdownToJira",
    [=[:<line1>,<line2>s:^  - :** :e
    \ | <line1>,<line2>s:^    - :*** :e
    \ | <line1>,<line2>s:^```$:{code}:e
    \ | <line1>,<line2>s:^```\(.\+\):{code\:\1}:e
    \ | <line1>,<line2>s:^# :h1. :e
    \ | <line1>,<line2>s:^## :h2. :e
    \ | <line1>,<line2>s:^### :h3. :e
    \ | <line1>,<line2>s: `: {{:eg
    \ | <line1>,<line2>s:^`:{{:e
    \ | <line1>,<line2>s:` :}} :eg
    \ | <line1>,<line2>s:`$:}}:eg
    \ | <line1>,<line2>s:`\.:}}.:eg
    \ | <line1>,<line2>s:^\d\+\. :# :e
    \ | <line1>,<line2>s/\v\[([^\]]*)\]\(([^\)]*)\)/[\1|\2]/ge
    \]=],
    {bang = true, bar = true, range = "%", nargs=0}
)

vim.api.nvim_create_user_command(
    "RenameFile",
    function(args)
        local old_name = vim.fn.expand("%")
        local new_name = vim.fn.input("New file name: ", old_name, "file")
        if new_name ~= '' and new_name ~= old_name then
            vim.api.nvim_command(' saveas ' .. new_name)
            -- TODO: https://unix.stackexchange.com/a/562421/185953
            vim.api.nvim_command(' silent !rm ' .. old_name)
        end
    end,
    {bang = true}
)

-- END LUA
EOF

" https://askubuntu.com/a/686806/483521
command! InsertDate :execute 'norm i' .
    \ substitute(system("date '+%a %b %d - %Y-%m-%d %H:%M:%S %Z'"), '\n\+$', '', '')

