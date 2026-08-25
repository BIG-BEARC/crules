#!/usr/bin/env bash
# 脚本自测（W2⑤ 检查器自测·轻量版，v68）——三个「应报错」断言：检查器验别人，也得能证自己会红
# 完整版（check-consistency 对 fixture 坏样本目录跑 A/B/F 检查）与 J 查同轮（W1），此处先锁行为下限
set -uo pipefail
CRULES_SRC=$(cd "$(dirname "$0")/.." && pwd)
PASS=0; FAIL=0
t() {  # $1=名 $2=期望RC $3=命令
  eval "$3" >/dev/null 2>&1; rc=$?
  if [ "$rc" = "$2" ]; then PASS=$((PASS+1)); echo "PASS  $1"
  else FAIL=$((FAIL+1)); echo "FAIL  $1（rc=$rc 期望 $2）"; fi
}
D=/tmp/crules-selftest
mkdir -p "$D/oldproj" "$D/broken" "$D/fix-good" "$D/fix-bad" "$D/fix-twin"
printf '# 老项目规则\n' > "$D/oldproj/CLAUDE.md"                       # 无戳 → install 应中止
printf '@/tmp/crules-selftest/nonexist/CLAUDE.md\n' > "$D/broken/CLAUDE.md"  # 断链 → 巡检应非零

t "install.sh 老项目（无戳）应中止" 1 "bash $CRULES_SRC/scripts/install.sh $D/oldproj"
t "check-imports.sh 断链应非零"     1 "bash $CRULES_SRC/scripts/check-imports.sh $D/broken"
t "release.sh 非法版本号应报错"     1 "bash $CRULES_SRC/scripts/release.sh abc"

# fixture 模式（v69/W1 完整版：check-consistency 对任意目录跑 A-F/J/K，G/H/I 跳过）
printf '# 干净文档\n\n正文无链接无特征串。\n' > "$D/fix-good/doc.md"
t "consistency fixture 干净目录应 PASS" 0 "CONSISTENCY_ROOT=$D/fix-good bash $CRULES_SRC/scripts/check-consistency.sh"
printf '# 坏文档\n\n[死链](nope.md)；提及 通用项目规则模板包 与 不进 git\n' > "$D/fix-bad/doc.md"
t "consistency fixture 悬链+旧名+政策外应红" 1 "CONSISTENCY_ROOT=$D/fix-bad bash $CRULES_SRC/scripts/check-consistency.sh"
printf '# 孪生漂移\n\n<!-- twin:x -->\n| a |\n|---|\n| 1 |\n' > "$D/fix-twin/one.md"
printf '# 另一处\n\n<!-- twin:x -->\n| a |\n|---|\n| 1 |\n| 2 |\n' > "$D/fix-twin/two.md"
t "consistency fixture 孪生行数漂移应红" 1 "CONSISTENCY_ROOT=$D/fix-twin bash $CRULES_SRC/scripts/check-consistency.sh"

rm -rf /tmp/crules-selftest
echo "== 脚本自测：PASS=$PASS FAIL=$FAIL =="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
