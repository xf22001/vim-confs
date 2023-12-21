""" Configuration example

" let g:translator_target_lang = 'zh'
" let g:translator_source_lang = 'auto'
let g:translator_proxy_url = 'socks5://127.0.0.1:1080'
" let g:translator_default_engines = ['bing', 'google', 'haici', 'youdao']
" or ['google']
let g:translator_default_engines = ['google']
" let g:translator_history_enable = 'false'
" let g:translator_window_type = 'popup'
" let g:translator_window_max_width = '0.6'
" let g:translator_window_max_height = '0.6'
" let g:translator_window_borderchars = ['─', '│', '─', '│', '┌', '┐', '┘', '└']

" Echo translation in the cmdline
"nmap <silent> <Leader>t <Plug>Translate
"vmap <silent> <Leader>t <Plug>TranslateV
" Display translation in a window
nmap <silent> <Leader>w <Plug>TranslateW
vmap <silent> <Leader>w <Plug>TranslateWV
" Replace the text with translation
"nmap <silent> <Leader>r <Plug>TranslateR
"vmap <silent> <Leader>r <Plug>TranslateRV
" Translate the text in clipboard
"nmap <silent> <Leader>x <Plug>TranslateX
