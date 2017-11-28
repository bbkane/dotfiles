" source vim_ide_status from the environment
" Ex: export vim_ide_status="ycm rust cpp"
" don't forget to 'pip install neovim'
let vim_ide_status=$vim_ide_status

if has("nvim")

    " This needs the following Python modules:
    " https://github.com/roxma/nvim-completion-manager#installation
    " - neovim jedi mistune psutil setproctitle flake8

    " See https://bbkane.github.io/2017/05/17/Reproducible-Python-Environments-with-Conda.html
    " If using anaconda on Mac:
    " cd ~/.config/nvim
    " conda env create -f environment-mac.yaml
    if isdirectory(expand('~/anaconda3/envs/nvim'))
        " Now it depends on anaconda...
        " I'm going to try putting it in a conda environment called "nvim"
        " the environment-mac.yaml is in my ~/.config/nvim dir
        let g:python3_host_prog = expand('~/anaconda3/envs/nvim/bin/python3')
        let flake8_exe = expand('~/anaconda3/envs/nvim/bin/flake8')
    else
        " NOTE: Mac doesn't have /usr/bin/python3
        " but I install anaconda on every Mac I use

        " /usr/bin/python3 -m pip install --user neovim jedi psutil setproctitle
        let g:python3_host_prog = '/usr/bin/python3'
        let flake8_exe = 'flake8'  " TODO: test this
    endif


    " TODO: Use roxma's version once I'm done experimenting
    " Plug 'bbkane/nvim-completion-manager'
    Plug 'roxma/nvim-completion-manager'

    " Add preview to see docstrings in the complete window.
    let g:cm_completeopt = 'menu,menuone,noinsert,noselect,preview'

    " Close the preview window automatically on InsertLeave
    " https://github.com/davidhalter/jedi-vim/blob/eba90e615d73020365d43495fca349e5a2d4f995/ftplugin/python/jedi.vim#L44
    augroup ncm_preview
        autocmd! InsertLeave <buffer> if pumvisible() == 0|pclose|endif
    augroup END

    inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

    " Use :ll to go to the first error
    Plug 'neomake/neomake'
    let g:neomake_open_list = 0
    let g:neomake_echo_current_error = 1
    let g:neomake_list_height = 5

    " 0 : Errors only
    " 1 : Quiet message (default)
    let g:neomake_verbose = 0

    " E501: line length
    " W503: line break before binary operator
    let flake8_ignore = '--ignore=E501,W503'

    " When experimenting, I don't want to deal with a bunch of this...
    if !empty($vim_flake8_lax_mode)
        let flake8_ignore .= ',E302,E301,E261,W391,F401,E402,E731,E226,F841,E303,E225'
    endif

    " Don't forget to 'pip3 install flake8'
    " Not sure if the errorformat stuff is necessary
    let g:neomake_python_enabled_makers = ['flake8']
    let g:neomake_python_flake8_maker = {
        \ 'exe': flake8_exe,
        \ 'args': [flake8_ignore, '--format=default'],
        \ 'errorformat':
            \ '%E%f:%l: could not compile,%-Z%p^,' .
            \ '%A%f:%l:%c: %t%n %m,' .
            \ '%A%f:%l: %t%n %m,' .
            \ '%-G%.%#',
        \ }

    " I think you can only disable all warnings at once.
    " but the only one I don't want is the proprietary attributes
    " let g:neomake_html_tidy_maker = {
    "     \ 'args': ['-e', '-q', '--gnu-emacs', 'true', '--show-warnings', 'false'],
    "     \ 'errorformat': '%A%f:%l:%c: Warning: %m',
    "     \ }

    " Let YCM handle cpp if possible
    if vim_ide_status =~ 'cpp'
        let g:neomake_cpp_enabled_makers = []
        " TODO: Disabling this for c files could get me in trouble because YCM is currently only
        " configured for cpp files... Leaving it in for now because it makes
        " bfaas easier
        let g:neomake_c_enabled_makers = []
    elseif executable('clang')
        let g:neomake_cpp_enabled_makers=['clang']
        let g:neomake_cpp_clang_args = ["-std=c++14", "-Wextra", "-Wall", "-Weverything", "-pedantic", "-Wno-c++98-compat", "-Wno-missing-prototypes"]
    endif


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
else " Use syntastic on vim
    Plug 'scrooloose/syntastic'
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0

    " don't forget to 'pip3 install flake8'
    if executable('flake8')
        let g:syntastic_python_checkers = ['flake8']
    endif

    " ignore longer lines
    let g:syntastic_python_flake8_args = '--ignore=E501'
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

