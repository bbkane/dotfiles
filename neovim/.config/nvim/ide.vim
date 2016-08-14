Plug 'Valloric/YouCompleteMe', { 'dir': '~/.config/nvim/bundle/YouCompleteMe', 'do': './install.py --racer-completer' }
let g:ycm_rust_src_path = '/usr/local/src/rust/src'

Plug 'rust-lang/rust.vim'
let g:rustfmt_autosave = 1

Plug 'scrooloose/syntastic'
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
