-- https://unix.stackexchange.com/a/32003
-- NOTE: i was using Ctrl+v,M to make ^M here but VS Code autoformatter doesn't like it. This seems to work
vim.cmd [[
command! -range=% -nargs=0 -bar Dos2Unix
    \ :<line1>,<line2>s:\r::ge
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
    function(_)
        local old_name = vim.fn.expand("%")
        local new_name = vim.fn.input("New file name: ", old_name, "file")
        if new_name ~= '' and new_name ~= old_name then
            vim.api.nvim_command(' saveas ' .. new_name)
            vim.fn.delete(old_name)
            vim.cmd('redraw!')
        end
    end,
    { bang = true }
)

local function create_date_command(name, format)
    vim.api.nvim_create_user_command(
        name,
        function(_)
            vim.api.nvim_command('norm i' .. os.date(format))
        end,
        { bang = true }
    )

    -- ;Date is not a valid abbreviation, so expand Date only when preceded by ;.
    local expansion = ([[getline('.')[col('.') - %d] ==# ';' ? "\<BS>" . strftime('%s') : '%s']])
        :format(#name + 2, format, name)
    vim.cmd(("inoreabbrev <expr> %s %s"):format(name, expansion))
end

create_date_command("Date", '%Y-%m-%d')
create_date_command("Day", '%a %Y-%m-%d')
create_date_command("Time", '%H:%M')

vim.api.nvim_create_user_command(
    "FullPath",
    function(_)
        print(vim.fn.expand("%:p"))
    end,
    { bang = true }
)

vim.cmd [[
command! -range FormatShellCmd <line1>!format_shell_cmd.py
]]
