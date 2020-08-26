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

" This is ok...
let g:deus_termcolors=256
Plug 'ajmwagar/vim-deus'


let g_airline_theme='oceanicnext'
Plug 'mhartington/oceanic-next'

" This adds a *bunch* of colorschemes
Plug 'flazz/vim-colorschemes'
if has('nvim')
    Plug 'Soares/base16.nvim'
endif

Plug 'mitsuhiko/fruity-vim-colorscheme'

let g:sonokai_style = 'maia'
let g:airline_theme = 'sonokai'
Plug 'sainnhe/sonokai'

let g:gruvbox_material_background = 'soft'
" let g:gruvbox_material_background = 'medium'
Plug 'sainnhe/gruvbox-material'

Plug 'haishanh/night-owl.vim'

" let ayucolor="dark"   " for dark version of theme
" let ayucolor="light"  " for light version of theme
let ayucolor="mirage" " for mirage version of theme
Plug 'ayu-theme/ayu-vim' " or other package manager

let g:airline_theme = 'miramare'
let g:miramare_disable_italic_comment = 1
let g:miramare_palette = {
    \ 'grey': ['#928374', '245','LightGrey'],
    \ 'light_grey': ['#c0c0c0', '245', 'LightGrey']
    \ }
" Plug 'franbach/miramare'
" Plug '~/Git/miramare'
Plug 'bbkane/miramare'  " TODO: switch back if my PR gets merged
