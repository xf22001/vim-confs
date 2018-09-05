if exists("highlight_words")
  finish
endif

let highlight_words=1

hi xiaofei term=bold ctermfg=11 gui=bold guifg=#ffff60

func s:HighlightWord(word)
	"echo 'syn match xiaofei' . ' "\<' . a:word . '\>" containedin=ALL'
	exec 'syn match xiaofei' . ' "\<' . a:word . '\>" containedin=ALL'
endfunc

func s:UnHighlightWord()
	"echo 'syn clear xiaofei'
	exec 'syn clear xiaofei'
endfunc

if !exists(':HighlightWord')
	command -nargs=1 HW :call s:HighlightWord(<args>)
end

if !exists(':UnHighlightWord')
	command -nargs=0 UHW :call s:UnHighlightWord()
end
