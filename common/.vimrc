" Determine OS
" Mac, Linux, Cygwin
if has("unix")
    let os = substitute(system('uname'), "\n", "", "")
elseif has("win32")
    let os = "Windows"
endif

" Install vim-plug if it isn't
if empty(glob("~/.vim/autoload/plug.vim"))
    let plugpath = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    " '.' concatenates the variable with the command
    execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs ' . plugpath
endif

" look for plugins in bundle/
call plug#begin('~/.vim/bundle')

" let b:cpp_file=0
" autocmd BufNewFile *.cpp let b:cpp_file=1
" autocmd BufRead *.cpp let b:cpp_file=1

" function! UsingCPP()
"     echo "UsingCPP"
"     let g:using_cpp = 1
" endfunction

let g:using_cpp = 0
let g:at_work = $at_work

" Only use YCM for cpp
if has("nvim") && g:using_cpp == 1 && g:at_work == 0
    let g:python_host_prog = '/usr/bin/python'
    " C++ autocompleter. Needs Steps outside of this one
    Plug 'Valloric/YouCompleteMe'
    " Set global config file. This might need to be changed :)
    let g:ycm_global_ycm_extra_conf = '~/.vim/ycm_extra_conf.py'
    " auto-load completion file INSECURE BY DEFAULT
    let g:ycm_confirm_extra_conf = 0

    " stop the preview window
    set completeopt-=preview
    let g:ycm_add_preview_to_completeopt = 0

    " Works on mac... but not Linux
    " Need to symlink clang++-3.? to clang++ -> sudo ln -s /usr/bin/clang++-3.6 /usr/bin/clang++
    Plug 'rdnetto/YCM-Generator', {'branch': 'stable'}
else
    " echo "no  YCM"
    Plug 'ervandew/supertab'

    " Plug 'scrooloose/syntastic'
    " set statusline+=%#warningmsg#
    " set statusline+=%{SyntasticStatuslineFlag()}
    " set statusline+=%*
    " let g:syntastic_enable_signs=0 " See errors in first column
    " let g:syntastic_always_populate_loc_list = 1 " Fill in location for error highlighting
    " let g:syntastic_auto_loc_list = 1 " Uses Separate window for errors
    " " let g:syntastic_auto_loc_list = 2 " Uses one line at the bottom for errors
    " let g:syntastic_check_on_open = 0 " Set to 0 for faster opening cpp files
    " let g:syntastic_check_on_wq = 0
    " " let g:syntastic_cpp_checkers = ['gcc']
    " " let g:syntastic_cpp_compiler = 'gcc'
    " let g:syntastic_cpp_compiler_options = '-std=c++1y' " If this flag is wrong, it stops working
endif

" Good default settings
Plug 'tpope/vim-sensible'

" Highlights and fixes trailing whitespace
Plug 'bronson/vim-trailing-whitespace'

if g:at_work == 0
    Plug 'ChesleyTan/wordCount.vim'
endif

" use :A to switch between .cpp and .h
Plug 'vim-scripts/a.vim'
" cmake syntax
Plug 'slurps-mad-rips/cmake.vim'
" Add highlighting of functions and containers and types
Plug 'octol/vim-cpp-enhanced-highlight'

" s <two letters> to jump to words
Plug 'justinmk/vim-sneak'

" easily comment line with `gcc` or selection with `gc`
Plug 'tpope/vim-commentary'
" set default commentstring
" set commentstring=#\ %s
" Find filetype with `set filetype?` and escape spaces and use `%s` for the string
autocmd FileType cmake set commentstring=#\ %s
autocmd FileType cpp set commentstring=//\ %s

" change enclosing symbols with `cs`. Ex: `cs'(` to chang from quotes to
" parens
Plug 'tpope/vim-surround'

" <C-p> opens a search window to find stuff
Plug 'kien/ctrlp.vim'
" limit ctrlp to current directory (see github for this) (might change)
" let g:ctrlp_working_path_mode = 'c'

" auto-matching
Plug 'jiangmiao/auto-pairs'
" Ignore single quotes in shell
au FileType sh let b:AutoPairs = {'(':')', '[':']', '{':'}','"':'"', '`':'`'}

" colors parentheses. Can be toggled with RainbowToggle
Plug 'luochen1990/rainbow'
let g:rainbow_active = 1

"Align text by selecting, :Tab /<character to align, usually '='>
Plug 'godlygeek/tabular'

" When filetype is html, type tagname then <C-x> <space> to complete the tag. <enter> adds a line
Plug 'tpope/vim-ragtag'
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'vim-scripts/closetag.vim'

" Pimps my statusbar
Plug 'bling/vim-airline'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnameod = ':t'

"TODO: research this carefully
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'
let g:session_autosave = 'no'
let g:session_autoload = 'no'

" :SaveSeesion and :OpenSession to begin with
Plug 'mhinz/vim-startify'
let g:startify_custom_header =
      \ map(split(system('fortune | cowsay'), '\n'), '"   ". v:val') + ['','']

Plug 'airblade/vim-gitgutter'

" Use BufClose to close stuff
Plug 'vim-scripts/BufOnly.vim'

" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'
" let g:UltiSnipsExpandTrigger="<tab>"

" use NERDTreeToggle
Plug 'scrooloose/nerdtree'
let g:NERDTreeWinSize=22
Plug 'Xuyuanp/nerdtree-git-plugin'

Plug 'christoomey/vim-tmux-navigator'

" Python Plugins
" Plug 'tmhedberg/SimpylFold'
Plug 'vim-scripts/indentpython.vim'
Plug 'nvie/vim-flake8'
let python_highlight_all=1

" colorschemes
Plug 'nanotech/jellybeans.vim'
Plug 'tomasr/molokai'
Plug 'altercation/vim-colors-solarized'
let g:solarized_termcolors=256
Plug 'jpo/vim-railscasts-theme'
Plug 'rainux/vim-desert-warm-256'

" End plugins
call plug#end()

if g:at_work == 1
    colorscheme elflord
else
    colorscheme desert-warm-256
endif

" Source my non-plugin-related keybindings
source ~/.vimrc-ben

