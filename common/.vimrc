set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

" C++ autocompleter. Needs to be compiled too.
Plugin 'Valloric/YouCompleteMe'
" Set global config file. This might need to be changed :)
let g:ycm_global_ycm_extra_conf = '.vim/ycm_extra_conf.py'

" Good default settings
Plugin 'tpope/vim-sensible'

" Highligts and fixes trailing whitespace
Plugin 'bronson/vim-trailing-whitespace'

" use :A to switch between .cpp and .h
Plugin 'vim-scripts/a.vim'

" s <two letters> to jump to words
Plugin 'justinmk/vim-sneak'

" cmake syntax
Plugin 'slurps-mad-rips/cmake.vim'

" easily comment line with `gcc` or selection with `gc`
Plugin 'tpope/vim-commentary'
" Find filetype with `set filetype?` and escape spaces and use `%s` for the string
autocmd FileType cmake set commentstring=#\ %s
autocmd FileType cpp set commentstring=//\ %s

" <C-p> opens a search window to find stuff
Plugin 'kien/ctrlp.vim'

" autocomplete parens and stuff
Plugin 'Raimondi/delimitMate'
" Ignore double quotes in vim
au Filetype vim let b:delimitMate_quotes = "' `"
" Ignore single quotes in shell
au Filetype sh let b:delimitMate_quotes = "\" `"


" colors parentheses. Must be toggled with RainbowToggle
Plugin 'luochen1990/rainbow'
let g:rainbow_active = 1 " Doesn't work for some reason

"Align text by selecting, :Tab /<character to align, usually =>
Plugin 'godlygeek/tabular'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"

" Source my non-plugin-related keybindings
source ~/.vimrc-ben
