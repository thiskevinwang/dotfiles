"----------------------------------------------------------------------
" Plugins
"----------------------------------------------------------------------
"
call plug#begin()
" For everforest colorscheme to work, make sure it's at thhe top of the plugin
" list
Plug 'sainnhe/everforest'
" For vim-colors-github to work, make sure it's at the top of the plugin list
" Plug 'cormacrelf/vim-colors-github'
Plug 'projekt0n/github-nvim-theme'

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
Plug 'b4b4r07/vim-hcl'

Plug 'scrooloose/nerdtree'
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'

Plug 'myusuf3/numbers.vim'
Plug 'prettier/vim-prettier', { 'do': 'npm i' }
Plug 'cespare/vim-toml', { 'branch': 'main' }
Plug 'github/copilot.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'sindrets/diffview.nvim'
Plug 'akinsho/toggleterm.nvim',{ 'tag': 'v2.*' }
call plug#end()

" keep cursor as a block during insert mode
set guicursor=i:block

"-------------------------------------------
" prettier
"-------------------------------------------
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0
let g:prettier#autoformat_config_present = 0

set tabstop=2
set shiftwidth=2

"-------------------------------------------------------------
" Fix issue where code comments have highlighted background
" and aren't italic
" - https://github.com/mhartington/oceanic-next/issues/25
" - https://stackoverflow.com/a/21077380/9823455
set t_ZH=[3m
set t_ZR=[23m
"-------------------------------------------------------------

if has('termguicolors')
	set termguicolors
endif

" For dark version.
set background=dark

" For light version.
" set background=light

"-------------------------------------------------------------
" Set nvim theme to github
" Set vim theme to everforest
"-------------------------------------------------------------
if has('nvim')
	colorscheme github_dark
else
	let g:everforest_background = 'hard'
	colorscheme everforest
endif


" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
			\ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

" Airline
let g:airline#extensions#tabline#enabled = 1
" No Arrows, only rectangles — https://github.com/vim-airline/vim-airline/issues/1688
let g:airline_powerline_fonts = 1
"let g:airline_theme='github'
"let g:airline_theme='angr'
let g:airline_theme='violet'

" change leader key
let mapleader = ","

"-------------------------------------------------------------
" File tree
" - vim: NERDTree
" - nvim: nvim-tree.lua
"-------------------------------------------------------------
if has('nvim')
	lua require'nvim-tree'.setup {}
	nnoremap <C-n> :NvimTreeToggle<CR>
	nnoremap <leader>r :NvimTreeRefresh<CR>
	nnoremap <leader>n :NvimTreeFindFile<CR>
else
	nnoremap <leader>n :NERDTreeFocus<CR>
	nnoremap <C-n> :NERDTree<CR>
	nnoremap <C-t> :NERDTreeToggle<CR>
	" nnoremap <C-f> :NERDTreeFind<CR>
endif


" Relies on iTerm mapping of ⌘j to \<C-j>
" Open terminal; Like VScode behavior
if has('nvim')
	nnoremap <C-J> :ToggleTerm<CR>
else
	nnoremap <C-j> :term<CR>
endif

" Ctrl+d forward-delete in INSERT mode
inoremap <C-d> <Del>
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-p> <Up>
inoremap <C-n> <Down>

" Make integrated terminal open below
set splitbelow

if !has('nvim')
	set termwinsize=25x0
endif

set belloff=all

" Notes
" [Ctrl-w w] swaps between editor & terminal windows
" [Ctrl-d]   in terminal, closes terminal
"
" Resizing buffer splits
" [Ctrl-w =] makes splits equal size
" [Ctrl-w -] decreases current split by 1
" [Ctrl-w +] increases current split by 1
" [Ctrl-w _] maximizes current split
" [Ctrl-w :resize 20] resizes current split to the specified height
"
"
" Scrolling in terminal
" [Ctrl-w Shift-n] pauses terminal; You can navigate now
"   [i] resumes terminal
"
" Mapping mac command key (⌘) — 2 step process
" 1. Specify a Keyboard Shortcut in iTerm2
"    > Preferences > Profiles > Keys
"      > Keyboard Shortcut: ⌘j
"      > Action Send Text with “vim” Special Chars
"        example: ⌘j -> \<C-j>
" 2. Specify the mapping in .vimrc as usual
