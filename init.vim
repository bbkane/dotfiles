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

" Linux has termguicolors but it ruins the colors...
if has('termguicolors') && (has('mac') || has('win32'))
    set termguicolors
endif

" Try to use a colorscheme plugin
" but fallback to a default one
try
    " get the colorscheme from the environment if it's there
    if !empty($vim_colorscheme)
        colorscheme $vim_colorscheme
    else
        " colorscheme gruvbox
        " colorscheme desert-warm-256
        " colorscheme elflord
        " colorscheme railscasts
        " colorscheme dracula
        " colorscheme 0x7A69_dark
        colorscheme desertedocean
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

set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.

set shiftwidth=4    " Indents will have a width of 4

set softtabstop=4   " Sets the number of columns for a TAB

set expandtab       " Expand TABs to spaces

" Custom indent settings per filetype
augroup custom_filetype_indents
    autocmd!
    " Only use tabs in gitconfig
    " https://stackoverflow.com/questions/3682582/how-to-use-only-tab-not-space-in-vim
    autocmd BufRead,BufNewFile .gitconfig setlocal autoindent noexpandtab tabstop=8 shiftwidth=8
    " Use 2 spaces to indent in these
    autocmd FileType html,javascript,json,ruby,typescript,yaml setlocal shiftwidth=2 softtabstop=2
augroup END

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

" Sometimes I dont want to indent (yaml files in particular)
command! StopIndenting setl noai nocin nosi inde=

" Set Visual Studio style indents
command! VSIndentStyle set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab

" Done with indenting yay!

augroup custum_filetypes
    autocmd!
    autocmd BufRead,BufNewFile *.rs set filetype=rust
    autocmd BufRead,BufNewFile Vagrantfile set filetype=ruby
    " custom Lync highlighting
    autocmd BufRead,BufNewFile *.lync set filetype=lync
    " https://superuser.com/a/907889/643441
    autocmd filetype crontab setlocal nobackup nowritebackup
augroup END

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



" map j to gj and k to gk, so line navigation ignores line wrap
nmap j gj
nmap k gk

" Tab through buffers (writes to them...)
nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>

" This seems to make my space key slow...
let mapleader = " "

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

inoremap fd <ESC>

" save without sudo vim
cmap w!! w !sudo tee > /dev/null %


if has("nvim")
    " Disable mouse
    if !has('win32')
        set mouse-=a
    endif

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
" TODO: maybe use plugin for this
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
    echo "gq : Format selected text"
    echo "-- CTAGS --"
    echo "<C-]> : goto def"
    echo "<C-t> : come from"
    echo "-- END CTAGS --"
endfunction
command! BensCommands call BensCommands()

command! -nargs=1 Help vert help <args>

function Open(open_me)
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

if executable('python')
    command! JSONFormat %!python -m json.tool
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
        setlocal complete-=kspell
    else
        setlocal spell spelllang=en_us
        " turn on auto-completion with C-n, C-p
        setlocal complete+=kspell
    endif
endfunction
command! SpellCheckToggle call SpellCheckToggle()
" format existing text by selecting it and using `gq`

function! BlogMode()
    setlocal textwidth=80
    setlocal nonumber
    " set background=light
    " Get a margin
    " https://stackoverflow.com/a/7941499/2958070
    setlocal foldcolumn=4
    highlight FoldColumn guibg=gray14
    call SpellCheckToggle()
endfunction
command! BlogMode call BlogMode()

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
" This command will be called on `:W`, and I misspress Caps Lock and :w too
" much to trust it
" command! WriteHTML call WriteHTML()

" http://superuser.com/a/277326/643441
command! MakeFile :call writefile([], expand("<cfile>"), "t")

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


" TODO: Make this work to replace visual selections
" python -c "import sys, pprint, ast; obj = ast.literal_eval(sys.stdin.read()); pprint.pprint(obj)"

" TODO: figure out a way to insert the date on command

command! SourceCurrent source % | echo "Sourced " . expand('%')

" Visually select \n separated IPs, then call this
" NOTE: I'm not convinced that I can't do something simpler with the
" `function! Name() range` syntax
" or aliasing `:pyfile somehow`
fun! SortLinesByIP()
python3 << EOF

import vim
import socket

# https://stackoverflow.com/a/18168075/2958070
buf = vim.current.buffer
(lnum1, col1) = buf.mark('<')
(lnum2, col2) = buf.mark('>')

# Vim likes to count from 1 and Python from 0
lines = buf[lnum1 - 1: lnum2]
len_selected_lines = len(lines)
# remove whitespace and empty lines
# TODO: use a regex capturing group to grap '<stuff><ip><stuff>' then sort by IP
lines = [line.strip() for line in lines if line.strip()]
# I need the same amount of lines to put back
assert len(lines) == len_selected_lines, "No whitespace-only lines allowed"
lines.sort(key=socket.inet_aton)
buf[lnum1 - 1: lnum2] = lines

EOF
endfun
" https://stackoverflow.com/a/2585673/2958070
command! -range=% -nargs=0 SortLinesByIP :<line1>,<line2> call SortLinesByIP()

" The 'e' on the end of the substitute ignores errors
" -range=% means without a visual selection the whole buffer is selected
command! -range=% -nargs=0 -bar MarkdownToJira
    \ :<line1>,<line2>s:^- :* :e
    \ | <line1>,<line2>s:^  - :** :e
    \ | <line1>,<line2>s:^```:{noformat}:e
    \ | <line1>,<line2>s:^# :h1. :e
    \ | <line1>,<line2>s:^## :h2. :e
    \ | <line1>,<line2>s: `: {{:eg
    \ | <line1>,<line2>s:^`:{{:eg
    \ | <line1>,<line2>s:` :}} :eg
    \ | <line1>,<line2>s:`$:}}:eg
    \ | <line1>,<line2>s:`\.:}}.:eg

" https://unix.stackexchange.com/a/58748/185953
" <line1>,<line2>VisualSelect
command! -range VisualSelect normal! <line1>GV<line2>G

" Finally, load specific stuff
if !empty(glob("~/.config/nvim_local.vim"))
    " Source company specific stuff
    source ~/.config/nvim_local.vim
    command! EditNvimLocal :edit ~/.config/nvim_local.vim
endif
