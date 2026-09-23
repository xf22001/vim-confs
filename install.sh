#!/usr/bin/env bash
# install.sh — vim-confs 的安装/更新入口
#
# vim-plug 的 do 钩子会以「本仓库根目录为 cwd」调用它, 例如:
#   Plug 'xf22001/vim-confs', { 'do': 'bash install.sh' }
# 所以以后 :PlugInstall / :PlugUpdate 要顺带做的事, 都往这里加, .vimrc 不用动。
#
# 约定: patches/<插件名>/ 下每个「不以 _ 开头」的 *.sh 都会被自动执行 (按名排序);
#       辅助文件请用 _ 前缀或非 .sh 后缀 (例如 *.snippet.js), 以免被当成入口。
#       每个补丁脚本自行保证幂等 (内容已打补丁就跳过)。
#
# 手动运行: bash install.sh
set -uo pipefail

SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ran=0
failed=0

run_patch() {
  local script="$1"
  local rel="${script#"$SELF"/}"
  echo "── $rel"
  if bash "$script"; then
    ran=$((ran + 1))
  else
    echo "!! 失败: $rel" >&2
    failed=$((failed + 1))
  fi
}

shopt -s nullglob
for script in "$SELF"/patches/*/*.sh; do
  case "$(basename "$script")" in
    _*) continue ;;
  esac
  run_patch "$script"
done

echo
if [ "$failed" -eq 0 ]; then
  echo "vim-confs: 完成 ($ran 项)。"
else
  echo "vim-confs: $ran 项成功, $failed 项失败。" >&2
fi
exit $(( failed > 0 ))
