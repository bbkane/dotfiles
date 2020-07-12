
" From: https://github.com/neovim/nvim-lsp#pyls_ms
" 
" did the dotnet curl script. It put it in ~/.dotnet. Added that to the PATH
" 

call plug#begin('~/.config/nvim/bundle')
Plug 'neovim/nvim-lsp'
call plug#end()

" :LspInstall pyls_ms

lua vim.lsp.set_log_level('debug')

lua <<EOF
    local nvim_lsp = require('nvim_lsp')
    nvim_lsp.pyls_ms.setup{}
EOF

" :help lsp
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

" Use LSP omni-completion in Python files.
" |i_CTRL-X_CTRL-O| to consume LSP completion
autocmd Filetype python setlocal omnifunc=v:lua.vim.lsp.omnifunc

" See language clients
" :lua print(vim.inspect(vim.lsp.buf_get_clients()))
"
" See log path
" :lua print(vim.lsp.get_log_path()
" >> /Users/bbkane/.local/share/nvim/lsp.log

" Let's try to reinstall - https://github.com/neovim/nvim-lsp/blob/master/lua/nvim_lsp/pyls_ms.lua
" removing ~/.cache/nvim/nvim_lsp/pyls_ms
" gonna get python on PATH to point to python3
" LspInstall pyls_ms - gonna wait for 10m now

" can also use :checkhealth to see LSP errors - nothing wrong there...

" Let's try the palantir one...
