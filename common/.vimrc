" look for plugins in bundle/
call plug#begin('~/.vim/bundle')

" C++ autocompleter. Needs to be compiled too.
Plug 'Valloric/YouCompleteMe'
" Set global config file. This might need to be changed :)
let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_extra_conf.py'

" Good default settings
Plug 'tpope/vim-sensible'

" Highligts and fixes trailing whitespace
Plug 'bronson/vim-trailing-whitespace'

" use :A to switch between .cpp and .h
Plug 'vim-scripts/a.vim'

" s <two letters> to jump to words
Plug 'justinmk/vim-sneak'

" cmake syntax
Plug 'slurps-mad-rips/cmake.vim'

" easily comment line with `gcc` or selection with `gc`
Plug 'tpope/vim-commentary'
" set default commentstring
" set commentstring=#\ %s
" Find filetype with `set filetype?` and escape spaces and use `%s` for the string
autocmd FileType cmake set commentstring=#\ %s
autocmd FileType cpp set commentstring=//\ %s

" <C-p> opens a search window to find stuff
Plug 'kien/ctrlp.vim'
" let ctrlp see my .vimrc
let g:ctrlp_show_hidden = 1
" limit ctrlp to current directory (see github for this) (might change)
let g:ctrlp_working_path_mode = 'c'
" only scan in the current file (should this be 0 or 1?
let g:ctrlp_max_depth = 10
" also follow symlinks
let g:ctrlp_follow_symlinks = 2
" This isn't exactly working now......

" autocomplete parens and stuff
Plug 'Raimondi/delimitMate'
" Ignore double quotes in vim
au Filetype vim let b:delimitMate_quotes = "' `"
" Ignore single quotes in shell
au Filetype sh let b:delimitMate_quotes = "\" `"

" colors parentheses. Must be toggled with RainbowToggle
Plug 'luochen1990/rainbow'
let g:rainbow_active = 1 " Doesn't work for some reason

"Align text by selecting, :Tab /<character to align, usually =>
Plug 'godlygeek/tabular'

" When filetype is html, type tagname then <C-x> <space> to complete the tag. <enter> adds a line
Plug 'tpope/vim-ragtag'

" Add highlighting of functions and contanters and types
Plug 'octol/vim-cpp-enhanced-highlight'

" Pimps my statusbar
Plug 'bling/vim-airline'

" End plugins
call plug#end()

" Source my non-plugin-related keybindings
source ~/.vimrc-ben

