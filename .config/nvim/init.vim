" reset augroup
augroup MyAutoCmd
    autocmd!
augroup END

noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

cnoremap w!! w !sudo tee > /dev/null %<CR> :e!<CR>
nnoremap x "_x

cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'

inoremap <silent> jj <ESC>
inoremap <silent> っｊ <ESC>
inoremap <silent> っj <ESC>

" ENV
let $CACHE = empty($XDG_CACHE_HOME) ? expand('$HOME/.cache') : $XDG_CACHE_HOME
let $CONFIG = empty($XDG_CONFIG_HOME) ? expand('$HOME/.config') : $XDG_CONFIG_HOME
let $DATA = empty($XDG_DATA_HOME) ? expand('$HOME/.local/share') : $XDG_DATA_HOME

" Load rc file
function! s:load(file) abort
    let s:path = expand('$CONFIG/nvim/rc/' . a:file . '.vim')
    if filereadable(s:path)
        execute 'source' fnameescape(s:path)
    endif
endfunction

call s:load('plugins')

filetype plugin indent on
syntax on

" Colorscheme
set termguicolors
colorscheme iceberg

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

" Undo
if has('persistent_undo')
  set undodir=~/.config/nvim/undo
  set undofile
endif

" Clipboard
set clipboard+=unnamedplus

" Character code
set fileencoding=utf-8
set fileencodings=ucs-boms,utf-8,euc-jp,cp932
set fileformats=unix,dos,mac
set ambiwidth=double

" Tab / Indent
set expandtab
set tabstop=2
set softtabstop=2
set autoindent
set smartindent
set shiftwidth=2

" Search
set incsearch
set ignorecase
set smartcase
set hlsearch

" Lightline
set laststatus=2

nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

set whichwrap=b,s,h,l,<,>,[,],~
set number
set cursorline

nnoremap j gj
nnoremap k gk
nnoremap <down> gj
nnoremap <up> gk
" noremap ; :
" noremap : ;

set backspace=indent,eol,start

set showmatch

set wildmenu
set wildmode=full
set history=5000

function! s:auto_mkdir(dir, force) abort " {{{
  if !isdirectory(a:dir) && (a:force || input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
    call mkdir(iconv(a:dir, &enc, &tenc), 'p')
  endif
endfunction " }}}
autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)

function! s:comma_period(line1, line2) abort range " {{{
  let cursor = getcurpos()
  execute 'silent keepjumps keeppatterns' a:line1 ',' a:line2 's/、/，/ge'
  execute 'silent keepjumps keeppatterns' a:line1 ',' a:line2 's/。/．/ge'
  call setpos('.', cursor)
endfunction " }}}
command! -bar -range=% CommaPeriod  call s:comma_period(<line1>, <line2>)

function! s:kutouten(line1, line2) abort range " {{{
  let cursor = getcurpos()
  execute 'silent keepjumps keeppatterns' a:line1 ',' a:line2 's/，/、/ge'
  execute 'silent keepjumps keeppatterns' a:line1 ',' a:line2 's/．/。/ge'
  call setpos('.', cursor)
endfunction " }}}
command! -bar -range=% Kutouten  call s:kutouten(<line1>, <line2>)

let g:yankring_n_keys = 'Y D'
" default
" let g:yankring_n_keys = 'Y D x X'
"
function! Fcitx2en()
 let s:input_status = system("fcitx-remote")
 if s:input_status == 2
    let l:a = system("fcitx-remote -c")
 endif
endfunction

set ttimeoutlen=150
autocmd InsertLeave * call Fcitx2en()
