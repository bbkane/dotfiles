Plug 'ervandew/supertab'

" Good default settings
Plug 'tpope/vim-sensible'

" Highlights and fixes trailing whitespace
Plug 'bronson/vim-trailing-whitespace'

" use :A to switch between .cpp and .h
Plug 'vim-scripts/a.vim'
" cmake syntax
Plug 'slurps-mad-rips/cmake.vim'
" Add highlighting of functions and containers and types
Plug 'octol/vim-cpp-enhanced-highlight'

" easily comment line with `gcc` or selection with `gc`
Plug 'tpope/vim-commentary'
" set default commentstring
" setglobal commentstring=#\ %s
" Find filetype with `set filetype?` and escape spaces and use `%s` for the string
autocmd FileType cmake setlocal commentstring=#\ %s
autocmd FileType cpp setlocal commentstring=//\ %s
autocmd FileType php setlocal commentstring=//\ %s
autocmd FileType sql setlocal commentstring=--\ %s
autocmd FileType jinja setlocal commentstring=<!--\ %s\ -->
autocmd FileType asm setlocal commentstring=;\ %s

" change enclosing symbols with `cs`. Ex: `cs'(` to change from quotes to parens
Plug 'tpope/vim-surround'

" auto-matching
Plug 'jiangmiao/auto-pairs'
" Ignore single quotes in shell
au FileType sh let b:AutoPairs = {'(':')', '[':']', '{':'}','"':'"', '`':'`'}
command! AutoPairsToggle call AutoPairsToggle()

" colors parentheses. Can be toggled with RainbowToggle
Plug 'luochen1990/rainbow'
let g:rainbow_active = 1

"Align text by selecting, :Tab /<character to align, usually '='>
Plug 'godlygeek/tabular'

" When filetype is html, type tagname then <C-x> <space> to complete the tag. <enter> adds a line
Plug 'tpope/vim-ragtag'
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'vim-scripts/closetag.vim'
if has("python")
    Plug 'https://github.com/Valloric/MatchTagAlways.git'
endif

" Pimps my statusbar
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnameod = ':t'

" :SaveSession and :OpenSession
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'
let g:session_autosave = 'no'
let g:session_autoload = 'no'

Plug 'mhinz/vim-startify'
let g:startify_custom_header =
      \ map(split(system('fortune | cowsay'), '\n'), '"   ". v:val') + ['','']

Plug 'airblade/vim-gitgutter'

" Use BufClose to close stuff
Plug 'vim-scripts/BufOnly.vim'

Plug 'christoomey/vim-tmux-navigator'

" Python Plugins
Plug 'hdima/python-syntax'
Plug 'hynek/vim-python-pep8-indent'
let python_highlight_all=1

" Command: QuickRun
Plug 'thinca/vim-quickrun'
let g:quickrun_config = {}
let g:quickrun_config.python = {'command' : 'python3'}
" After running this, QuickRun runs on :w
" bad for long running code (will freeze vim)
command! AutoQuickRun  autocmd BufWritePost * QuickRun

" Command: Man
Plug 'vim-utils/vim-man'

Plug 'cespare/vim-toml'

Plug 'elzr/vim-json'
let g:vim_json_syntax_conceal = 0

Plug 'Matt-Deacalion/vim-systemd-syntax'

" colorschemes
Plug 'nanotech/jellybeans.vim'
Plug 'tomasr/molokai'
Plug 'altercation/vim-colors-solarized'
let g:solarized_termcolors=256
Plug 'jpo/vim-railscasts-theme'
Plug 'rainux/vim-desert-warm-256'
Plug 'morhetz/gruvbox'

