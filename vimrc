"----------------------------------------------------------------------
" Plugins
"----------------------------------------------------------------------
"
call plug#begin()
" For everforest colorscheme to work, make sure it's at the top of the plugin
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
Plug 'LnL7/vim-nix'
Plug 'scrooloose/nerdtree'
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'

Plug 'myusuf3/numbers.vim'
Plug 'prettier/vim-prettier', { 'do': 'npm i' }
Plug 'cespare/vim-toml', { 'branch': 'main' }
Plug 'github/copilot.vim'
Plug 'sindrets/diffview.nvim'
Plug 'preservim/nerdcommenter'
if has('nvim')
	Plug 'akinsho/toggleterm.nvim',{ 'tag': 'v2.*' }
	Plug 'nvim-lua/plenary.nvim'
	Plug 'nvim-telescope/telescope.nvim'
	Plug 'rcarriga/nvim-notify'
	Plug 'f-person/auto-dark-mode.nvim'
endif
Plug 'kristijanhusak/vim-simple-notifications'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" For https://vimawesome.com/plugin/the-nerd-commenter
filetype plugin on
" Create default mappings
let g:NERDCreateDefaultMappings = 1

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
" set background=light

" For light version.
" set background=light

"-------------------------------------------------------------
" Set nvim theme to github
" Set vim theme to everforest
"-------------------------------------------------------------
if has('nvim')
	colorscheme github_dark " github_light | github_dark
else
	let g:everforest_background = 'hard'
	colorscheme everforest
endif


" Airline
let g:airline#extensions#tabline#enabled = 1
" No Arrows, only rectangles — https://github.com/vim-airline/vim-airline/issues/1688
let g:airline_powerline_fonts = 1
"let g:airline_theme='base16_google_dark'
"let g:airline_theme='angr'
let g:airline_theme='violet'

" change leader key
"let mapleader = ","


" start up notification
"
"call notifications#info([
"			\"🐶 Welcome to nvim!",
"			\"ℹ️  Note: Leader is (\\)",
"			\"",
"			\"",
"			\"Useful cmds:",
vmap ÷ <plug>NERDCommenterToggle<CR>gv


"-------------------------------------------------------------
" File tree
" - vim: NERDTree
" - nvim: nvim-tree.lua
"-------------------------------------------------------------
autocmd StdinReadPre * let s:std_in=1

"-- open NERDTree on `vim .` ---------------------------------
autocmd VimEnter * if argc() == 1 && has('vim') && isdirectory(argv()[0]) && !exists('s:std_in') |
			\ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

"-- open nvim-tree on `nvim .` -------------------------------
autocmd VimEnter * if argc() == 1 && has('nvim') && isdirectory(argv()[0]) && !exists('s:std_in') |
			\ execute 'NvimTreeOpen' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
"-- auto close nvim-tree if last window is closed ------------
"autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif
"-------------------------------------------------------------

if has('nvim')
	lua require'nvim-tree'.setup {}
	"nnoremap <C-n> :NvimTreeToggle<CR>
	nnoremap <leader>r :NvimTreeRefresh<CR>
	nnoremap <leader>n :NvimTreeFindFile<CR>
else
	nnoremap <leader>n :NERDTreeFocus<CR>
	nnoremap <C-n> :NERDTree<CR>
	nnoremap <C-t> :NERDTreeToggle<CR>
	" nnoremap <C-f> :NERDTreeFind<CR>
endif


" Ctrl+d forward-delete in INSERT mode
inoremap <C-d> <Del>

inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-p> <Up>
inoremap <C-n> <Down>

" Ctrl+h/j/k/l/ navigates between splits
nnoremap <C-h> <C-W>h " left
nnoremap <C-l> <C-W>l " right
nnoremap <C-j> <C-W>j " down
nnoremap <C-k> <C-W>k " up

" Make integrated terminal open below
set splitbelow

if !has('nvim')
	set termwinsize=25x0
endif

set belloff=all

" http://vimcasts.org/episodes/neovim-terminal-mappings/
if has('nvim')
	tnoremap <Esc> <C-\><C-n>
	tnoremap <M-[> <Esc>
	tnoremap <C-v><Esc> <Esc>
endif

" "-------------------------------------------------------------
" " https://github.com/neoclide/coc.nvim
"
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
  inoremap <silent><expr> <c-@> coc#refresh()

	" Make <CR> auto-select the first completion item and notify coc.nvim to
	" format on enter, <cr> could be remapped by other vim plugin
	inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
								\: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

	" Use `[g` and `]g` to navigate diagnostics
	" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
	nmap <silent> [g <Plug>(coc-diagnostic-prev)
	nmap <silent> ]g <Plug>(coc-diagnostic-next)

  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
