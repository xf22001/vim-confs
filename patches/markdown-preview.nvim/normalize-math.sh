#!/usr/bin/env bash
# normalize-math.sh — markdown-preview.nvim 补丁
#
# 作用: 让预览支持 \(...\) 与 \[...\] 形式的 LaTeX 公式。
# 原因: 它内置的 markdown-it-katex 只认 $...$ 和 $$...$$, 而 LLM 一般
#       输出前一种, 于是公式会原样显示成字面量。这里在内容送到浏览器
#       之前把两套定界符统一, 并保持行数不变(不影响滚动同步)。
#
# 用法:
#   bash normalize-math.sh [插件根目录]
#   省略参数时默认 ~/.vim/plugged/markdown-preview.nvim
#   (fork 用法: bash normalize-math.sh ~/src/markdown-preview.nvim)
#
# 说明: 幂等, 可重复运行。首次打补丁时把原始 server.js 备份为 server.js.orig。
set -euo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${1:-$HOME/.vim/plugged/markdown-preview.nvim}"
SERVER="$PLUGIN_ROOT/app/server.js"
SNIPPET="$SELF_DIR/normalize-math.snippet.js"

if [ ! -f "$SERVER" ]; then
  # 目标插件没装: 不算错误 (本补丁是可选的), 安静跳过, 便于作为 do 钩子使用
  echo "跳过: 找不到 $SERVER (markdown-preview.nvim 未安装?)" >&2
  exit 0
fi
if [ ! -f "$SNIPPET" ]; then
  echo "找不到片段文件 $SNIPPET (需与本脚本同目录)" >&2
  exit 1
fi

if grep -q "function normalizeMath" "$SERVER"; then
  echo "已打过补丁, 无需重复。"
else
  # 备份当前(未打补丁的)server.js, 始终对应当前插件版本
  cp "$SERVER" "$SERVER.orig"

  node - "$SERVER" "$SNIPPET" <<'NODE'
const fs = require('fs')
const [file, snippetFile] = process.argv.slice(2)
let src = fs.readFileSync(file, 'utf8')

const helper = fs.readFileSync(snippetFile, 'utf8')
if (!src.includes('exports.run = function')) {
  console.error('server.js 结构与预期不符, 放弃。')
  process.exit(1)
}
// 注意: 替换串里含 $$ 等, 必须用函数式替换, 否则 String.replace 会做 $ 语法解析
src = src.replace('exports.run = function', () => helper + 'exports.run = function')

const aOld = '        const content = await buffer.getLines()'
const aNew = '        const content = normalizeMath(await buffer.getLines())'
if (!src.includes(aOld)) { console.error('注入点 1 未找到, 放弃。'); process.exit(1) }
src = src.replace(aOld, () => aNew)

const bOld = "      function refreshPage ({ bufnr, data }) {\n        logger.info('refresh page: ', bufnr)"
const bNew = bOld + "\n        if (data && data.content) {\n          data = { ...data, content: normalizeMath(data.content) }\n        }"
if (!src.includes(bOld)) { console.error('注入点 2 未找到, 放弃。'); process.exit(1) }
src = src.replace(bOld, () => bNew)

fs.writeFileSync(file, src)
console.log('补丁已应用:', file)
NODE
fi

if node --check "$SERVER"; then
  echo "语法 OK。"
else
  echo "警告: $SERVER 语法检查未通过, 请检查。" >&2
  exit 1
fi

if grep -q "^Plug 'iamcco/mathjax-support-for-mkdp'" "$HOME/.vimrc" 2>/dev/null; then
  echo "提醒: ~/.vimrc 里仍有 mathjax-support-for-mkdp (旧版插件, 建议注释掉)。" >&2
fi
