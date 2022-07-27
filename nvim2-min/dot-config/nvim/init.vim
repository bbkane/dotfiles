inoremap jk <Esc>

" map j to gj and k to gk, so line navigation ignores line wrap
nnoremap j gj
nnoremap k gk

" https://stackoverflow.com/a/30691754 
set clipboard=unnamedplus
set nohlsearch

set wrap                          " Only use a soft wrap, not a hard one
set linebreak                     " Break lines at word (requires Wrap lines)

" https://stackoverflow.com/a/1878984/2958070
set tabstop=4       " The width of a TAB is set to 4. Still it is a \t. It is just that
                    " Vim will interpret it to be having a width of 4.
set shiftwidth=4    " Indents will have a width of 4
set softtabstop=4   " Sets the number of columns for a TAB
set expandtab       " Expand TABs to spaces

" NOTE: add bottom one first to not mess up what's <line2>
command! -range=% -nargs=0 -bar AddCodeFence
    \ :<line2>s:$:\r```:
    \ | <line1>s:^:```\r:

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

function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
command! RenameFile :call RenameFile()

" https://askubuntu.com/a/686806/483521
command! InsertDate :execute 'norm i' .
    \ substitute(system("date '+%a %b %d - %Y-%m-%d %H:%M:%S %Z'"), '\n\+$', '', '')

augroup custom_filetype
    autocmd!
    autocmd BufNewFile,BufRead *.src set filetype=xml
augroup END

" http://stackoverflow.com/a/18444962/2958070
" custom file templates
augroup templates
    au!
    autocmd BufNewFile *.* silent! execute '0r ~/.config/nvim/templates/skeleton.'.expand("<afile>:e")
augroup END
