#!/usr/bin/env bash
# crules 一致性检查（v13续 B2 机械化底座）——治「纪律写了≠生效」的 L14 类复发
# 检查项：A 悬空相对链接 / B 旧名残留 / C README 清单一致 / D 段落级文字指针 / E 归档引用实存
#         / F 跨包相对链接 / G plugin 版本号 / H deny-list 回归
# 白名单：docs/archive（历史）；docs/CHANGELOG.md 与 docs/评审.md（历史记述密集，多次人工核可免责）；
#         memory/NAVIGATION.md 的 indexes/ 占位链接（L9/L58 已注「启用记忆库时创建」）
# 用法：bash scripts/check-consistency.sh —— 末行 PASS = 通过；FAIL N = N 条问题待处置
# 退出码：0 全绿 / 1 任一问题（CI 与 AI 摘录都依赖此码判红绿，勿改回恒 0）
# 实现注：问题行走 fd 3 收集到临时文件、结尾统一计数——不用 $() 包裹各节（macOS bash 3.2
#         命令替换内嵌 case 的 ")" 解析报语法错，实测）；H 节失败按 1 事件计（pytest 输出走 stdout）
cd "$(dirname "$0")/.." || exit 1
lsmd() { git -c core.quotePath=off ls-files '*.md' | grep -v '^docs/archive/'; }

tmp=$(mktemp) || exit 1
trap 'rm -f "$tmp"' EXIT
exec 3>"$tmp"

echo "== A. 悬空相对链接（排除 archive 与 NAVIGATION 占位）=="
lsmd | while IFS= read -r f; do
  dir=$(dirname "$f")
  grep -oE '\]\([^)#]+\.md' "$f" 2>/dev/null | sed 's/](//' | while IFS= read -r link; do
    case "$f" in memory/NAVIGATION.md) case "$link" in indexes/*) continue;; esac;; esac
    [ -f "$dir/$link" ] || echo "  悬空: $f → $link" >&3
  done
done

echo "== B. 旧名残留（历史记述白名单免责）=="
lsmd | while IFS= read -r f; do
  case "$f" in docs/CHANGELOG.md|docs/评审.md) continue;; esac
  grep -n '通用项目规则模板包' "$f" 2>/dev/null | awk -v f="$f" '{print "  旧名: " f ":" $0}' >&3
done

echo "== C. README 清单一致（目录级：各顶层条目应在根 README 文件清单出现）=="
for entry in 'CLAUDE.md' '项目附录.md' '进阶/' 'agents/' 'commands/' 'memory/'; do
  grep -q "$entry" README.md || echo "  README 漏列: $entry" >&3
done

echo "== D. 段落级文字指针（「见下方「X」段」的 X 须在本文件标题中）=="
lsmd | while IFS= read -r f; do
  grep -oE '(见|详见)下方「[^」]+」' "$f" 2>/dev/null | sed -E 's/.*(见|详见)下方「([^」]+)」/\2/' | while IFS= read -r sec; do
    grep -q "^#.*${sec}" "$f" || echo "  指针悬空: $f → 「${sec}」段" >&3
  done
done

echo "== E. 归档引用实存 =="
git -c core.quotePath=off ls-files '*.md' | while IFS= read -r f; do
  dir=$(dirname "$f")
  grep -oE '\((archive/[^)#]+\.md)\)' "$f" 2>/dev/null | sed 's/[()]//g' | while IFS= read -r link; do
    [ -f "$dir/$link" ] || echo "  归档缺失: $f → $link" >&3
  done
done

echo "== F. 跨包相对链接（规范化后越出包根即报；v18-D 已知豁免清单内静默）=="
# 越包 = 链接从所在文件目录规范化后逃出 crules 包根（如 进阶/ 的 ../../flutter）——分发/消费后必断
# 包内合法 = ../CLAUDE.md（进阶/ 的上一级恰是包根）。豁免：v18-D 暂缓项涉及的 5 文件（重启时清单）
KNOWN_F=':README.md:进阶/审查与复核纪律.md:进阶/工程化流程.md:进阶/Agent编排.md:memory/NAVIGATION.md:'
lsmd | while IFS= read -r f; do
  case "$KNOWN_F" in *":$f:"*) continue;; esac
  dir=$(dirname "$f")
  grep -oE '\]\([^)#]+\.md' "$f" 2>/dev/null | sed 's/](//' | while IFS= read -r link; do
    esc=$(python3 -c "import os; p=os.path.normpath(os.path.join('$dir','$link')); print('ESCAPE' if p.startswith('..') else '')" 2>/dev/null)
    [ -n "$esc" ] && echo "  越包: $f → $link" >&3
  done
done

echo "== G. plugin 版本号一致（双 json 手工同步防漂移）=="
v1=$(python3 -c 'import json;print(json.load(open(".claude-plugin/plugin.json"))["version"])' 2>/dev/null)
v2=$(python3 -c 'import json;print(json.load(open(".claude-plugin/marketplace.json"))["plugins"][0]["version"])' 2>/dev/null)
[ -n "$v1" ] && [ "$v1" = "$v2" ] || echo "  版本不一致: plugin.json=$v1 marketplace.json=$v2" >&3

echo "== H. deny-list 回归测试（对抗样本库，新增绕过先加 fixture 再修名单）=="
hout=$(python3 hooks/test_deny_list.py 2>&1); hrc=$?
[ $hrc -eq 0 ] || { printf '%s\n' "$hout" | sed 's/^/  /'; echo "  deny-list 回归失败（rc=$hrc，详见上方输出）" >&3; }

exec 3>&-
grep . "$tmp"
fails=$(grep -c . "$tmp")
if [ "$fails" -gt 0 ]; then
  echo "== FAIL $fails（以上逐条处置，退出码 1）=="
  exit 1
fi
echo "== PASS（A-H 全绿）=="
