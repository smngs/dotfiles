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
