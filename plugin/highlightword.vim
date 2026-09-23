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
"   - 纯 ASCII 单词按整词匹配 (\V\<word\>); 含空白/符号/中文的按字面匹配
"     (中文没有词边界, 套 \<\> 反而在 "中文测试" 里匹配不上); 两端空白自动去掉
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

" 纯 ASCII 单词用整词匹配 (\<word\>); 其余 (含空白/符号/中文) 按字面匹配。
" 中文没有词边界, 若也套 \<\> 则 :HW 中文 在 "中文测试" 里反而不命中。
function! s:Pattern(text) abort
  if a:text =~# '^\k\+$' && a:text =~# '^[\x00-\x7f]\+$'
    return '\V\<' . escape(a:text, '\') . '\>'
  endif
  return '\V' . escape(a:text, '\')
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

" 取 lnum 行第 c1 字节 到 第 c2 字节所在字符末尾 的文本 (c2<=0 表示到行尾)。
" col("'>") 指向最后一个字符的「首」字节; 块选/中文时它还可能落在多字节字符中间
" (如 <C-v>l 在双宽字 '中' 上只跨显示列 1-2, 列值就是 2), 所以两端都先吸附到
" 字符边界再按整字符取长度, 否则 '中文' 会被截成 '中' + 文的首字节 (乱码)。
function! s:Seg(lnum, c1, c2) abort
  let line = getline(a:lnum)
  let [b, e] = [a:c1, a:c2 > 0 ? a:c2 : strlen(line) + 1]
  while b > 1 && char2nr(strpart(line, b - 1, 1)) >= 0x80
        \ && char2nr(strpart(line, b - 1, 1)) <= 0xbf
    let b -= 1
  endwhile
  while e > 1 && e <= strlen(line) && char2nr(strpart(line, e - 1, 1)) >= 0x80
        \ && char2nr(strpart(line, e - 1, 1)) <= 0xbf
    let e -= 1
  endwhile
  if e <= strlen(line)
    let e += strlen(matchstr(strpart(line, e - 1), '^.'))
  endif
  return strpart(line, b - 1, e - b)
endfunction

" 取自选区文本。不碰任何寄存器: 用 '< '> 两端位置自己算,
" 否则 "zy 会把 @"/@"z 一起改写, 之后按 p 粘出来的是刚选中的词。
function! s:Selection() abort
  let [l1, c1] = [line("'<"), col("'<")]
  let [l2, c2] = [line("'>"), col("'>")]
  if visualmode() ==# 'V'                    " 行选择
    return join(getline(l1, l2), "\n")
  elseif visualmode() ==# "\<C-V>"           " 块选择
    let lines = []
    for lnum in range(l1, l2)
      call add(lines, s:Seg(lnum, c1, c2))
    endfor
    return join(lines, "\n")
  elseif l1 == l2                            " 单行字符选择
    return s:Seg(l1, c1, c2)
  else                                       " 跨行字符选择
    return join([s:Seg(l1, c1, 0)]
          \ + getline(l1 + 1, l2 - 1)
          \ + [s:Seg(l2, 1, c2)], "\n")
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
