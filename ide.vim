" source vim_ide_status from the environment
" Ex: export vim_ide_status="ycm rust cpp"
" don't forget to 'pip install neovim'
let vim_ide_status=$vim_ide_status

" Python only requires cmake on mac
if has('mac')
    let ycm_can_compile = executable('cmake')
elseif has('win32')
    let ycm_can_compile = 0
else
    " TODO: make ubuntu check for this
    let ycm_can_compile = 1
endif

if vim_ide_status =~ 'ycm' && ycm_can_compile
    " Note: When compiling YCM, use the system python! Not Anaconda!
    let g:ycm_python_binary_path = 'python3'
    let ycm_options = { 'dir': '~/.config/nvim/bundle/YouCompleteMe', 'do': './install.py' }

    if vim_ide_status =~ 'rust'
        let g:ycm_rust_src_path = '/usr/local/src/rust/src'
        Plug 'rust-lang/rust.vim'
        let g:rustfmt_autosave = 1
        let ycm_options.do .= ' --racer-completer'
    endif
    if vim_ide_status =~ 'cpp'
        " Set global config file. This might need to be changed :)
        let g:ycm_global_ycm_extra_conf = '~/.config/nvim/ycm_extra_conf.py'
        " auto-load completion file INSECURE BY DEFAULT
        let g:ycm_confirm_extra_conf = 0
        let ycm_options.do .= ' --clang-completer'

        " OSX: Need to clang++ in path
        " OSX: Need a python2 in the path. I can't symlink in /usr/bin and
        " python doesn't like a symlink anywhere else so I'm using a wrapper script in ~/bin
        " http://unix.stackexchange.com/a/126567/185953
        Plug 'rdnetto/YCM-Generator', {'branch': 'stable'}
    endif

    Plug 'Valloric/YouCompleteMe', ycm_options
    command! GoTo YcmCompleter GoTo
else
    Plug 'ervandew/supertab'
endif


if has("nvim")
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
    if executable('flake8')
        let g:neomake_python_enabled_makers = ['flake8']
        let g:neomake_python_flake8_maker = {
            \ 'args': [flake8_ignore, '--format=default'],
            \ 'errorformat':
                \ '%E%f:%l: could not compile,%-Z%p^,' .
                \ '%A%f:%l:%c: %t%n %m,' .
                \ '%A%f:%l: %t%n %m,' .
                \ '%-G%.%#',
            \ }
    endif

    " Let YCM handle cpp if possible
    if vim_ide_status =~ 'cpp'
        let g:neomake_cpp_enabled_makers = []
        " TODO: Disabling this for c files could get me in trouble because YCM is currently only
        " configured for cpp files... Leaving it in for now because it makes
        " bfaas easier
        let g:neomake_c_enabled_makers = []
    elseif executable('clang')
        let g:neomake_cpp_enabled_makers=['clang']
        let g:neomake_cpp_clang_args = ["-std=c++14", "-Wextra", "-Wall", "-Weverything", "-pedantic"]
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

