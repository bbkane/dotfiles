" source vim_ide_status from the environment
" Ex: export vim_ide_status="ycm rust cpp"
" don't forget to 'pip install neovim'
let vim_ide_status=$vim_ide_status
if vim_ide_status =~ 'ycm'
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

        " OSX: Need to symlink clang++-3.? to clang++ -> sudo ln -s /usr/bin/clang++-3.6 /usr/bin/clang++
        Plug 'rdnetto/YCM-Generator', {'branch': 'stable'}
    endif

    Plug 'Valloric/YouCompleteMe', ycm_options

endif


" Use :ll to go to the first error
Plug 'neomake/neomake'

" Don't forget to 'pip3 install flake8'
" Not sure if the errorformat stuff is necessary
let g:neomake_python_flake8_maker = {
    \ 'args': ['--ignore=E501',  '--format=default'],
    \ 'errorformat':
        \ '%E%f:%l: could not compile,%-Z%p^,' .
        \ '%A%f:%l:%c: %t%n %m,' .
        \ '%A%f:%l: %t%n %m,' .
        \ '%-G%.%#',
    \ }
let g:neomake_python_enabled_makers = ['flake8']

" Run Neomake on every write
autocmd! BufWritePost * Neomake

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
