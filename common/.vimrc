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
endif

" look for plugins in bundle/
call plug#begin('~/.vim/bundle')

if os == "Linux" || has("gui_running")
    " C++ autocompleter. Needs Steps outside of this one
    Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer' }
    " Set global config file. This might need to be changed :)
    let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_extra_conf.py'
else
    Plug 'ervandew/supertab'

    Plug 'scrooloose/syntastic'
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
    let g:syntastic_enable_signs=0 " See errors in first column
    let g:syntastic_always_populate_loc_list = 1 " Fill in location for error highlighting
    let g:syntastic_auto_loc_list = 1 " Uses Separate window for errors
    " let g:syntastic_auto_loc_list = 2 " Uses one line at the bottom for errors
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0
    " let g:syntastic_cpp_checkers = ['gcc']
    " let g:syntastic_cpp_compiler = 'gcc'
    let g:syntastic_cpp_compiler_options = '-std=c++1y' " If this flag is wrong, it stops working
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

Plug 'tpope/vim-surround'

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
let g:rainbow_active = 0

"Align text by selecting, :Tab /<character to align, usually '='>
Plug 'godlygeek/tabular'

" When filetype is html, type tagname then <C-x> <space> to complete the tag. <enter> adds a line
Plug 'tpope/vim-ragtag'

" Add highlighting of functions and containers and types
Plug 'octol/vim-cpp-enhanced-highlight'

" Use a colorscheme until I find a better one
if has("gui_running")
    colorscheme desert
else
    colorscheme elflord
endif

" Pimps my statusbar
Plug 'bling/vim-airline'

" End plugins
call plug#end()

" Source my non-plugin-related keybindings
source ~/.vimrc-ben

