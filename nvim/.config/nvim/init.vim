if executable('git') && !empty(glob("~/.config/nvim/autoload/plug.vim"))
    " look for plugins in bundle/
    call plug#begin('~/.config/nvim/bundle')

    if !empty(glob("~/.config/nvim/plugins.vim"))
        " Source my plugins!
        source ~/.config/nvim/plugins.vim
        command! EditPlugins :edit ~/.config/nvim/plugins.vim
    endif

    " End plugins
    call plug#end()
else
    autocmd VimEnter * echom "Install vim-plug with :InstallVimPlug and plugins with :PlugInstall"
endif

syntax on
" for vim 7
set t_Co=256
if has('termguicolors')
    set termguicolors
endif
" Try to use a colorscheme plugin
" but fallback to a default one
try
    if has('mac')
        " colorscheme gruvbox
        colorscheme OceanicNext
    else
        colorscheme desert-warm-256
    endif
catch /^Vim\%((\a\+)\)\=:E185/
    " no plugins available
    colorscheme elflord
endtry
set background=dark

" use stuff from vim.wikia.com example vimrc
filetype indent plugin on
set wildmenu                      " Use tab to complete stuff in vim menu
set showcmd                       " show partial commands in the last line of screen
set ignorecase                    " case insensitive search except for capital letters
set smartcase
set backspace=indent,eol,start    " allow backspacing over characters
set autoindent                    " Auto-indent new lines if no filetype
set ruler                         " Show row and column ruler information
set noerrorbells

set wrap                          " Only use a soft wrap, not a hard one
set linebreak                     " Break lines at word (requires Wrap lines)
set nolist
set showbreak=\\\\                 " Wrap-broken line prefix
set textwidth=0                   " Line wrap (number of cols)
set wrapmargin=0

set number                        " Show line numbers
set showmatch                     " Highlight matching brace
set undolevels=1000               " Number of undo levels
set nohlsearch
set splitbelow
set splitright

" I think this will shorten YCM's function doc window
" set previewheight=5

" Default indent settings

" https://stackoverflow.com/a/1878984/2958070
set tabstop=4       " The width of a TAB is set to 4. Still it is a \t. It is just that
                    " Vim will interpret it to be having a width of 4.
set shiftwidth=4    " Indents will have a width of 4
set softtabstop=4   " Sets the number of columns for a TAB
set expandtab       " Expand TABs to spaces

" TODO: clean up indent settings ( https://stackoverflow.com/a/1878983/2958070 )
function! IndentSpacesToggle()
    if &softtabstop == 2
        setlocal tabstop=4
        setlocal shiftwidth=4
        setlocal softtabstop=4
        setlocal expandtab
        echom "#spaces per indent = 4"
    else
        setlocal tabstop=2
        setlocal shiftwidth=2
        setlocal softtabstop=2
        setlocal expandtab
        echom "#spaces per indent = 2"
    endif
endfunction

command! IndentSpacesToggle call IndentSpacesToggle()

" Custom indent settings per filetype
augroup custom_filetype
    autocmd!

    autocmd BufRead,BufNewFile Vagrantfile set filetype=ruby

    autocmd filetype go setlocal noexpandtab shiftwidth=4 softtabstop=4 tabstop=4
    " https://superuser.com/a/907889/643441
    autocmd filetype crontab setlocal nobackup nowritebackup
    " Only use tabs in gitconfig
    " https://stackoverflow.com/questions/3682582/how-to-use-only-tab-not-space-in-vim
    autocmd filetype gitconfig setlocal autoindent noexpandtab tabstop=8 shiftwidth=8
    " Use 2 spaces to indent in these
    autocmd filetype html,javascript,json,ruby,typescript,yaml setlocal shiftwidth=2 softtabstop=2

    " formatprgs
    " Many times I want to format just a few comment lines - so I don't want
    " to overwrite formatprg for that. See :FormatFile for formatting the
    " whole file with external tools instead
    autocmd filetype json
        \ if executable('jq') |
            \ set formatprg=jq\ . |
        \ elseif executable('python') |
            \ set formatprg=python\ -m\ json.tool |
        \ endif

augroup END

function! FormatFile()
    if &filetype == 'go'
        if executable('gofmt')
            :%!gofmt
        endif
    elseif &filetype =='json'
        if executable('jq')
            :%!jq .
        elseif executable('python')
            :%!python -m json.tool
        endif
    elseif &filetype == 'python'
        if executable('black')
            :%!black -q -
        endif
    elseif &filetype == 'terraform'
        if executable('terraform')
            :%!terraform fmt -no-color -
        endif
    endif
endfunction
command! FormatFile call FormatFile()

command! -range FormatShellCmd <line1>!format_shell_cmd.py

" Sometimes I dont want to indent (yaml files in particular)
command! StopIndenting setl noai nocin nosi inde=

" Set Visual Studio style indents
command! VSIndentStyle set noexpandtab shiftwidth=4 softtabstop=4 tabstop=4

"save temporary files to /tmp/
"if tmp doesn't exist, make it
" http://stackoverflow.com/a/15317146/2958070
" https://www.reddit.com/r/vim/comments/2jpcbo/mkdir_issue/
silent! call mkdir($HOME . '/.config/nvim/backup', 'p')
set backupdir=~/.config/nvim/backup//
silent! call mkdir($HOME . '/.config/nvim/swap', 'p')
set directory=~/.config/nvim/swap//
if exists('&undodir') " Vim 7.2 doesn't have this
    silent! call mkdir($HOME . '/.config/nvim/undo', 'p')
    set undodir=~/.config/nvim/undo//
endif

if !has("gui_running")
    set confirm "open a save dialog when quitting"
endif

if exists('&inccommand')
    set inccommand=split
endif

let mapleader = " "

" map j to gj and k to gk, so line navigation ignores line wrap
nnoremap j gj
nnoremap k gk

nnoremap <leader>V ggVG


" Tab through buffers (writes to them...)
nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>


" Use bash highlighting instead of sh highlighting
" let g:is_posix = 1
let g:is_bash = 1

" Make some stuff uncopyable on HTML output
" :help :TOhtml
let g:html_prevent_copy = "fn"


" To use the clipboard on linux, install xsel
if has('clipboard')
    set clipboard^=unnamedplus,unnamed
endif

" inoremap fd <ESC>
" Need another one cause I'm using fd more now..
inoremap jk <ESC>

" save without sudo vim
cmap w!! w !sudo tee > /dev/null %


if has("nvim")
    tnoremap <Esc> <C-\><C-n>
    tnoremap fd  <C-\><C-n>
    " split settings
    " This doesn't work with my tmux plugin
    " go to next bufer
    tnoremap <C-n> <C-\><C-n><C-w><C-w>
    " Map Ctrl+ <motion> to <Terminal escape> + < Window Control> + <Motion>
    tnoremap <C-j> <C-\><C-n><C-w><C-j>
    tnoremap <C-k> <C-\><C-n><C-w><C-k>
    tnoremap <C-l> <C-\><C-n><C-w><C-l>
    tnoremap <C-h> <C-\><C-n><C-w><C-h>
    " open terminal in vertical split instead of new buffer
    command! Term :vert sp | term
    " Hopefully, this keeps buffers when I switch windows
    autocmd TermOpen * set bufhidden=hide
endif


" disable error bells
if !has("nvim")
    set nocompatible
    set visualbell t_vb=
endif

" http://stackoverflow.com/a/18444962/2958070
" custom file templates
augroup templates
    au!
    autocmd BufNewFile *.* silent! execute '0r ~/.config/nvim/templates/skeleton.'.expand("<afile>:e")
augroup END

" " This is now on plug in https://github.com/christoomey/vim-tmux-navigator
" " which makes it also work in tmux
" " split settings
nnoremap <C-n> <ESC><C-w><C-w>
nnoremap <C-j> <ESC><C-w><C-j>
nnoremap <C-k> <ESC><C-w><C-k>
nnoremap <C-l> <ESC><C-w><C-l>
" " This won't work on OSX withot more work
" " See :Checkhealth on NeoVim
" 2018-07-26 I guess it works now?
nnoremap <C-h> <ESC><C-w><C-h>


" reload vimrc
command! ReloadVimrc source $MYVIMRC
command! EditVimrc :edit $MYVIMRC

function! ShowFuncName()
    let lnum = line(".")
    let col = col(".")
    echohl ModeMsg
    echo getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW'))
    echohl None
    call search("\\%" . lnum . "l" . "\\%" . col . "c")
endfunction
command! ShowFuncName call ShowFuncName()

command! -nargs=1 Help vert help <args>

" Open :help in new tab
" https://stackoverflow.com/a/3132202/2958070
cnoreabbrev <expr> h getcmdtype() == ":" && getcmdline() == 'h' ? 'tab help' : 'h'
cnoreabbrev <expr> help getcmdtype() == ":" && getcmdline() == 'help' ? 'tab help' : 'help'

function! Open(open_me)
    let open_me = expand(a:open_me)
    if has('win32')
        execute "silent !start " . a:open_me
    elseif has('mac')
        execute "silent !open " . a:open_me
    else
        execute "silent !xdg-open " . a:open_me
    endif
endfunction
command! Open call Open('%')
command! OpenDir call Open('%:p:h')


function! InstallVimPlug()
    if empty(glob("~/.config/nvim/autoload/plug.vim"))
        if executable('curl')
            let plugpath = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
            silent exec "!curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs " . plugpath
            redraw!
            echom "Now restart the editor"
        else
            echom "Install curl"
        endif
    else
        echom "vim-plug installed!"
    endif
endfunction
command! InstallVimPlug call InstallVimPlug()

if executable("rg")
    set grepprg=rg\ --vimgrep
endif

if executable('cloc')
    command! VimConfigStats exec '!cloc --by-file-by-lang --exclude-dir=syntax,bundle,autoload,templates ~/.config/nvim'
    command! Cloc !cloc %
endif

" https://stackoverflow.com/a/46348040/2958070
" Execute current file
" TODO: this should ChmodX too
" TODO: this should execute ./run.sh or ../run.sh if they exist
" function! Run()
command! Run :!"%:p"

" use zg to add word to word-list
" ]s and [s jump to misspelled words
function! SpellCheckToggle()
    if &spell
        setlocal nospell
        setlocal complete-=kspell
    else
        setlocal spell spelllang=en_us
        " turn on auto-completion with C-n, C-p
        setlocal complete+=kspell
    endif
endfunction
command! SpellCheckToggle call SpellCheckToggle()

command! SearchHLToggle :setlocal invhlsearch

function! NumberToggle()
    if &number
        setlocal nonumber
    else
        setlocal number
    endif
endfunction
command! NumberToggle call NumberToggle()

" TODO: optional filename to save to
function! WriteHTML()
    silent exec "TOhtml"
    silent exec "w"
    silent exec "q"
endfunction

" http://superuser.com/a/277326/643441
command! TouchFile :call writefile([], expand("<cfile>"), "t")

function! UpByIndent()
    norm! ^
    let start_col = col(".")
    let col = start_col
    while col >= start_col
        norm! k^
        if getline(".") =~# '^\s*$'
            let col = start_col
        elseif col(".") <= 1
            return
        else
            let col = col(".")
        endif
    endwhile
endfunction
command! UpByIndent :call UpByIndent()

" http://stackoverflow.com/a/749320/2958070
" exit with :q or :diffoff
function! s:DiffWithSaved()
    let filetype=&ft
    diffthis
    vnew | r # | normal! 1Gdd
    diffthis
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
command! DiffSaved call s:DiffWithSaved()

command! FullPath echo expand('%:p')

function! ChmodX()
    let fname = expand("%:p")
    checktime
    execute "au FileChangedShell " . fname . " :echo"
    silent !chmod a+x %
    checktime
    execute "au! FileChangedShell " . fname
endfunction
command! ChmodX call ChmodX()

" The 'e' on the end of the substitute ignores errors
" -range=% means without a visual selection the whole buffer is selected
"  Special thanks to a @jfim for the link substitution line
"  Note that top level lists can be represented by ^-, not ^*
"  TODO: handle ^# substitution in code blocks
command! -range=% -nargs=0 -bar MarkdownToJira
    \ :<line1>,<line2>s:^  - :** :e
    \ | <line1>,<line2>s:^    - :*** :e
    \ | <line1>,<line2>s:^```:{noformat}:e
    \ | <line1>,<line2>s:^# :h1. :e
    \ | <line1>,<line2>s:^## :h2. :e
    \ | <line1>,<line2>s:^### :h3. :e
    \ | <line1>,<line2>s: `: {{:eg
    \ | <line1>,<line2>s:^`:{{:e
    \ | <line1>,<line2>s:` :}} :eg
    \ | <line1>,<line2>s:`$:}}:eg
    \ | <line1>,<line2>s:`\.:}}.:eg
    \ | <line1>,<line2>s:^\d\+\. :# :e
    \ | <line1>,<line2>s/\v\[([^\]]*)\]\(([^\)]*)\)/[\1|\2]/ge

" TODO: add filtype on top?
" NOTE: add bottom one first to not mess up what's <line2>
command! -range=% -nargs=0 -bar AddCodeFence
    \ :<line2>s:$:\r```:
    \ | <line1>s:^:```\r:

" https://unix.stackexchange.com/a/58748/185953
" <line1>,<line2>VisualSelect
command! -range VisualSelect normal! <line1>GV<line2>G


" Mostly for ordered lists in Markdown
" https://stackoverflow.com/a/4224454/2958070
command! -nargs=0 -range=% NumberLines <line1>,<line2>s/^\s*\zs/\=(line('.') - <line1>+1).'. '
command! -nargs=0 -range=% UnNumberLines <line1>,<line2>s/\d\+\. //g

" https://askubuntu.com/a/686806/483521
command! InsertDate :execute 'norm i' .
    \ substitute(system("date '+%a %b %d - %Y-%m-%d %H:%M:%S %Z'"), '\n\+$', '', '')

" Finally, load secretive stuff not under version control
if !empty(glob("~/.config/nvim_local.vim"))
    source ~/.config/nvim_local.vim
    command! EditNvimLocal :edit ~/.config/nvim_local.vim
endif
