" Go 文件里用 vim-go 的导航, 覆盖掉 coc 的全局 gd/gy/gi/gr。
" gd 已由 vim-go 自己 buffer-local 映射, 这里只补 gy/gi/gr。
" 必须带 <buffer>: 否则打开任一 .go 后这些键会泄漏成全局映射,
" 把非 go 文件里内置的 gd/gr 一并覆盖掉。
nnoremap <silent> <buffer> gy <Plug>(go-def-type)
nnoremap <silent> <buffer> gi <Plug>(go-implements)
nnoremap <silent> <buffer> gr <Plug>(go-referrers)
