#!/usr/bin/env bash
# crules 安装痕迹巡检（W2①，v64）——消费项目侧防「静默断链」与「版本失察」
# 背景：轻装 @ 导入指向的源路径被移动/清理时，下个会话规则**无声消失**（比报错危险——
#       红线看似还在实则全撤）；完整模式复制后无出处记录，升级只能全量体检。
# 用法：bash scripts/check-imports.sh <消费项目根> [crules源根]
#   查 <项目根>/CLAUDE.md：①轻装导入行路径可达（断链 = exit 1）②版本戳 vs 源版本差提示
#   戳格式（crules-init 落盘）：<!-- crules: v0.3.x @ YYYY-MM-DD -->
set -uo pipefail
CRULES_SRC=$(cd "$(dirname "$0")/.." && pwd)

[ $# -ge 1 ] || { echo "用法: bash scripts/check-imports.sh <消费项目根> [crules源根]"; exit 2; }
TARGET=$1; SRC=${2:-$CRULES_SRC}
CM="$TARGET/CLAUDE.md"
[ -f "$CM" ] || { echo "❌ 未找到 $CM（不是 crules 消费项目？）"; exit 2; }

SRC_VER=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["version"])' "$SRC/.claude-plugin/plugin.json" 2>/dev/null) || SRC_VER="?"

IMP=$(grep -oE '^@[^[:space:]]+/CLAUDE\.md' "$CM" | head -1 | sed 's/^@//')
STAMP=$(grep -oE '<!-- crules: v[0-9]+\.[0-9]+\.[0-9]+' "$CM" | head -1 | sed 's/.*v//')

RC=0
if [ -n "$IMP" ]; then
  IMP_EVAL=${IMP/#\~/$HOME}
  if [ -e "$IMP_EVAL" ]; then
    echo "✅ 轻装导入可达：$IMP"
  else
    echo "🔴 断链：导入行指向 $IMP 不存在——源被移动/清理，规则已静默失效；修正导入行或重跑 /crules:crules-init"
    RC=1
  fi
fi

if [ -n "$STAMP" ] && [ "$SRC_VER" != "?" ]; then
  if [ "$STAMP" = "$SRC_VER" ]; then
    echo "✅ 版本戳 v$STAMP 与源一致"
  else
    echo "🟡 版本差：项目装自 v$STAMP，源现为 v$SRC_VER——轻装自动跟随无需动作；完整模式重跑 /crules:crules-init 合并时可聚焦 CHANGELOG v$STAMP→v$SRC_VER 段"
  fi
elif [ -z "$STAMP" ]; then
  echo "🟢 未检出版本戳（v0.3.4 前安装或手装）——重跑 /crules:crules-init 可补戳"
fi
[ -z "$IMP" ] && [ -z "$STAMP" ] && echo "🟢 未检出 crules 安装痕迹"
exit $RC
