""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Highlight word -- 同时高亮多组词/片段, 且不干扰搜索和寄存器
"
" 用法:
"   \hw        可视模式下高亮选中内容 (v / V / <C-v> 及跨行选择都行)
"   :HW        高亮光标下的词
"   :HW {内容} 高亮指定内容
"   :UHW       清除当前窗口由本脚本加的全部高亮
"
" 说明:
"   - 三种入口可反复调用叠加, 不限组数; 颜色为红 (高亮组 xiaofei)
"   - 纯单词按整词匹配 (\V\<word\>), 含空格或符号的按字面匹配; 两端空白自动去掉
"   - 不碰 @/  -> n / N 与上次搜索不受影响
"   - 不碰任何寄存器 -> p 粘出的仍是上次的内容
"   - 不移动光标 (比 * 温和)
"   - matchadd 是窗口级: 分屏的新窗口没有高亮; 同窗口 :e 换文件高亮仍在;
"     :UHW 只清当前窗口, 换窗口后各自的高亮互不影响
"
" 何时不必用: 只需高亮单个词用 * / # 即可 (见 plugin/my_habit.vim 的 <F3>)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists('g:loaded_highlightword')
  finish
endif
let g:loaded_highlightword = 1

hi xiaofei term=bold cterm=bold ctermfg=9 gui=bold guifg=#ff5555

" 单个词用整词匹配; 含空白或符号的片段按字面处理
function! s:Pattern(text) abort
  return '\V' . (a:text =~# '^\k\+$' ? '\<' . escape(a:text, '\') . '\>' : escape(a:text, '\'))
endfunction

" 逐行添加高亮 (可视选区可能跨行); 去掉两端空白, 免得选中词后多带个空格就失配
" matchadd 是窗口级的, id 也按窗口记 (w:hw_ids), 这样在哪个窗口加就在哪个窗口清
function! s:Add(text) abort
  if !exists('w:hw_ids')
    let w:hw_ids = []
  endif
  for line in split(a:text, "\n")
    let line = trim(line)
    if !empty(line)
      call add(w:hw_ids, matchadd('xiaofei', s:Pattern(line)))
    endif
  endfor
endfunction

" :HW [词]  省略参数时取光标下的词; 可重复调用累加多组
command! -nargs=? HW call s:Add(empty(<q-args>) ? expand('<cword>') : <q-args>)

" 取自选区文本。不碰任何寄存器: 用 '< '> 两端位置自己算,
" 否则 "zy 会把 @"/@"z 一起改写, 之后按 p 粘出来的是刚选中的词。
function! s:Selection() abort
  let [l1, c1] = [line("'<"), col("'<")]
  let [l2, c2] = [line("'>"), col("'>")]
  if visualmode() ==# 'V'                    " 行选择
    return join(getline(l1, l2), "\n")
  elseif visualmode() ==# "\<C-V>"           " 块选择
    return join(map(range(l1, l2),
          \ 'strpart(getline(v:val), c1 - 1, c2 - c1 + 1)'), "\n")
  elseif l1 == l2                            " 单行字符选择
    return strpart(getline(l1), c1 - 1, c2 - c1 + 1)
  else                                       " 跨行字符选择
    return join([strpart(getline(l1), c1 - 1)]
          \ + getline(l1 + 1, l2 - 1)
          \ + [strpart(getline(l2), 0, c2)], "\n")
  endif
endfunction

" 可视模式下 <leader>hw: 高亮选中内容 (不动搜索状态, 也不动寄存器)
function! s:AddSelection() abort
  call s:Add(s:Selection())
endfunction

xnoremap <silent> <leader>hw :<C-U>call <SID>AddSelection()<CR>

" :UHW  清除本窗口由本脚本加过的所有高亮
function! s:Clear() abort
  for id in get(w:, 'hw_ids', [])
    silent! call matchdelete(id)
  endfor
  let w:hw_ids = []
endfunction
command! -nargs=0 UHW call s:Clear()
