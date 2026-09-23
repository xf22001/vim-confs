if exists('g:loaded_highlightword')
  finish
endif
let g:loaded_highlightword = 1

hi xiaofei term=bold ctermfg=11 gui=bold guifg=#ffff60

" 高亮整词 <word>; \V 让词中的正则符号按字面处理, 再转义 \ 与 " 以免拼进 syn 命令时报错
function! s:HighlightWord(word) abort
  execute 'syn match xiaofei "\V\<' . escape(a:word, '\"') . '\>" containedin=ALL'
endfunction

function! s:UnHighlightWord() abort
  syntax clear xiaofei
endfunction

command! -nargs=1 HW  call s:HighlightWord(<q-args>)
command! -nargs=0 UHW call s:UnHighlightWord()
