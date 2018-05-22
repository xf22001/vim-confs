autocmd BufNewFile * exec ":call s:set_header()"
autocmd BufWrite * exec "call s:set_last_modify_time(9)"

" modify the last modified time of a file
function s:set_last_modify_time(lineno)
        let modif_time = strftime("%c")
	let line = getline(a:lineno)
	let line = substitute(line, '修改日期：.*', '修改日期：'.modif_time, "")
	call setline(a:lineno, line)
endfunction

"定义函数set_header，自动插入文件头 
func s:set_header()
	let author = "肖飞"
	if &filetype == 'make' 
		call setline(1, "#") 
		call setline(2, "#") 
		call setline(3, "#================================================================") 
		call setline(4, "#   Copyright (C) ".strftime("%Y年%m月%d日")." ".author." All rights reserved.")
		call setline(5, "#   ") 
		call setline(6, "#   文件名称：".expand("%:t")) 
		call setline(7, "#   创 建 者：".author)
		call setline(8, "#   创建日期：".strftime("%c")) 
		call setline(9, "#   修改日期：".strftime("%c")) 
		call setline(10, "#   描    述：") 
		call setline(11, "#")
		call setline(12, "#================================================================")
	elseif &filetype == 'cpp' || &filetype == "c"
		call setline(1, "") 
		call setline(2, "") 
		call setline(3, "/*================================================================") 
		call setline(4, " *   Copyright (C) ".strftime("%Y年%m月%d日")." ".author." All rights reserved")
		call setline(5, " *   ") 
		call setline(6, " *   文件名称：".expand("%:t")) 
		call setline(7, " *   创 建 者：". author)
		call setline(8, " *   创建日期：".strftime("%c")) 
		call setline(9, " *   修改日期：".strftime("%c")) 
		call setline(10, " *   描    述：") 
		call setline(11, " *")
		call setline(12, " *================================================================*/") 
		if expand("%:e") == 'h' 
			call setline(13, "#ifndef _".toupper(expand("%:t:r"))."_H") 
			call setline(14, "#define _".toupper(expand("%:t:r"))."_H") 
			call setline(15, "#ifdef __cplusplus") 
			call setline(16, "extern \"C\"") 
			call setline(17, "{") 
			call setline(18, "#endif") 
			call setline(19, "") 
			call setline(20, "#ifdef __cplusplus") 
			call setline(21, "}") 
			call setline(22, "#endif") 
			call setline(23, "#endif //_".toupper(expand("%:t:r"))."_H") 
		elseif expand("%:e") == 'c' || expand("%:e") == "cpp" || expand("%:e") == "cc"
			call setline(13,"#include \"".expand("%:t:r").".h\"") 
		endif
	elseif &filetype == 'python'
		call setline(1, "# -*- coding: utf-8 -*-") 
		call setline(2, "#!/usr/bin/env python") 
		call setline(3, "#================================================================") 
		call setline(4, "#   Copyright (C) ".strftime("%Y年%m月%d日")." ".author." All rig") 
		call setline(4, "#   Copyright (C) ".strftime("%Y年%m月%d日")." ".author." All rights reserved")
		call setline(5, "#   ") 
		call setline(6, "#   文件名称：".expand("%:t")) 
		call setline(7, "#   创 建 者：". author)
		call setline(8, "#   创建日期：".strftime("%c")) 
		call setline(9, "#   修改日期：".strftime("%c")) 
		call setline(10, "#   描    述：") 
		call setline(11, "#")
		call setline(12, "#================================================================") 

		call setline(13, "import sys") 
		call setline(14, "") 
		call setline(15, "def main(argv):") 
		call setline(16, "    pass") 
		call setline(17, "") 
		call setline(18, "if '__main__' == __name__:") 
		call setline(19, "    main(sys.argv[1:])") 
	elseif &filetype == 'sh'
		call setline(1, "#!/bin/bash") 
		call setline(2, "") 
		call setline(3, "#================================================================") 
		call setline(4, "#   Copyright (C) ".strftime("%Y年%m月%d日")." ".author." All rig") 
		call setline(4, "#   Copyright (C) ".strftime("%Y年%m月%d日")." ".author." All rights reserved")
		call setline(5, "#   ") 
		call setline(6, "#   文件名称：".expand("%:t")) 
		call setline(7, "#   创 建 者：". author)
		call setline(8, "#   创建日期：".strftime("%c")) 
		call setline(9, "#   修改日期：".strftime("%c")) 
		call setline(10, "#   描    述：") 
		call setline(11, "#")
		call setline(12, "#================================================================") 

		call setline(13, "function main() {") 
		call setline(14, "	:") 
		call setline(15, "}") 
		call setline(16, "") 
		call setline(17, "main $@") 
	elseif &filetype == 'java'
		call setline(1, "") 
		call setline(2, "") 
		call setline(3, "/*================================================================") 
		call setline(4, " *   Copyright (C) ".strftime("%Y年%m月%d日")." ".author." All rights reserved")
		call setline(5, " *   ") 
		call setline(6, " *   文件名称：".expand("%:t")) 
		call setline(7, " *   创 建 者：". author)
		call setline(8, " *   创建日期：".strftime("%c")) 
		call setline(9, " *   修改日期：".strftime("%c")) 
		call setline(10, " *   描    述：") 
		call setline(11, " *")
		call setline(12, " *================================================================*/") 
		call setline(13, "public class ".expand("%:t:r")." {")
		call setline(14, "")
		call setline(15, "	/**")
		call setline(16, "	*")
		call setline(17, "	* @param args")
		call setline(18, "	*/")
		call setline(19, "	*/")
		call setline(20, "	public static void main(String[] args) {")
		call setline(21, "		// TODO Auto-generated method stub")
		call setline(22, "		System.out.println(\"Hello World\");")
		call setline(23, "	}")
		call setline(24, "}")
	endif
endfunc
