" let os=substitute(system('uname'), '\n', '', '')
" os == 'Darwin' or os == 'Linux'
" use has("darwin") for mac and !has("darwin") for linux

if executable('git') && !empty(glob("~/.config/nvim/autoload/plug.vim"))
    " look for plugins in bundle/
    call plug#begin('~/.config/nvim/bundle')

    if !empty(glob("~/.config/nvim/plugins.vim"))
        " Source my plugins!
        source ~/.config/nvim/plugins.vim
        command! EditPlugins :edit ~/.config/nvim/plugins.vim
    endif

    if !empty(glob("~/.config/nvim/ide.vim"))
        " Source IDE Plugins
        source ~/.config/nvim/ide.vim
        command! EditIDE :edit ~/.config/nvim/ide.vim
    endif

    " End plugins
    call plug#end()
else
    autocmd VimEnter * echom "Install vim-plug with command InstallVimPlug"
endif

try
    " These colorschemes are plugins
    " If they're not available, use a default
    if has('termguicolors')
        set termguicolors
        colorscheme gruvbox
        set background=dark
    else
        " no termguicolors
        colorscheme desert-warm-256
    endif
catch /^Vim\%((\a\+)\)\=:E185/
    " no plugins available
    colorscheme elflord
endtry

" use stuff from vim.wikia.com example vimrc
filetype indent plugin on
syntax on
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
set showbreak=+++                 " Wrap-broken line prefix
set textwidth=0                   " Line wrap (number of cols)
set wrapmargin=0

set expandtab                     " Use spaces instead of tabs
set shiftwidth=4                  " Number of auto-indent spaces
set softtabstop=4                 " Number of spaces per Tab

set number                        " Show line numbers
set showmatch                     " Highlight matching brace
set undolevels=1000               " Number of undo levels
set nohlsearch
set guifont=Source\ Code\ Pro:h13 " set font for macvim
set splitbelow
set splitright

if has('termguicolors')
    set termguicolors " Use gui colors in terminal if possible
endif

"save temporary files to /tmp/
"if tmp doesn't exist, make it
set backupdir=~/tmp,.
set directory=~/tmp,.

if !has("gui_running")
    set confirm "open a save dialog when quitting"
endif

" map j to gj and k to gk, so line navigation ignores line wrap
nmap j gj
nmap k gk

" Tab through buffers (writes to them...)
nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>

" This seems to make my space key slow...
" let mapleader = "\<SPACE>"
let mapleader = ","

" Use bash highlighting instead of sh highlighting
let g:is_posix = 1

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

" disable error bells
if !has("nvim")
    set nocompatible
    set visualbell t_vb=
endif

" Valloric tweaks
" Unicode support (taken from http://vim.wikia.com/wiki/Working_with_Unicode)
if has("multi_byte") && !has("nvim")
    if &termencoding == ""
        let &termencoding = &encoding
    endif
    set encoding=utf-8
    setglobal fileencoding=utf-8
    set fileencodings=ucs-bom,utf-8,latin1
endif

augroup vimrc
    " Automatically delete trailing DOS-returns and whitespace on file open and
    " write.
    autocmd BufRead,BufWritePre,FileWritePre * silent! %s/[\r \t]\+$//
augroup END


augroup vagrant
  au!
  au BufRead,BufNewFile Vagrantfile set filetype=ruby
augroup END

" This is now on plug in
" split settings
" Still doesn't hurt to have it here...
nnoremap <C-n> <C-w><C-w>
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
" all the other mappings work but this one...
nnoremap <C-h> <C-w><C-h>

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

" pip
if executable('autoflake')
    command! AutoFlake silent exec "!autoflake --in-place " . bufname("%")
endif

" pip
if executable('autopep8')
    command! AutoPep8 silent exec "!autopep8 --in-place --max-line-length 150 " . bufname("%")
endif

if executable('cloc')
    command! VimConfigStats !cloc --by-file-by-lang --exclude-dir=syntax,bundle,autoload %:p:h
endif

" cpanmn Perl::Tidy
if executable('perltidy')
    autocmd FileType perl setlocal equalprg=perltidy\ -st
endif
