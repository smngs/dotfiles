" Defx config
nnoremap <silent>ff :<C-u>Defx -listed -columns=mark:indent:git:icons:filename:type<CR>

let g:floating_win_width_percent = 0.8
let g:floating_win_height_percent = 0.8

call defx#custom#option('_', {
      \ 'split': 'floating',
      \ 'vertical_preview': v:true,
      \ 'floating_preview': v:true,
      \ 'preview_width': float2nr(&columns * g:floating_win_width_percent / 2),
      \ 'preview_height': float2nr(&lines * g:floating_win_height_percent),
      \ 'wincol': float2nr((&columns - (&columns * g:floating_win_width_percent)) / 2),
      \ 'winrow': float2nr((&lines - (&lines * g:floating_win_height_percent)) / 2),
      \ 'winwidth': float2nr(&columns * g:floating_win_width_percent / 2),
      \ 'winheight': float2nr(&lines * g:floating_win_height_percent),
      \ })

autocmd FileType defx call s:defx_my_settings()
function! s:defx_my_settings() abort
  " Define mappings
  nnoremap <silent><buffer><expr> <Space>
        \ defx#do_action('multi', [['drop', 'split'], 'quit'])
  nnoremap <silent><buffer><expr> <Esc>
        \ defx#do_action('quit')
  nnoremap <silent><buffer><expr> q
        \ defx#do_action('quit')
  nnoremap <silent><buffer><expr> ..
        \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> h
        \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> c
        \ defx#do_action('copy')
  nnoremap <silent><buffer><expr> p
        \ defx#do_action('paste')
  nnoremap <silent><buffer><expr> d
        \ defx#do_action('remove')
  nnoremap <silent><buffer><expr> r
        \ defx#do_action('rename')
  nnoremap <silent><buffer><expr> m
        \ defx#do_action('move')
  nnoremap <silent><buffer><expr> n
        \ defx#do_action('new_file')
  nnoremap <silent><buffer><expr> N
        \ defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> yy
        \ defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> <CR>
        \ defx#is_directory() ?
        \ defx#do_action('open') :
        \ defx#do_action('multi', [['open', 'choose'], 'quit']) 
  nnoremap <silent><buffer><expr> l
        \ defx#is_directory() ?
        \ defx#do_action('open') :
        \ defx#do_action('multi', [['open', 'choose'], 'quit']) 
  nnoremap <silent><buffer><expr> E
        \ defx#do_action('multi', [['open', 'vsplit'], 'quit'])
  nnoremap <silent><buffer><expr> v
        \ defx#do_action('multi', [['open', 'vsplit'], 'quit'])
  nnoremap <silent><buffer><expr> s
        \ defx#do_action('multi', [['open', 'split'], 'quit'])
  nnoremap <silent><buffer><expr> j
        \ line('.') == line('$') ? 'gg' : 'j' . defx#do_action('preview')
  nnoremap <silent><buffer><expr> k
        \ line('.') == 1 ? 'G' : 'k' . defx#do_action('preview')
  nnoremap <silent><buffer><expr> x
        \ defx#do_action('execute_system')
  nnoremap <silent><buffer><expr> <C-l>
        \ defx#do_action('redraw')
endfunction
