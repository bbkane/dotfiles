" Moar plugins at https://vimawesome.com/

" Most important plugin
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

" Good default settings
if !has("nvim")
    Plug 'tpope/vim-sensible'
endif

" https://github.com/tpope/vim-surround
" After selecting something in visual mode:
"   S' -> adds ' around selected object
Plug 'tpope/vim-surround'

" Highlights and fixes trailing whitespace
Plug 'bronson/vim-trailing-whitespace'

" By default, gx ignores querystrings in my links...
Plug 'tyru/open-browser.vim'
" https://github.com/tyru/open-browser.vim/blob/master/doc/openbrowser.txt
let g:netrw_nogx = 1 " disable netrw's gx mapping.
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)

" Vim
let g:indentLine_color_term = 239
"GVim (also neovim with termguicolors)
let g:indentLine_color_gui = '#545454' " grey
" none X terminal
let g:indentLine_color_tty_light = 7 " (default: 4)
let g:indentLine_color_dark = 1 " (default: 2)

Plug 'Yggdroot/indentLine', { 'for': ['jinja', 'xml', 'html', 'yaml']}

" Get me some sweet command line mappings for vim
Plug 'tpope/vim-rsi'

" :FZF [dir], then start typing file name
" use enter key, CTRL-T, CTRL-X or CTRL-V to open selected files in the
" current window, in new tabs, in horizontal splits, or in vertical splits
" respectively.
" I'm installing with brew, so I don't need the install script
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
" from brew info fzf
set rtp+=/usr/local/opt/fzf
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" colors parentheses. Can be toggled with RainbowToggle
Plug 'luochen1990/rainbow'
let g:rainbow_active = 1

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


" TODO: probably don't need both of these...
" Ctrl+_ to close the tag
" Plug 'vim-scripts/closetag.vim'
Plug 'tpope/vim-ragtag'

"Align text by selecting, :Tab /<character to align, usually '='>
Plug 'godlygeek/tabular'

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

" show diff when vim finds a .swp file
Plug 'chrisbra/Recover.vim'

" :rename <name>
Plug 'danro/rename.vim'

Plug 'hynek/vim-python-pep8-indent'

" Syntax highlighting plugins

" Plug 'Glench/Vim-Jinja2-Syntax'

Plug 'hdima/python-syntax'
let python_highlight_all=1

Plug 'cespare/vim-toml'

Plug 'elzr/vim-json'
let g:vim_json_syntax_conceal = 0

Plug 'vito-c/jq.vim'

Plug 'rust-lang/rust.vim'
let g:rustfmt_autosave = 1

Plug 'b4b4r07/vim-hcl'

" TODO: replace Neomake, especially for shellcheck and python

" -fgcc outputs gcc style errors and -x follows sources
" let g:neomake_sh_shellcheck_args = ['-fgcc', '-x']

" Command: QuickRun
Plug 'thinca/vim-quickrun'
let g:quickrun_config = {}
let g:quickrun_config.python = {'command' : 'python3'}

" Not sure I need this or not but quickrun is having problems with finding
" a conda env python
let g:quickrun_config['python'] = {
\   'command': 'python'
\ }

" After running this, QuickRun runs on :w
" bad for long running code (will freeze vim)
command! AutoQuickRun  autocmd BufWritePost * QuickRun

" colorschemes

" Test colorschemes
" Plug 'nanotech/jellybeans.vim'
" Plug 'tomasr/molokai'
" Plug 'dracula/vim'
" Plug 'ajmwagar/vim-deus'

" I don't think I like this one... it doesn't look like the screenshot...
" let g_airline_theme='purify'
" Plug 'kyoz/purify', { 'rtp': 'vim' }

" Not as good as I thought it would be
" Plug 'arcticicestudio/nord-vim'
" Also not as good as I thought it would be
" Plug 'rakr/vim-one'

" Colorschemes I know I like

Plug 'jpo/vim-railscasts-theme'
Plug 'rainux/vim-desert-warm-256'
Plug 'morhetz/gruvbox'

Plug 'mhartington/oceanic-next'
let g_airline_theme='oceanicnext'

" This adds a *bunch* of colorschemes
Plug 'flazz/vim-colorschemes'
if has('nvim')
    Plug 'Soares/base16.nvim'
endif

