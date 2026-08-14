#!/usr/bin/env bash
# crules 一致性检查（v13续 B2 机械化底座）——治「纪律写了≠生效」的 L14 类复发
# 检查项：A 悬空相对链接 / B 旧名残留 / C README 清单一致 / D 段落级文字指针 / E 归档引用实存
# 白名单：docs/archive（历史）；docs/CHANGELOG.md 与 docs/评审.md（历史记述密集，多次人工核可免责）；
#         memory/NAVIGATION.md 的 indexes/ 占位链接（L9/L58 已注「启用记忆库时创建」）
# 用法：bash scripts/check-consistency.sh —— 各节无输出 = 通过；有输出 = 逐条处置
cd "$(dirname "$0")/.." || exit 1
lsmd() { git -c core.quotePath=off ls-files '*.md' | grep -v '^docs/archive/'; }

echo "== A. 悬空相对链接（排除 archive 与 NAVIGATION 占位）=="
lsmd | while IFS= read -r f; do
  dir=$(dirname "$f")
  grep -oE '\]\([^)#]+\.md' "$f" 2>/dev/null | sed 's/](//' | while IFS= read -r link; do
    case "$f" in memory/NAVIGATION.md) case "$link" in indexes/*) continue;; esac;; esac
    [ -f "$dir/$link" ] || echo "  悬空: $f → $link"
  done
done

echo "== B. 旧名残留（历史记述白名单免责）=="
lsmd | while IFS= read -r f; do
  case "$f" in docs/CHANGELOG.md|docs/评审.md) continue;; esac
  grep -n '通用项目规则模板包' "$f" 2>/dev/null | awk -v f="$f" '{print "  旧名: " f ":" $0}'
done

echo "== C. README 清单一致（目录级：各顶层条目应在根 README 文件清单出现）=="
for entry in 'CLAUDE.md' '项目附录.md' '进阶/' 'agents/' 'commands/' 'memory/'; do
  grep -q "$entry" README.md || echo "  README 漏列: $entry"
done

echo "== D. 段落级文字指针（「见下方「X」段」的 X 须在本文件标题中）=="
lsmd | while IFS= read -r f; do
  grep -oE '(见|详见)下方「[^」]+」' "$f" 2>/dev/null | sed -E 's/.*(见|详见)下方「([^」]+)」/\2/' | while IFS= read -r sec; do
    grep -q "^#.*${sec}" "$f" || echo "  指针悬空: $f → 「${sec}」段"
  done
done

echo "== E. 归档引用实存 =="
git -c core.quotePath=off ls-files '*.md' | while IFS= read -r f; do
  dir=$(dirname "$f")
  grep -oE '\((archive/[^)#]+\.md)\)' "$f" 2>/dev/null | sed 's/[()]//g' | while IFS= read -r link; do
    [ -f "$dir/$link" ] || echo "  归档缺失: $f → $link"
  done
done

echo "== 完成（以上无输出项 = 通过）=="
