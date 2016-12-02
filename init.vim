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
    autocmd VimEnter * echom "Install vim-plug with :InstallVimPlug and plugins with :PlugInstall"
endif

" Try to use a colorscheme plugin
" but fallback to a default one
try
    " Linux has termguicolors but it ruins the colors...
    if has('termguicolors') && has('mac') && 1
        set termguicolors
    endif
    " get the colorscheme from the environment if it's there
    if !empty($vim_colorscheme)
        colorscheme $vim_colorscheme
    else
        colorscheme gruvbox
        " colorscheme desert-warm-256
        " colorscheme elflord
        " colorscheme railscasts
        " colorscheme dracula
        " colorscheme 0x7A69_dark
        " colorscheme desertedocean
    endif
catch /^Vim\%((\a\+)\)\=:E185/
    " no plugins available
    colorscheme elflord
endtry
set background=dark

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
set guifont=Source\ Code\ Pro:h16 " set font for macvim
set splitbelow
set splitright

" I think this will shorten YCM's function doc window
set previewheight=5

"save temporary files to /tmp/
"if tmp doesn't exist, make it
" http://stackoverflow.com/a/15317146/2958070
" https://www.reddit.com/r/vim/comments/2jpcbo/mkdir_issue/
silent! call mkdir($HOME . '/.config/nvim/backup', 'p')
set backupdir=~/.config/nvim/backup//
silent! call mkdir($HOME . '/.config/nvim/swap', 'p')
set directory=~/.config/nvim/swap//
silent! call mkdir($HOME . '/.config/nvim/undo', 'p')
set undodir=~/.config/nvim/undo//

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
" let mapleader = "\<space>"
let mapleader = ","

" Use bash highlighting instead of sh highlighting
let g:is_posix = 1

" Make some stuff uncopyable on HTML output
" :help :TOhtml
let g:html_prevent_copy = "fn"

" To use the clipboard on linux, install xsel
if has('clipboard')
    set clipboard^=unnamedplus,unnamed
endif

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

augroup vagrant
  au!
  au BufRead,BufNewFile Vagrantfile set filetype=ruby
augroup END


" http://stackoverflow.com/a/18444962/2958070
" TODO: maybe use plugin for this
augroup templates
    au!
    autocmd BufNewFile *.* silent! execute '0r ~/.config/nvim/templates/skeleton.'.expand("<afile>:e")
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
    if has('mac')
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

" https://github.com/FriendsOfPHP/PHP-CS-Fixer
if executable('php-cs-fixer.phar')
    command! AutoPHPCSFixer silent exec "!php-cs-fixer.phar fix " . bufname("%")
endif

if executable('cloc')
    command! VimConfigStats exec '!cloc --by-file-by-lang --exclude-dir=syntax,bundle,autoload,templates ~/.config/nvim'
    command! Cloc !cloc %
endif

" install: cpanmn Perl::Tidy
" use: select the region to tidy and hit '='
if executable('perltidy')
    autocmd FileType perl setlocal equalprg=perltidy\ -st
endif

" use zg to add word to word-list
" ]s and [s jump to misspelled words
function! SpellCheckToggle()
    if &spell
        setlocal nospell
        set complete-=kspell
    else
        setlocal spell spelllang=en_us
        " turn on auto-completion with C-n, C-p
        set complete+=kspell
    endif
endfunction
command! SpellCheckToggle call SpellCheckToggle()

function! SearchHLToggle()
    if &hlsearch
        set nohlsearch
    else
        set hlsearch
    endif
endfunction
command! SearchHLToggle call SearchHLToggle()

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
command! WriteHTML call WriteHTML()
