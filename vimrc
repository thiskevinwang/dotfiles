"----------------------------------------------------------------------
" Plugins
"----------------------------------------------------------------------
"
call plug#begin()
" For everforest colorscheme to work, make sure it's at thhe top of the plugin
" list
Plug 'sainnhe/everforest'
" For vim-colors-github to work, make sure it's at the top of the plugin list
Plug 'cormacrelf/vim-colors-github'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'fatih/vim-go', { 'tag': '*', 'do': ':GoUpdateBinaries' }
Plug 'gcmt/taboo.vim'
Plug 'plasticboy/vim-markdown'
Plug 'tpope/vim-fugitive'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'scrooloose/nerdtree'
Plug 'myusuf3/numbers.vim'
call plug#end()

"-------------------------------------------------------------
" Fix issue where code comments have highlighted background
" and aren't italic
" - https://github.com/mhartington/oceanic-next/issues/25a
" - https://stackoverflow.com/a/21077380/9823455
set t_ZH=[3m
set t_ZR=[23m
"-------------------------------------------------------------


" Important!!
if has('termguicolors')
  set termguicolors
endif

" For dark version.
set background=dark

" For light version.
" set background=light

" Set contrast.
" This configuration option should be placed before `colorscheme everforest`.
" Available values: 'hard', 'medium'(default), 'soft'
let g:everforest_background = 'hard'

colorscheme everforest

" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

" Airline
let g:airline#extensions#tabline#enabled = 1
" No Arrows, only rectangles — https://github.com/vim-airline/vim-airline/issues/1688
let g:airline_powerline_fonts = 1
"let g:airline_theme='github'
let g:airline_theme='angr'

nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

nnoremap <C-i> :bn<CR>

" Ctrl+d forward-delete
inoremap <C-d> <Del>
