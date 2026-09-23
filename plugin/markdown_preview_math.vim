" markdown_preview_math.vim
" ---------------------------------------------------------------------------
" markdown-preview.nvim 自带的 markdown-it-katex 只认 $...$ / $$...$$,
" 而 LLM 一般输出 \(...\) / \[...\], 于是公式会变成字面量。
" 这里在启动时给插件自带的 app/server.js 打一个 normalizeMath 补丁,
" 把两套定界符在送到浏览器之前统一。
"
" 幂等: server.js 里已有 normalizeMath 就直接返回; :PlugUpdate / 重装会
" 覆盖 app/server.js, 下次进入 Vim 时再自动重打。
"
" 补丁脚本与片段随本插件 (vim-confs) 一起分发, 不往 ~/.vim 里塞散落脚本。
" ---------------------------------------------------------------------------

" 注意: 必须在脚本顶层取 <sfile>。函数体内的 <sfile> 会变成"调用者"的脚本
" (实测为 command line..script), 拿不到本插件目录。
let s:plugin_dir = expand('<sfile>:p:h:h')

" 补丁脚本位置: <vim-confs>/patches/markdown-preview.nvim/normalize-math.sh
let s:patch_script = s:plugin_dir . '/patches/markdown-preview.nvim/normalize-math.sh'

function! s:MkdpPluginRoot() abort
  " 优先用 vim-plug 记录的真实安装目录, 否则退回默认路径
  if exists('g:plugs') && has_key(g:plugs, 'markdown-preview.nvim')
    let l:dir = get(g:plugs['markdown-preview.nvim'], 'dir', '')
    if !empty(l:dir)
      return l:dir
    endif
  endif
  return expand('~/.vim/plugged/markdown-preview.nvim')
endfunction

function! s:EnsureKatexPatch() abort
  let l:root   = s:MkdpPluginRoot()
  let l:server = l:root . '/app/server.js'
  " 插件没装 / 脚本缺失就安静返回
  if !filereadable(s:patch_script) || !filereadable(l:server)
    return
  endif
  " 已打过 (server.js 里已有 normalizeMath) 就秒退, 不启动 shell
  if join(readfile(l:server, '', 200), "\n") =~# 'function normalizeMath'
    return
  endif

  let l:out = system('bash ' . shellescape(s:patch_script) . ' ' . shellescape(l:root))
  if v:shell_error != 0
    echohl WarningMsg
    echomsg '[mkdp-katex] 补丁失败: ' . substitute(l:out, "\n", ' ', 'g')
    echohl None
  endif
endfunction

augroup vim_confs_mkdp_katex
  autocmd!
  " VimEnter: 覆盖常规启动 / :PlugUpdate 后重启
  autocmd VimEnter * call <SID>EnsureKatexPatch()
  " FileType: 覆盖"装完插件不重启、直接打开 md"的场景
  autocmd FileType markdown call <SID>EnsureKatexPatch()
augroup END
