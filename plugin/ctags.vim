""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CTAGS settings for vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 把 $CTAGS_DB (逗号分隔) 里的每个库追加到 'tags'
if !empty($CTAGS_DB)
  for s:db in split($CTAGS_DB, ',')
    if !empty(s:db)
      execute 'set tags+=' . escape(s:db, ' \')
    endif
  endfor
endif

" <C-]>: 有可用的 native 跳转数据 → 走 native(:tag; cscopetag 打开时 Vim 内部即 :cstag);
"        没有数据 / native 未命中 → 回退 coc 的 jumpDefinition。
" go buffer 里 vim-go 的 <buffer> <C-]> (:GoDef) 覆盖本全局映射。
"
" 判定只认「实际能用的数据源」, 不看环境变量是否设了:
"   tags   —— tagfiles() 里有可读的库。tagfiles() 已把 ./ 按当前文件目录展开,
"             而 $CTAGS_DB 在上面就并进了 'tags', 所以不用再单独判它;
"   cscope —— Vim 真的 cs add 上了库, 且 cscopetag 打开 (否则 :tag 根本不查 cscope)。
" 顺序: cscope_maps.vim 里是 csto=1, 所以 tags 先查、cscope 后查。

function! s:HasTagFile() abort
  for l:f in tagfiles()
    if !empty(l:f) && filereadable(l:f)
      return 1
    endif
  endfor
  return 0
endfunction

" cscope 的连接状态只能看 :cs show 的实际输出:
" 「$CSCOPE_DB 非空」或「当前目录有 cscope.out」都不代表已经连上
" (cs add 是插件载入那一刻做的, 之后 :cd 走掉就错位了)。
function! s:HasCscopeConn() abort
  if !has('cscope') || !&cscopetag
    return 0
  endif
  let l:show = ''
  try
    redir => l:show
    silent cscope show
    redir END
  catch
    silent! redir END
    return 0
  endtry
  " 无连接时只有一行 "no cscope connections"; 有连接时每行形如 " 0 123 /path/cscope.out"
  return l:show =~# '\n\s*\d'
endfunction

function! s:HasNativeJumpData() abort
  return s:HasTagFile() || s:HasCscopeConn()
endfunction

" a:reason 非空 = native 的真实异常, 直接用它提示; 空 = 压根没有 native 数据可用。
function! s:CocJump(reason) abort
  if exists('*CocActionAsync')
    call CocActionAsync('jumpDefinition')
    return
  endif
  if exists('*CocAction')
    call CocAction('jumpDefinition')
    return
  endif
  echohl ErrorMsg
  if empty(a:reason)
    echomsg 'E426: Tag not found: ' . expand('<cword>')
  else
    echomsg a:reason
  endif
  echohl None
endfunction

function! s:TagOrCocJump() abort
  let l:word = expand('<cword>')
  if empty(l:word)
    return
  endif
  if s:HasNativeJumpData()
    try
      execute 'tag' escape(l:word, ' \|')
      return
    catch /^Vim\%((\a\+)\)\=:E\(257\|426\|433\):/
      " native 未命中: cscopetag 开时是 E257, 关时 E426, 一个 tags 库都读不到是 E433
      call s:CocJump(v:exception)
      return
    endtry
  endif
  call s:CocJump('')
endfunction

nnoremap <silent> <C-]> :call <SID>TagOrCocJump()<CR>
