#!/usr/bin/env bash
# keep-page-url.sh — markdown-preview.nvim 补丁
#
# 作用: 让预览页刷新后不再 404。
# 原因: 插件打开的是 /page/<bufnr>, 但页面挂载后会执行
#       window.history.replaceState(null, '', '/<bufnr>')
#       把地址栏改写成 /<bufnr>。socket 已经连上, 所以内容照常显示、
#       滚动/光标仍然同步, 但一刷新浏览器就去请求 /<bufnr>——
#       服务端只有 /page/:number 这一条路由, 于是落到 404。
#       这里让 replaceState 保留 /page/ 前缀, 并把 bufnr 的解析从
#       「取第 3 段」改成「取最后一段」, 这样 /page/3 与 /3 都能用。
#
# 用法:
#   bash keep-page-url.sh [插件根目录]
#   省略参数时默认 ~/.vim/plugged/markdown-preview.nvim
#
# 说明: 幂等, 可重复运行。
#       需要同时改两处: app/pages/index.jsx (源码) 和
#       app/out/_next/static/<buildId>/pages/index.js (实际运行的预构建产物)。
#       预构建产物不备份: 它是生成物、体积大(约 2MB 单行压缩), 且插件更新后
#       buildId 目录会重建, 备份没有意义。
set -euo pipefail

PLUGIN_ROOT="${1:-$HOME/.vim/plugged/markdown-preview.nvim}"
SRC="$PLUGIN_ROOT/app/pages/index.jsx"

if [ ! -d "$PLUGIN_ROOT/app" ]; then
  # 目标插件没装: 不算错误, 安静跳过, 便于作为 do 钩子使用
  echo "跳过: 找不到 $PLUGIN_ROOT/app (markdown-preview.nvim 未安装?)" >&2
  exit 0
fi

# 二进制发行版 (app/bin/markdown-preview-*) 走的是打包好的 server, app/ 改了也不生效
if compgen -G "$PLUGIN_ROOT/app/bin/markdown-preview-*" >/dev/null; then
  echo "警告: 存在 app/bin/markdown-preview-*, 预览走的是该二进制, 本补丁不会生效。" >&2
fi

# 待改文件列表: 源码 + 全部 buildId 下的预构建产物
targets=()
[ -f "$SRC" ] && targets+=("$SRC")
for f in "$PLUGIN_ROOT"/app/out/_next/static/*/pages/index.js; do
  [ -f "$f" ] && targets+=("$f")
done

if [ "${#targets[@]}" -eq 0 ]; then
  echo "跳过: 没找到可改的文件 (既无 app/pages/index.jsx 也无 app/out/_next/static/*/pages/index.js)" >&2
  exit 0
fi

node - "${targets[@]}" <<'NODE'
const fs = require('fs')

// 每个文件最多两处替换。正则同时覆盖源码写法 (`` `/${bufnr}` ``)
// 与压缩产物写法 ("/".concat(e)), 以兼容不同版本。
// 注意: 替换串含 $1, 必须走函数式替换, 否则 String.replace 会解析 $ 语法。
const rules = [
  {
    name: 'replaceState 保留 /page/ 前缀',
    done: /history\.replaceState\(\s*null\s*,\s*[`'"][^)]*\/page\//,
    find: /history\.replaceState\(\s*null\s*,\s*(['"])\1\s*,\s*(['"`])\/\$\{bufnr\}(['"`])\)|history\.replaceState\(\s*null\s*,\s*(['"])\4\s*,\s*(['"])\/\5\.concat\((\w+)\)\)/,
    replace: (m, q1, q2, q3, q4, q5, arg) => arg
      ? `history.replaceState(null,${q4}${q4},${q5}/page/${q5}.concat(${arg}))`
      : `history.replaceState(null, ${q1}${q1}, ${q2}/page/\${bufnr}${q3})`,
  },
  {
    name: 'bufnr 取路径最后一段',
    done: /pathname\.split\((['"])\/\1\)\.pop\(\)/,
    find: /pathname\.split\((['"])\/\1\)(?:\.pop\(\)|\[2\])/,
    replace: (m, q) => `pathname.split(${q}/${q}).pop()`,
  },
]

let changed = 0
let already = 0
let failed = 0

for (const file of process.argv.slice(2)) {
  let src = fs.readFileSync(file, 'utf8')
  const before = src

  for (const rule of rules) {
    if (rule.done.test(src)) {
      already++
      continue
    }
    if (!rule.find.test(src)) {
      console.error(`!! ${file}: 未找到注入点「${rule.name}」, 该文件结构与预期不符。`)
      failed++
      continue
    }
    src = src.replace(rule.find, rule.replace)
  }

  if (src !== before) {
    fs.writeFileSync(file, src)
    console.log('补丁已应用:', file)
    changed++
  }
}

console.log(`结果: 修改 ${changed} 个文件, ${already} 处已是补丁后状态, ${failed} 处失败。`)
process.exit(failed > 0 ? 1 : 0)
NODE

# 预构建产物是普通 JS, 可以语法检查; index.jsx 是 JSX, node 检不了, 跳过。
for f in "${targets[@]}"; do
  case "$f" in
    *.jsx) ;;
    *) node --check "$f" || { echo "警告: $f 语法检查未通过。" >&2; exit 1; } ;;
  esac
done

echo "语法 OK。"
