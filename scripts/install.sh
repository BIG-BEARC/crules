#!/usr/bin/env bash
# crules 安装器（W2②，v67）——新项目分支的机械部分脚本化（幂等、可 diff、可测）
# 定位：/crules:crules-init 新项目分支中的确定性操作（cp + 导入行 + 版本戳 + 安装报告）；
#       问答引导（技术栈/模式选择）与老项目合并（体检/取舍）仍归命令文档的 AI 流程。
# 用法：bash scripts/install.sh <目标项目根> [选项]
#   --mode lite|full   安装模式（默认 lite——CLAUDE.md 仅 @ 导入 + 覆写节 + 版本戳）
#   --dry-run          只输出安装报告，不写入任何文件
#   --force            覆盖已存在的目标文件（默认跳过并列出——禁静默覆盖）
# 行为：目标已有 CLAUDE.md → 中止（老项目走 /crules:crules-init 合并分支，不自动处理）
set -uo pipefail
CRULES_SRC=$(cd "$(dirname "$0")/.." && pwd)
VER=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["version"])' "$CRULES_SRC/.claude-plugin/plugin.json" 2>/dev/null) || VER="unknown"
STAMP="<!-- crules: v$VER @ $(date +%Y-%m-%d) -->"

usage() { sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }
[ $# -ge 1 ] || usage
TARGET=$1; MODE=lite; DRYRUN=0; FORCE=0
for a in "$@"; do
  case "$a" in
    --mode) :;;  # 值由下一参数处理（下方重扫）
    --mode=*) MODE=${a#--mode=};;
    --dry-run) DRYRUN=1;;
    --force) FORCE=1;;
  esac
done
# --mode 单独传值形态
for ((i=2; i<=$#; i++)); do
  [ "${!i}" = "--mode" ] && { j=$((i+1)); MODE=${!j}; }
done
[ "$MODE" = "lite" ] || [ "$MODE" = "full" ] || { echo "❌ --mode 只支持 lite|full"; exit 2; }

[ -d "$TARGET" ] || { echo "❌ 目标目录不存在: $TARGET"; exit 2; }
WROTE=0; SKIPPED=0

report_row() { echo "  $1  $2"; }

do_write() {  # $1=描述 $2=目标 $3=内容或 "-"（复制源 $4）
  local desc=$1 dst=$2 content=${3:-} src=${4:-}
  if [ -e "$dst" ] && [ "$FORCE" != "1" ]; then
    SKIPPED=$((SKIPPED+1)); report_row "SKIP（已存在）" "$dst"
    return
  fi
  if [ "$DRYRUN" = "1" ]; then
    WROTE=$((WROTE+1)); report_row "DRY  $desc" "$dst"; return
  fi
  if [ -n "$src" ]; then
    mkdir -p "$(dirname "$dst")"; cp -R "$src" "$dst"
  else
    mkdir -p "$(dirname "$dst")"; printf '%s\n' "$content" > "$dst"
  fi
  WROTE=$((WROTE+1)); report_row "WRITE $desc" "$dst"
}

echo "== crules 安装报告（mode=$MODE ver=v$VER$( [ "$DRYRUN" = "1" ] && echo ' · DRY-RUN 未写入' )$( [ "$FORCE" = "1" ] && echo ' · FORCE' )）=="

# 0. 老项目护栏：已有 CLAUDE.md 且**无 crules 版本戳** → 中止（真老项目，合并归 AI 流程）；
#    有戳（本脚本或 init 装的）→ 允许重跑（默认跳过已存在；--force 覆盖重装）
if [ -f "$TARGET/CLAUDE.md" ]; then
  if ! grep -qE '<!-- crules: v[0-9]' "$TARGET/CLAUDE.md"; then  # v[0-9]：vunknown 戳不放行重装（v71 meta-review 🟢#4）
    echo "❌ 目标已有 CLAUDE.md（无 crules 戳）——这是老项目，走 /crules:crules-init 老项目分支（体检→取舍→合并，禁静默覆盖）；本脚本只装新项目"
    exit 1
  fi
  echo "🟢 检出 crules 版本戳——按重装处理（默认跳过已存在，--force 覆盖）"
fi

# 1. 根 CLAUDE.md
if [ "$MODE" = "lite" ]; then
  case "$CRULES_SRC" in
    *".claude/plugins/cache"*)
      echo "⚠️  源在 plugin cache 版本目录——lite 导入行将指向它，plugin update 后有静默版本漂移风险；建议以 crules 仓库稳定路径重跑本脚本，或日后手动改导入行"
      ;;
  esac
  do_write "CLAUDE.md（轻装：导入+覆写+戳）" "$TARGET/CLAUDE.md" "@$CRULES_SRC/CLAUDE.md

## 本项目覆写
（项目特殊约定写这里：提交前缀 / 术语 / 例外授权——覆写优先于导入）

$STAMP"
else
  do_write "CLAUDE.md（完整：头戳+全文）" "$TARGET/CLAUDE.md" "$STAMP

$(cat "$CRULES_SRC/CLAUDE.md")"
fi

# 2. 按需文档（两模式相同；默认不覆盖既有）
do_write "项目附录.md" "$TARGET/项目附录.md" "" "$CRULES_SRC/项目附录.md"
for f in "$CRULES_SRC"/进阶/*.md; do
  do_write "进阶/$(basename "$f")" "$TARGET/进阶/$(basename "$f")" "" "$f"
done
for f in "$CRULES_SRC"/agents/*.md; do
  do_write ".claude/agents/$(basename "$f")" "$TARGET/.claude/agents/$(basename "$f")" "" "$f"
done
for f in "$CRULES_SRC"/memory/*.md; do
  do_write ".claude/memory/$(basename "$f")" "$TARGET/.claude/memory/$(basename "$f")" "" "$f"
done

echo "== 汇总：写入/将写 $WROTE，跳过 $SKIPPED =="
echo "== 下一步（人工/AI）== ① 填附录 3 必填（项目名/技术栈/构建·分析·测试命令）② Flutter 项目另装技术栈包 ③ 巡检可跑：bash $CRULES_SRC/scripts/check-imports.sh $TARGET"
[ "$DRYRUN" = "1" ] && echo "== DRY-RUN：以上未写入，去 --dry-run 重跑生效 =="
exit 0
