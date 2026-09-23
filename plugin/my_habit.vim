""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" My habit
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 可选的项目级 .vim (以当前文件所在目录为基准)
let s:project_vim = expand('%:p:h') . '/.vim'
if filereadable(s:project_vim)
  execute 'source' fnameescape(s:project_vim)
endif

" 各文件类型的缩进
let s:indent = {
      \ 'c':          'sw=8 ts=8 sts=8',
      \ 'cpp':        'sw=8 ts=8 sts=8',
      \ 'java':       'sw=4 ts=4 sts=4',
      \ 'python':     'sw=4 ts=4 sts=4 et',
      \ 'html':       'sw=4 ts=4 sts=4 et',
      \ 'xhtml':      'sw=4 ts=4 sts=4 et',
      \ 'css':        'sw=4 ts=4 sts=4 et',
      \ 'htmldjango': 'sw=4 ts=4 sts=4 et',
      \ 'javascript': 'sw=4 ts=4 sts=4 et',
      \ }
augroup my_habit
  autocmd!
  for s:ft in keys(s:indent)
    execute 'autocmd FileType' s:ft 'setlocal' s:indent[s:ft]
  endfor
augroup END

" 全局选项
set ai si cino+=g0 hls is noswf mouse=a
set fencs=ucs-bom,utf-8,gb18030,gbk,gb2312,big5,euc-jp,euc-kr,latin1,cp936

" 格式化: filetype -> 外部命令 (cmd) 或 vim 函数 (fn)
let s:formatters = {
      \ 'c':          {'cmd': 'astyle -A8Lfpjk3NSt'},
      \ 'cpp':        {'cmd': 'astyle -A8Lfpjk3NSt'},
      \ 'java':       {'cmd': 'astyle -A2Lfpjk3NSt'},
      \ 'python':     {'cmd': 'autopep8 -'},
      \ 'javascript': {'fn':  'JsBeautify'},
      \ 'html':       {'fn':  'HtmlBeautify'},
      \ 'xhtml':      {'fn':  'HtmlBeautify'},
      \ 'css':        {'fn':  'CSSBeautify'},
      \ 'json':       {'fn':  'JsonBeautify'},
      \ }

function! s:FormatCode() abort
  let spec = get(s:formatters, &filetype, {})
  if empty(spec)
    echomsg '不支持' . &filetype . '文件类型-_-'
    return
  endif
  let view = winsaveview()
  if has_key(spec, 'cmd')
    execute '%!' spec.cmd
  else
    call call(spec.fn, [])
  endif
  call winrestview(view)
endfunction

" 键映射
nnoremap <silent> <F2> :TlistToggle<CR>
vnoremap          <F3> y/<C-R>"<CR>
nnoremap <silent> <F4> :let @+ = expand('%:p')<CR>
vnoremap          <F4> y:vimgrep /<C-R>"/g %<CR>
nnoremap <silent> <F5> :edit<CR>
nnoremap <silent> <F6> :echo expand('%:p')<CR>
vnoremap          <F8> y:1,$s:\<<C-R>"\>:<C-R>"<CR>
" 故意不用 <leader>ff: coc 的 <leader>f (<Plug>(coc-format-selected)) 是它的
" 严格前缀, timeoutlen(1s) 内没敲完第二个 f 就会走 coc, 表现为 "有时候不灵"。
nnoremap <silent> <leader>F :call <SID>FormatCode()<CR>

" visual 下 yank/paste 走系统剪贴板
vnoremap y "+y
vnoremap p "+p
