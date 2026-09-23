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
