" use stuff from vim.wikia.com example vimrc
filetype indent plugin on
syntax on
set wildmenu "Use tab to complete stuff in vim menu
set showcmd " show partial commands in the last line of screen
" case insensitive search except for capital letters
set ignorecase
set smartcase
set backspace=indent,eol,start	" allow backspacing over characters
set autoindent    " Auto-indent new lines if no filetype
set ruler	" Show row and column ruler information
set noerrorbells

if !has("gui_running")
    set confirm "open a save dialog when quitting"
endif

" Only use a soft wrap, not a hard one
set wrap
set linebreak     " Break lines at word (requires Wrap lines)
set nolist
set showbreak=+++ " Wrap-broken line prefix
set textwidth=0 " Line wrap (number of cols)
set wrapmargin=0

set expandtab     " Use spaces instead of tabs
set shiftwidth=4  " Number of auto-indent spaces
set softtabstop=4 " Number of spaces per Tab

set number        " Show line numbers
set showmatch     " Highlight matching brace
set undolevels=1000	" Number of undo levels
set nohlsearch
set guifont=Source\ Code\ Pro:h13 " set font for macvim

" map j to gj and k to gk, so line navigation ignores line wrap
nmap j gj
nmap k gk

" Tab through buffers (writes to them...)
nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>

" This seems to make my space key slow...
" let mapleader = "\<SPACE>"
let mapleader = ","

" set clipboard+=unnamedplus

inoremap fd <ESC>

" save without sudo vim
cmap w!! w !sudo tee > /dev/null %


if has("nvim")
    " Disable mouse
    set mouse-=a

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

au BufRead,BufNewFile *.rs set filetype=rust

" disable error bels
if !has("nvim")
    set nocompatible
    set visualbell t_vb=
endif

" This is now on plug in
" split settings
" Still doesn't hurt to have it here...
nnoremap <C-n> <C-w><C-w>
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
" all the other mappings work but this one...
nnoremap <C-h> <C-w><C-h>

set splitbelow
set splitright

"save temporary files to /tmp/
"if tmp doesn't exist, make it
set backupdir=~/tmp,.
set directory=~/tmp,.

" save, make, run (depends on makeprg)
map <F5> :w<CR> :make<CR> :!./%:r.out<CR>

" Sometimes I dont want to indent (yaml files in particular)
command! StopIndenting setl noai nocin nosi inde=

" Set Visual Studio style indents
command! VSIndentStyle set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab

" reload vimrc
command! ReloadVimrc source $MYVIMRC
command! EditVimrc :edit $MYVIMRC

" Search for a project specific vimrc upward
" THIS IS INSECURE. BE CAREFUL.
" :help fnamemodify to learn to search only search one upwards.
" Need to do that
function! SourceFileUpwards(filename)
    let proj = findfile(a:filename, ".;")
    if proj != ""
        exec "source " . proj
    " else
    "     echo "No " . a:filename . " found"
    endif
endfunction

function! ShowFuncName()
    let lnum = line(".")
    let col = col(".")
    echohl ModeMsg
    echo getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bW'))
    echohl None
    call search("\\%" . lnum . "l" . "\\%" . col . "c")
endfunction

command! ShowFuncName call ShowFuncName()

function! BensCommands()
    echo "<C-g> : Name of buffer"
    echo "gd : local var definition"
    echo "gD : global var definition"
    echo "<C-i> : go forward"
    echo "<C-o> : go back"
    echo "-- CTAGS --"
    echo "<C-]> : goto def"
    echo "<C-t> : come from"
    echo "-- END CTAGS --"
endfunction
command! BensCommands call BensCommands()

command! -nargs=1 Help vert help <args>

function! Open()
    if has("darwin")
        execute "silent !open %"
    else
        execute "silent !xdg-open %"
    endif
endfunction
command! Open call Open()

