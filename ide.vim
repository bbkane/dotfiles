" source vim_ide_status from the environment
" Ex: export vim_ide_status="ycm rust cpp"
" don't forget to 'pip install neovim'
let vim_ide_status=$vim_ide_status

if has("nvim")

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

