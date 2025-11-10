local in_ssh = vim.env.SSH_CONNECTION ~= nil

-- https://github.com/folke/lazy.nvim?tab=readme-ov-file#-installation
-- Example using a list of specs with the default options
vim.g.mapleader = " "       -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\" -- Same for `maplocalleader`

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

-- https://mil.ad/blog/2024/remote-clipboard.html
-- help :clipboard-osc52 (TODO: test in ssh)
if in_ssh then
    vim.g.clipboard = 'osc52'
end

-- set wrap                          " Only use a soft wrap, not a hard one
vim.o.wrap = true
-- set linebreak                     " Break lines at word (requires Wrap lines)
vim.o.linebreak = true

-- https://stackoverflow.com/a/1878984/2958070
-- https://gist.github.com/LunarLambda/4c444238fb364509b72cfb891979f1dd

-- set tabstop=4       " The width of a TAB is set to 4. Still it is a \t. It is just that
vim.o.tabstop = 4

-- set shiftwidth=4    " Indents will have a width of 4
vim.o.shiftwidth = 4

-- set softtabstop=4   " Sets the number of columns for a TAB
vim.o.softtabstop = 4

-- set expandtab       " Expand TABs to spaces
vim.o.expandtab = true

vim.o.termguicolors = true

vim.o.inccommand = "split"

vim.o.smartcase = true

-- https://stackoverflow.com/a/65352148/2958070
-- https://www.reddit.com/r/neovim/comments/w1ujir/mouse_enabled_by_default_in_git_master/?utm_source=share&utm_medium=web2x&context=3
vim.opt.mouse = ''

-- https://stackoverflow.com/a/5774854
-- this means I can put something like `# vim:set ft=zsh:` in a file
-- It's also a security risk - arbitrary commands can be run on file open...
-- vim.o.modeline = true
-- vim.o.modelines = 5

-- augroup custom_filetype
--     autocmd!
--     autocmd BufNewFile,BufRead *.src set filetype=xml
-- augroup END
local bbkane_augroup = vim.api.nvim_create_augroup('bbkane_augroup', { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = bbkane_augroup,
    pattern = { ".gitconfig,", "gitconfig_*" },
    -- https://stackoverflow.com/a/1878992
    -- https://gist.github.com/LunarLambda/4c444238fb364509b72cfb891979f1dd#tabs-only
    command = "set filetype=gitconfig noexpandtab tabstop=8 shiftwidth=0 softtabstop=0 smarttab"
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = bbkane_augroup,
    pattern = "*.src",
    command = "set filetype=xml"
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = bbkane_augroup,
    pattern = "*.code-workspace",
    command = "set filetype=jsonc"
})

-- " http://stackoverflow.com/a/18444962/2958070
-- " custom file templates
-- augroup templates
--     au!
--     autocmd BufNewFile *.* silent! execute '0r ~/.config/nvim/templates/skeleton.'.expand("<afile>:e")
-- augroup END
vim.api.nvim_create_autocmd({ 'BufNewFile' }, {
    group = bbkane_augroup,
    pattern = "*.*",
    command = "silent! execute '0r ~/.config/nvim/templates/skeleton.'.expand('<afile>:e')"
})

-- TODO: lua version not working...
-- " NOTE: add bottom one first to not mess up what's <line2>
-- command! -range=% -nargs=0 -bar AddCodeFence
--     \ :<line2>s:$:\r```:
--     \ | <line1>s:^:```\r:
-- vim.api.nvim_create_user_command(
--     "AddCodeFence",
--     [[:<line2>s:$:\r```:
--     \ | <line1>s:^:```\r:]],
--     { bang = true, bar = true, range = "%", nargs = 0 }
-- )

-- https://unix.stackexchange.com/a/32003
vim.cmd [[
command! -range=% -nargs=0 -bar Dos2Unix
    \ :<line1>,<line2>s:$::
]]

vim.cmd [[
command! -range=% -nargs=0 -bar AddCodeFence
    \ :<line2>s:$:\r```:
    \ | <line1>s:^:```\r:
]]

vim.cmd [=[
" The 'e' on the end of the substitute ignores errors
" -range=% means without a visual selection the whole buffer is selected
"  Special thanks to a @jfim for the link substitution line
"  Note that top level lists can be represented by ^-, not ^*
"  TODO: handle ^# substitution in code blocks
command! -range=% -nargs=0 -bar MarkdownToJira
    \ :<line1>,<line2>s:^  - :** :e
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
]=]

-- https://github.com/richardmarbach/dotfiles/blob/7912ba284aac6cc005b9dfe35349bf1e5d50f1fe/config/nvim/lua/utils/file.lua#L5
vim.api.nvim_create_user_command(
    "RenameFile",
    function(args)
        local old_name = vim.fn.expand("%")
        local new_name = vim.fn.input("New file name: ", old_name, "file")
        if new_name ~= '' and new_name ~= old_name then
            vim.api.nvim_command(' saveas ' .. new_name)
            -- TODO: https://unix.stackexchange.com/a/562421/185953
            vim.api.nvim_command(' silent !rm ' .. old_name)
            vim.cmd('redraw!')
        end
    end,
    { bang = true }
)

-- " https://askubuntu.com/a/686806/483521
-- " :lua =os.date('%Y/%m/%d %H:%M:%S')
-- command! InsertDate :execute 'norm i' .
--     \ substitute(system("date '+%a %b %d - %Y-%m-%d %H:%M:%S %Z'"), '\n\+$', '', '')
vim.api.nvim_create_user_command(
    "InsertDate",
    function(args)
        local today = os.date('%a %b %d - %Y-%m-%d %H:%M:%S %Z')
        vim.api.nvim_command('norm i ' .. today)
    end,
    { bang = true }
)

vim.api.nvim_create_user_command(
    "FullPath",
    function (args)
        print(vim.fn.expand("%:p"))
    end,
    { bang = true }
)

vim.cmd [[
command! -range FormatShellCmd <line1>!format_shell_cmd.py
]]
