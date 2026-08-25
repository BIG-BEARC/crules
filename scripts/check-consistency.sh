#!/usr/bin/env bash
# crules 一致性检查（v13续 B2 机械化底座）——治「纪律写了≠生效」的 L14 类复发
# 检查项：A 悬空相对链接 / B 旧名残留 / C README 清单一致 / D 段落级文字指针 / E 归档引用实存
#         / F 跨包相对链接 / G plugin 版本号 / H deny-list 回归 / I 元账本（A/B2 机械化）
#         / J 孪生表断言（W1：twin 锚点成对+行数一致）/ K 政策声明归口（旧政策特征串只许在政策表）
# 白名单：docs/archive（历史）；docs/CHANGELOG.md 与 docs/评审.md（历史记述密集，多次人工核可免责）；
#         memory/NAVIGATION.md 的 indexes/ 占位链接（L9/L58 已注「启用记忆库时创建」）
# 用法：bash scripts/check-consistency.sh —— 末行 PASS = 通过；FAIL N = N 条问题待处置
#       CONSISTENCY_ROOT=<目录> bash scripts/check-consistency.sh —— fixture 模式：对任意目录跑
#         A-F/J/K（find 代 git ls-files），G/H/I 跳过（版本/回归/元账本与被检目录无关）——供 test-self.sh
# 退出码：0 全绿 / 1 任一问题（CI 与 AI 摘录都依赖此码判红绿，勿改回恒 0）
# 实现注：问题行走 fd 3 收集到临时文件、结尾统一计数——不用 $() 包裹各节（macOS bash 3.2
#         命令替换内嵌 case 的 ")" 解析报语法错，实测）；H 节失败按 1 事件计（pytest 输出走 stdout）
cd "$(dirname "$0")/.." || exit 1
if [ -n "${CONSISTENCY_ROOT:-}" ]; then
  cd "$CONSISTENCY_ROOT" || exit 1
  lsmd() { find . -name '*.md' -not -path './docs/archive/*' | sed 's|^\./||'; }
  lsmda() { find . -name '*.md' | sed 's|^\./||'; }   # 含 archive（E 查口径）
else
  lsmd() { git -c core.quotePath=off ls-files '*.md' | grep -v '^docs/archive/'; }
  lsmda() { git -c core.quotePath=off ls-files '*.md'; }
fi

tmp=$(mktemp) || exit 1
trap 'rm -f "$tmp"' EXIT
exec 3>"$tmp"

echo "== A. 悬空相对链接（排除 archive 与 NAVIGATION 占位）=="
# 包外链接（如 ../flutter）不在本节验存在性——兄弟目录不随仓库分发，CI 自包含 checkout 必假阳性（v48 实证：
# 本机因 ../flutter 存在而绿、CI 因无兄弟目录报 4 悬空 exit 1）；越包判定归 F 查管辖
lsmd | while IFS= read -r f; do
  dir=$(dirname "$f")
  grep -oE '\]\([^)#]+\.md' "$f" 2>/dev/null | sed 's/](//' | while IFS= read -r link; do
    case "$f" in memory/NAVIGATION.md) case "$link" in indexes/*) continue;; esac;; esac
    esc=$(python3 -c "import os;print('ESCAPE' if os.path.normpath(os.path.join('$dir','$link')).startswith('..') else '')" 2>/dev/null)
    if [ -n "$esc" ]; then continue; fi
    [ -f "$dir/$link" ] || echo "  悬空: $f → $link" >&3
  done
done

echo "== B. 旧名残留（历史记述白名单免责）=="
lsmd | while IFS= read -r f; do
  case "$f" in docs/CHANGELOG.md|docs/评审.md) continue;; esac
  grep -n '通用项目规则模板包' "$f" 2>/dev/null | awk -v f="$f" '{print "  旧名: " f ":" $0}' >&3
done

echo "== C. README 清单一致（目录级：各顶层条目应在根 README 文件清单出现）=="
if [ -z "${CONSISTENCY_ROOT:-}" ]; then
for entry in 'CLAUDE.md' '项目附录.md' '进阶/' 'agents/' 'commands/' 'memory/'; do
  grep -q "$entry" README.md || echo "  README 漏列: $entry" >&3
done
fi

echo "== D. 段落级文字指针（「见下方「X」段」的 X 须在本文件标题中）=="
lsmd | while IFS= read -r f; do
  grep -oE '(见|详见)下方「[^」]+」' "$f" 2>/dev/null | sed -E 's/.*(见|详见)下方「([^」]+)」/\2/' | while IFS= read -r sec; do
    grep -q "^#.*${sec}" "$f" || echo "  指针悬空: $f → 「${sec}」段" >&3
  done
done

echo "== E. 归档引用实存 =="
lsmda | while IFS= read -r f; do
  dir=$(dirname "$f")
  grep -oE '\((archive/[^)#]+\.md)\)' "$f" 2>/dev/null | sed 's/[()]//g' | while IFS= read -r link; do
    [ -f "$dir/$link" ] || echo "  归档缺失: $f → $link" >&3
  done
done

echo "== F. 跨包相对链接（规范化后越出包根即报；v18-D 已知豁免清单内静默）=="
# 越包 = 链接从所在文件目录规范化后逃出 crules 包根（如 README 的 ../flutter）——分发/消费后必断
# v56：模板正文 5 处越包链接已 prose 化（部署拓扑断链收口，v18-D/N5 关闭），豁免仅余 README（不复制、原位合法）
KNOWN_F=':README.md:'
lsmd | while IFS= read -r f; do
  case "$KNOWN_F" in *":$f:"*) continue;; esac
  dir=$(dirname "$f")
  grep -oE '\]\([^)#]+\.md' "$f" 2>/dev/null | sed 's/](//' | while IFS= read -r link; do
    esc=$(python3 -c "import os; p=os.path.normpath(os.path.join('$dir','$link')); print('ESCAPE' if p.startswith('..') else '')" 2>/dev/null)
    [ -n "$esc" ] && echo "  越包: $f → $link" >&3
  done
done

echo "== G. plugin 版本号一致（双 json 手工同步防漂移）=="
if [ -z "${CONSISTENCY_ROOT:-}" ]; then
v1=$(python3 -c 'import json;print(json.load(open(".claude-plugin/plugin.json"))["version"])' 2>/dev/null)
v2=$(python3 -c 'import json;print(json.load(open(".claude-plugin/marketplace.json"))["plugins"][0]["version"])' 2>/dev/null)
[ -n "$v1" ] && [ "$v1" = "$v2" ] || echo "  版本不一致: plugin.json=$v1 marketplace.json=$v2" >&3
fi

echo "== H. deny-list 回归测试（对抗样本库，新增绕过先加 fixture 再修名单）=="
if [ -z "${CONSISTENCY_ROOT:-}" ]; then
hout=$(python3 hooks/test_deny_list.py 2>&1); hrc=$?
[ $hrc -eq 0 ] || { printf '%s\n' "$hout" | sed 's/^/  /'; echo "  deny-list 回归失败（rc=$hrc，详见上方输出）" >&3; }
fi

echo "== I. 元账本（A/B2 机械化，v55：已办残留不滞留 / 已关闭表不膨胀）=="
if [ -z "${CONSISTENCY_ROOT:-}" ]; then
# I1 待办池表格行级别列为 ✅ = 已办未删行（应移评审.md 已关闭表；只认级别列精确 ✅，说明文字提及不算）
i1=$(grep -E '^\|[^|]*\| ✅ \|' docs/待办.md 2>/dev/null || true)
[ -n "$i1" ] && printf '%s\n' "$i1" | sed 's/^/  待办池已办残留: /' >&3
# I2 已关闭表 >8 行 = 触发 L11 归档
i2=$(awk '/^## 已关闭/{f=1;next} /^## /{f=0} f&&/^\| \*\*/{n++} END{if(n>8)print "已关闭表 " n " 行 >8，按 L11 批量归档 archive"}' docs/评审.md)
[ -n "$i2" ] && echo "  $i2" >&3
fi

echo "== J. 孪生表断言（W1/v69：twin 锚点成对 + 数据行数一致）=="
# 孪生双份曾靠注释人肉同步、已漂移过一次（git 政策 v61）；现锚点机器看守——行数不等即漂移
# 范围限分发 md：docs/ 记账文档常含锚点字样的「文档性引用」（CHANGELOG 记本轮改动等），非真锚点
lsmd | grep -v '^docs/' | while IFS= read -r f; do
  grep -n '<!-- twin:' "$f" 2>/dev/null | sed -E 's/^([0-9]+):<!-- *twin: *([A-Za-z0-9_-]+) *-->.*/\2 \1/' | while IFS=' ' read -r name ln; do
    n=$(awk -v s="$((ln+1))" 'NR>=s && /^\|/{c++; next} NR>s && c>0{exit} END{print c+0}' "$f")
    echo "$name $n $f:$ln"
  done
done | sort > "$tmp.j" 2>/dev/null || :
if [ -s "$tmp.j" ]; then
  awk '{cnt[$1]++} END{for(n in cnt) if(cnt[n]<2) print "  孪生缺伴: " n "（仅 1 处，孪生须 ≥2）"}' "$tmp.j" >&3
  awk '{if(!($1 in lo)){lo[$1]=$2; hi[$1]=$2} else if($2+0>hi[$1]+0)hi[$1]=$2} END{for(n in lo) if(lo[n]!=hi[n]) printf "  孪生行数漂移: %s（%s vs %s 行）\n", n, lo[n], hi[n]}' "$tmp.j" >&3
elif [ -z "${CONSISTENCY_ROOT:-}" ]; then
  echo "  孪生表：未检出任何 twin 锚点（预期 ≥2 对——锚点被删即报）" >&3
fi

echo "== K. 政策声明归口（W1/v69：旧政策特征串只许出现在 MAINTENANCE 政策表）=="
# 特征串 = 旧政策四特征（不进 git / 整体 gitignore / 纯本地 / AI 私有——v69 修的漂移恰是此表述，v71 补看守）；正向新政策表述（制度资产进 git）合法
for f in CLAUDE.md README.md 项目附录.md agents/*.md commands/*.md memory/*.md 进阶/*.md; do
  [ -f "$f" ] || continue
  case "$f" in memory/MAINTENANCE.md) continue;; esac   # 政策表本体
  grep -n '不进 git\|整体 gitignore\|纯本地\|AI 私有' "$f" 2>/dev/null | cut -d: -f1 | while IFS= read -r no; do
    echo "  政策外声明: $f:$no（git 纳管政策单一权威在 memory/MAINTENANCE.md「git 分层」）"
  done
done >&3

exec 3>&-
grep . "$tmp"
fails=$(grep -c . "$tmp")
rm -f "$tmp.j"
if [ "$fails" -gt 0 ]; then
  echo "== FAIL $fails（以上逐条处置，退出码 1）=="
  exit 1
fi
echo "== PASS（A-K 全绿）=="
