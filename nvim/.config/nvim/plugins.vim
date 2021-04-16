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
    autocmd FileType json  setlocal commentstring=//\ %s
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

" :Delete , :Rename
Plug 'tpope/vim-eunuch'

" Highlights and fixes trailing whitespace
" Turns out ale does this... I've got ale fixing on every save, so I'll leave
" this here commented out in case I need a standalone command
" Plug 'bronson/vim-trailing-whitespace'

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
Plug 'junegunn/fzf'
" :Files
Plug 'junegunn/fzf.vim'

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
" How to use:
" - On first run, select Compare and :w to save the version you want, :q
" - On second run, select open anyway?
Plug 'chrisbra/Recover.vim'

" I think eunuch.vim replaces this
" :rename <name>
" Plug 'danro/rename.vim'

" Syntax highlighting plugins

" Plug 'Glench/Vim-Jinja2-Syntax'

Plug 'hdima/python-syntax'
let python_highlight_all=1

Plug 'cespare/vim-toml'

Plug 'elzr/vim-json'
let g:vim_json_syntax_conceal = 0

" https://github.com/cuelang/cue/issues/722
let g:cue_fmt_on_save = 0
Plug 'jjo/vim-cue'

Plug 'vito-c/jq.vim'

Plug 'rust-lang/rust.vim'
let g:rustfmt_autosave = 1

Plug 'b4b4r07/vim-hcl'

" " Using coc-go instead
" GoTest , GoTestFunc , GoDef , GoDocBrowser , GoRename
" GoMetaLinter , GoLint , GoVet , GoErrCheck
" GoCallees , GoReferrers
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" TODO: consider https://github.com/majutsushi/tagbar with this
" TODO: go through https://github.com/fatih/vim-go/wiki/Tutorial#quick-setup

" for shellcheck!!!
" See linters with :ALEInfo
Plug 'dense-analysis/ale'
let g:airline#extensions#ale#enabled = 1

" :ll - go to first error
" :lprev/next - go to prev/next error
" :lopen - open error window
" only lint on open/save
let g:ale_linters = {
            \ 'go': [ 'go vet' ],
            \}
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0

let g:ale_sign_error = '✘'
let g:ale_sign_warning = '⚠'

let g:ale_sh_shellcheck_options = '-fgcc -x'
" Ignore some of these
" - E203: whitespace before ':'
" - E231: missing whitespace after ','
" - E501: line too long
" - W503: line break before binary operator
let g:ale_python_flake8_options = '--max-line-length 120 --ignore=E203,E231,E501,W503'
let g:ale_python_black_options = '--line-length 120'

let g:ale_fixers = {
            \ '*': ['remove_trailing_lines'],
            \ 'sh': ['shfmt'],
            \ 'go': ['gofmt'],
            \ 'python': ['black'],
            \}
nmap <F10> :ALEFix<CR>
" This autoformats!!
let g:ale_fix_on_save = 1

" TODO: build airline statusbar out of this (actually show the warning in the
" statusbar, not just the line number
" echom string(ale#statusline#Count(bufnr('')))
" echom string(ale#statusline#FirstProblem(bufnr(''), 'warning'))

" NOTE: my :Run command is a lightweight way of doing this
" but it doesn't run code in a buffer
" Command: QuickRun
Plug 'thinca/vim-quickrun'
let g:quickrun_config = {}
let g:quickrun_config.python = {'command' : 'python3'}

" After running this, QuickRun runs on :w
" bad for long running code (will freeze vim)
command! AutoQuickRun  autocmd BufWritePost * QuickRun

" Adds a lot of syntax stuff
" Interferes with vim-cue for .cue files
let g:polyglot_disabled = ['cue']
Plug 'sheerun/vim-polyglot'

" NOTE: Coc replaces this. Keeping commented out for now
" Autocomplete from buffer, filesystem on Tab
" Plug 'ajh17/VimCompletesMe'
" " So working in Python files doesn't try to invoke autocomplete
" let g:vcm_omni_pattern = 'NEVER_MATCH'

" See ../../README.md for install info
Plug 'neoclide/coc.nvim', {'branch': 'release'}
source ~/.config/nvim/coc_readme_config.vim

source ~/.config/nvim/colorscheme_plugins.vim
