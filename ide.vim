" source vim_ide_status from the environment
" Ex: export vim_ide_status="ycm rust cpp"
" don't forget to 'pip install neovim'
let vim_ide_status=$vim_ide_status

if has("nvim")

    " Here I am doing this again...
    " NOTE: nvim-yarp requires the neovim module
    " https://github.com/ncm2/ncm2 - copying straight from this

    " assuming your using vim-plug: https://github.com/junegunn/vim-plug
    Plug 'ncm2/ncm2'
    " ncm2 requires nvim-yarp
    Plug 'roxma/nvim-yarp'

    " enable ncm2 for all buffer
    autocmd BufEnter * call ncm2#enable_for_buffer()

    " note that must keep noinsert in completeopt, the others is optional
    set completeopt=noinsert,menuone,noselect

    " supress the annoying 'match x of y', 'The only match' and 'Pattern not
    " found' messages
    set shortmess+=c

    " CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
    inoremap <c-c> <ESC>

    " When the <Enter> key is pressed while the popup menu is visible, it only
    " hides the menu. Use this mapping to close the menu and also start a new
    " line.
    inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

    " Use <TAB> to select the popup menu:
    inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

    " some completion sources
    Plug 'ncm2/ncm2-bufword'
    Plug 'ncm2/ncm2-path'

    " End copied ncm2 config
    let g:ncm2#complete_length = 3


    " End ncm2 config

    " Use :ll to go to the first error
    Plug 'neomake/neomake'
    let g:neomake_open_list = 0
    let g:neomake_echo_current_error = 1
    let g:neomake_list_height = 5

    " 0 : Errors only
    " 1 : Quiet message (default)
    let g:neomake_verbose = 0


    if executable('clang')
        let g:neomake_cpp_enabled_makers=['clang']
        let g:neomake_cpp_clang_args = ["-std=c++14", "-Wextra", "-Wall", "-Weverything", "-pedantic", "-Wno-c++98-compat", "-Wno-missing-prototypes"]
    endif

    " -fgcc outputs gcc style errors and -x follows sources
    let g:neomake_sh_shellcheck_args = ['-fgcc', '-x']

    function! NeoMakeOnWrite()
        " If NeoMake isn't installed, don't do this
        if exists(":Neomake")
            augroup neomake
                " Run Neomake on every write
                autocmd!
                autocmd BufWritePost * Neomake
                autocmd BufWritePost *.rs NeomakeProject cargo
            augroup END
        endif
    endfunction

    " When Vim starts, register the neomake autogroup if possible
    autocmd VimEnter * call NeoMakeOnWrite()

    " Add a command to disable NeomakeOnWrite
    " http://superuser.com/questions/439078/how-to-disable-autocmd-or-augroup-in-vim
    command! NoNeoMakeOnWrite autocmd! neomake BufWritePost *

    " Open errors in separate window
    let g:neomake_open_list = 2

    " Get some simple fonts for warnings and errors
    let g:neomake_warning_sign = {
      \ 'text': 'W',
      \ 'texthl': 'WarningMsg',
      \ }
    let g:neomake_error_sign = {
      \ 'text': 'E',
      \ 'texthl': 'ErrorMsg',
      \ }
endif


" Command: QuickRun
Plug 'thinca/vim-quickrun'
let g:quickrun_config = {}
let g:quickrun_config.python = {'command' : 'python3'}
" According to the help line 526, this should work...
let g:quickrun_config['outputter/buffer/name'] = "quickrun_output"
if executable('clang')
    let g:quickrun_config['cpp'] = {
                \ 'command': 'clang++',
                \ 'cmdopt': '-std=c++14 -Wextra -Wall',
                \ 'exec': ['%c %o %s -o %s:p:r', '%s:p:r %a'],
                \ 'tempfile': '%{tempname()}.cpp',
                \ 'hook/sweep/files': ['%S:p:r']
                \ }
endif
if executable('stack')
    let g:quickrun_config['haskell'] = {
    \   'command': 'stack',
    \   'cmdopt': 'runghc',
    \   'tempfile': '%{tempname()}.hs',
    \   'hook/eval/template': 'main = print \$ %s'
    \ }
endif
" Not sure I need this or not but quickrun is having problems with finding
" a conda env python
let g:quickrun_config['python'] = {
\   'command': 'python'
\ }

" After running this, QuickRun runs on :w
" bad for long running code (will freeze vim)
command! AutoQuickRun  autocmd BufWritePost * QuickRun

