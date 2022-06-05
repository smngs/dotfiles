" ---------------------------------
"
" (_)_ __ (_) |___   _(_)_ __ ___
" | | '_ \| | __\ \ / / | '_ ` _ \
" | | | | | | |_ \ V /| | | | | | |
" |_|_| |_|_|\__(_)_/ |_|_| |_| |_|
"
" ---------------------------------

" ---------------------------------
" Reset augroup
" ---------------------------------

augroup MyAutoCmd
    autocmd!
augroup END

" ---------------------------------
" ENV
" ---------------------------------

let $CACHE = empty($XDG_CACHE_HOME) ? expand('$HOME/.cache') : $XDG_CACHE_HOME
let $CONFIG = empty($XDG_CONFIG_HOME) ? expand('$HOME/.config') : $XDG_CONFIG_HOME
let $DATA = empty($XDG_DATA_HOME) ? expand('$HOME/.local/share') : $XDG_DATA_HOME

" ---------------------------------
" Include rc 
" ---------------------------------

function! s:load(file) abort
    let s:path = expand('$CONFIG/nvim/rc/' . a:file . '.vim')
    if filereadable(s:path)
        execute 'source' fnameescape(s:path)
    endif
endfunction

call s:load('plugins')

" ---------------------------------
" Mapping
" ---------------------------------

cnoremap w!! w !sudo tee > /dev/null %<CR> :e!<CR>
nnoremap x "_x

cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'

inoremap <silent> jj <ESC>
inoremap <silent> っｊ <ESC>
inoremap <silent> っj <ESC>


nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

nnoremap j gj
nnoremap k gk
nnoremap <down> gj
nnoremap <up> gk

" ---------------------------------
" Colorscheme / syntax
" ---------------------------------

highlight Normal ctermbg=NONE guibg=NONE
highlight NonText ctermbg=NONE guibg=NONE
highlight SpecialKey ctermbg=NONE guibg=NONE
highlight EndOfBuffer ctermbg=NONE guibg=NONE

augroup TransparentBG
  	autocmd!
	autocmd Colorscheme * highlight Normal ctermbg=none
	autocmd Colorscheme * highlight NonText ctermbg=none
	autocmd Colorscheme * highlight LineNr ctermbg=none
	autocmd Colorscheme * highlight Folded ctermbg=none
	autocmd Colorscheme * highlight EndOfBuffer ctermbg=none 
augroup END

filetype plugin indent on
syntax on

" ---------------------------------
" Lightline
" ---------------------------------

set laststatus=2

" ---------------------------------
" linenumber
" ---------------------------------

set relativenumber number
set signcolumn=yes:1

" ---------------------------------
" Undo
" ---------------------------------

if has('persistent_undo')
  set undodir=~/.config/nvim/undo
  set undofile
endif

" ---------------------------------
" Clipboard
" ---------------------------------

set clipboard+=unnamedplus

" ---------------------------------
" Character code
" ---------------------------------

set fileencoding=utf-8
set fileencodings=ucs-boms,utf-8,euc-jp,cp932
set fileformats=unix,dos,mac
set ambiwidth=double

" ---------------------------------
" Tab / Indent
" ---------------------------------

set expandtab
set tabstop=2
set softtabstop=2
set autoindent
set smartindent
set shiftwidth=2

" ---------------------------------
" Search
" ---------------------------------

set incsearch
set ignorecase
set smartcase
set hlsearch

set whichwrap=b,s,h,l,<,>,[,],~
set cursorline

set backspace=indent,eol,start

set showmatch

set wildmenu
set wildmode=full
set history=5000

" ---------------------------------
" Mouse
" ---------------------------------

set mouse=a
