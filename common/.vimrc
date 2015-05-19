set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'Valloric/YouCompleteMe'
" Set global config file. This might need to be changed :)
let g:ycm_global_ycm_extra_conf = '.vim/ycm_extra_conf.py'

Plugin 'tpope/vim-sensible'

Plugin 'bronson/vim-trailing-whitespace'

Plugin 'vim-scripts/a.vim'

Plugin 'kien/rainbow_parentheses.vim'

Plugin 'justinmk/vim-sneak'

Plugin 'slurps-mad-rips/cmake.vim'

Plugin 'tpope/vim-commentary'
" Find filetype with `set filetype?` and escape spaces and use `%s` for the string
autocmd FileType cmake set commentstring=#\ %s
autocmd FileType cpp set commentstring=//\ %s


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
