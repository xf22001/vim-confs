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

" <C-]>: CTAGS_DB / CSCOPE_DB 有配置(或本地有可读 tags/cscope.out)
"        → 生效 native 跳转(:tag, 且尊重 cscopetag);
"        两边都没数据 → 用 coc。native 未命中时再回退 coc。
" go buffer 里 vim-go 的 <buffer> <C-]> (:GoDef) 覆盖本全局映射。
function! s:HasNativeJumpData() abort
  if !empty($CTAGS_DB) || !empty($CSCOPE_DB)
    return 1
  endif
  if filereadable('cscope.out')
    return 1
  endif
  for l:p in split(&tags, ',')
    if !empty(l:p) && filereadable(l:p)
      return 1
    endif
  endfor
  return 0
endfunction

function! s:CocJump() abort
  if exists('*CocActionAsync')
    call CocActionAsync('jumpDefinition')
  elseif exists('*CocAction')
    call CocAction('jumpDefinition')
  else
    echohl ErrorMsg
    echomsg 'E426: Tag not found: ' . expand('<cword>')
    echohl None
  endif
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
    catch /^Vim\%((\a\+)\)\=:E426/
    catch /^Vim\%((\a\+)\)\=:E433/
    catch /^Vim\%((\a\+)\)\=:E425/
    catch /^Vim\%((\a\+)\)\=:E257/
      " native 未命中(cscopetag 下常见 E257) → 回退 coc
    endtry
  endif
  call s:CocJump()
endfunction

nnoremap <silent> <C-]> :call <SID>TagOrCocJump()<CR>
