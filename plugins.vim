
" Good default settings
if !has("nvim")
    Plug 'tpope/vim-sensible'
endif

" Highlights and fixes trailing whitespace
Plug 'bronson/vim-trailing-whitespace'

Plug 'Yggdroot/indentLine', { 'for': ['jinja', 'xml', 'html']}
" Vim
let g:indentLine_color_term = 239
"GVim (also neovim with termguicolors)
let g:indentLine_color_gui = '#545454' " grey
" none X terminal
let g:indentLine_color_tty_light = 7 " (default: 4)
let g:indentLine_color_dark = 1 " (default: 2)

" vim-xpath is really only useful for XML files and
" requires a Python2 with lxml installed
" The easiest way to get this is with Anaconda.
" Plug 'actionshrimp/vim-xpath'

" use :A to switch between .cpp and .h
Plug 'vim-scripts/a.vim'

" cmake syntax
" Plug 'slurps-mad-rips/cmake.vim'
Plug 'nickhutchinson/vim-cmake-syntax'

" Add highlighting of functions and containers and types
Plug 'octol/vim-cpp-enhanced-highlight'

" easily comment line with `gcc` or selection with `gc`
Plug 'tpope/vim-commentary'
" set default commentstring
" setglobal commentstring=#\ %s
" Find filetype with `set filetype?` and escape spaces and use `%s` for the string
augroup commentsrings
    autocmd!
    autocmd FileType asm   setlocal commentstring=;\ %s
    autocmd FileType cfg   setlocal commentstring=#\ %s
    autocmd FileType cmake setlocal commentstring=#\ %s
    autocmd FileType cpp   setlocal commentstring=//\ %s
    autocmd FileType jinja setlocal commentstring=<!--\ %s\ -->
    autocmd FileType jq    setlocal commentstring=#\ %s
    autocmd FileType mysql setlocal commentstring=--\ %s
    autocmd FileType php   setlocal commentstring=//\ %s
    autocmd FileType sql   setlocal commentstring=--\ %s
    autocmd FileType text  setlocal commentstring=#\ %s
augroup end

" because the autocommand isn't working so well...
command! SetHTMLCommentString setlocal commentstring=<!--\ %s\ -->

" change enclosing symbols with `cs`. Ex: `cs'(` to change from quotes to parens
" add add parens with ysiw( or ysiw)
Plug 'tpope/vim-surround'
" make the surround movements work with .
Plug 'tpope/vim-repeat'

" Get me some sweet command line mappings for vim
Plug 'tpope/vim-rsi'

" auto-matching
Plug 'jiangmiao/auto-pairs'
command! AutoPairsToggle call AutoPairsToggle()
augroup autopairs
    autocmd!
    " Ignore single quotes in shell
    autocmd FileType sh let b:AutoPairs = {'(':')', '[':']', '{':'}','"':'"', '`':'`'}
    " disable for scheme files
    autocmd VimEnter *.scm let b:autopairs_enabled = 0
augroup end

" colors parentheses. Can be toggled with RainbowToggle
Plug 'luochen1990/rainbow'
let g:rainbow_active = 1

"Align text by selecting, :Tab /<character to align, usually '='>
Plug 'godlygeek/tabular'

" When filetype is html, type tagname then <C-x> <space> to complete the tag. <enter> adds a line
Plug 'tpope/vim-ragtag'
Plug 'Glench/Vim-Jinja2-Syntax'
" Ctrl+_ to close the tag
Plug 'vim-scripts/closetag.vim'
if has("python")
    Plug 'https://github.com/Valloric/MatchTagAlways.git'
endif

" Pimps my statusbar
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnameod = ':t'

Plug 'mhinz/vim-startify'
if executable('cowsay') && executable('fortune')
    let g:startify_custom_header =
          \ map(split(system('fortune | cowsay'), '\n'), '"   ". v:val') + ['','']
endif

Plug 'airblade/vim-gitgutter'

" Python Plugins
Plug 'hdima/python-syntax'
Plug 'hynek/vim-python-pep8-indent'
let python_highlight_all=1


Plug 'cespare/vim-toml'
Plug 'StanAngeloff/php.vim'

Plug 'elzr/vim-json'
let g:vim_json_syntax_conceal = 0

Plug 'vito-c/jq.vim'

Plug 'rust-lang/rust.vim'
let g:rustfmt_autosave = 1

Plug 'Matt-Deacalion/vim-systemd-syntax'

Plug 'tpope/vim-fugitive'

Plug 'vim-scripts/LargeFile'
let g:LargeFile = 20

Plug 'chrisbra/Recover.vim'

Plug 'b4b4r07/vim-hcl'
Plug 'leafgarland/typescript-vim'

" :rename <name>
Plug 'danro/rename.vim'

if executable('clang-format')
    Plug 'rhysd/vim-clang-format'
endif

" colorschemes

" This adds a *bunch* of colorschemes
Plug 'flazz/vim-colorschemes'
if has('nvim')
    Plug 'Soares/base16.nvim'
endif

" Test colorschemes
" Plug 'nanotech/jellybeans.vim'
" Plug 'tomasr/molokai'
" Plug 'dracula/vim'
" Plug 'ajmwagar/vim-deus'

" " Ones I know I like
" Plug 'jpo/vim-railscasts-theme'
" Plug 'rainux/vim-desert-warm-256'
Plug 'morhetz/gruvbox'

