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

" Character code
set fileencoding=utf-8
set fileencodings=ucs-boms,utf-8,euc-jp,cp932
set fileformats=unix,dos,mac
set ambiwidth=double

" Tab / Indent
set expandtab
set tabstop=4
set softtabstop=4
set autoindent
set smartindent
set shiftwidth=4

" Search
set incsearch
set ignorecase
set smartcase
set hlsearch

" Lightline
set laststatus=2
set t_Co=256
syntax enable

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
source $VIMRUNTIME/macros/matchit.vim

set guifont=CodeM
set wildmenu
set history=5000
colorscheme iceberg

if &term=~ "xterm"
    let &t_SI .= "\e[?2004h"
    let &t_EI .= "\e[?2004l"
    let &pastetoggle = "\e[201~"

    function XTermPasteBegin(ret)
        set paste
        return a:ret
    endfunction

    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif 

" Plugins
" lightline
let g:lightline = {'colorscheme': 'wombat'}

" vim-markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0
let g:tex_conceal = 0
let g:vim_markdown_math = 1

" previm
let g:previm_disable_default_css = 1
let g:previm_custom_css_path = '~/Dotfiles/.config/nvim/markdown.css'

" vimtex
let g:vimtex_fold_envs = 0
let g:vimtex_view_general_viewer = 'evince'
let g:vimtex_view_general_options = '-r @line @pdf @tex'
let g:vimtex_compiler_latexmk = {
      \ 'options' : [
      \   '-verbose',
      \   '-file-line-error',
      \   '-synctex=1',
      \   '-interaction=nonstopmode',
      \ ]}
let g:vimtex_compiler_progname = 'nvr'

" snippets
" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
"imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" " For conceal markers.
" if has('conceal')
"   set conceallevel=2 concealcursor=niv
" endif

let g:tex_flavor='latex' 

"set snippet file dir
let g:neosnippet#snippets_directory='~/.vim/bundle/neosnippet-snippets/snippets/,~/.vim/snippets'
