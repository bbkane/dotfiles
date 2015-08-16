" Determine OS
" Mac, Linux, Cygwin
if has("unix")
    let os = substitute(system('uname'), "\n", "", "")
elseif has("win32")
    let os = "Windows"
endif

" Install vim-plug if it isn't (on windows, manually download it...)
if empty(glob("~/.vim/autoload/plug.vim"))
    let plugpath = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    " '.' concatenates the variable with the command
    execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs ' . plugpath
    autocmd VimEnter * PlugInstall
endif

" look for plugins in bundle/
call plug#begin('~/.vim/bundle')

if os == "Linux"
    " C++ autocompleter. Needs to be compiled too.
    Plug 'Valloric/YouCompleteMe'
    " Set global config file. This might need to be changed :)
    let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_extra_conf.py'
elseif has("lua")
    Plug 'Shougo/neocomplete'
else
    Plug 'ervandew/supertab'
endif

" Good default settings
Plug 'tpope/vim-sensible'

" Highlights and fixes trailing whitespace
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
" limit ctrlp to current directory (see github for this) (might change)
let g:ctrlp_working_path_mode = 'c'

" auto-matching
Plug 'jiangmiao/auto-pairs'
" Ignore single quotes in shell
au FileType sh let b:AutoPairs = {'(':')', '[':']', '{':'}','"':'"', '`':'`'}

" colors parentheses. Can be toggled with RainbowToggle
Plug 'luochen1990/rainbow'
let g:rainbow_active = 1

"Align text by selecting, :Tab /<character to align, usually =>
Plug 'godlygeek/tabular'

" When filetype is html, type tagname then <C-x> <space> to complete the tag. <enter> adds a line
Plug 'tpope/vim-ragtag'

" Add highlighting of functions and containers and types
Plug 'octol/vim-cpp-enhanced-highlight'

" Sexy statusbar
Plug 'bling/vim-airline'

" End plugins
call plug#end()

" Source my non-plugin-related keybindings
source ~/.vimrc-ben

