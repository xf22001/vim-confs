" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes
Plug 'junegunn/vim-plug'
Plug 'vim-scripts/OmniCppComplete'
Plug 'vim-scripts/winmanager'
Plug 'vim-scripts/taglist.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'maksimr/vim-jsbeautify'
Plug 'vim-scripts/highlight.vim'

" If you have nodejs and yarn
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

" go 主要插件
Plug 'fatih/vim-go', { 'tag': '*' }

" 安装/更新本插件时跑它的统一入口 (do 钩子 cwd = 插件目录), 入口里自动跑 patches/ 下所有补丁。
" 日常启动时由 plugin/markdown_preview_math.vim 兜底重打。
Plug 'xf22001/vim-confs', { 'do': 'bash install.sh' }

" Initialize plugin system
call plug#end()

let g:coc_disable_startup_warning = 1
