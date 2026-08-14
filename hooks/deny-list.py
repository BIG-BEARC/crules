#!/usr/bin/env python3
# crules 破坏性命令 deny-list（PreToolUse 硬闸，随 plugin 分发）
# 原则：只 deny 无歧义的破坏性命令，**不做任何意图判断**；被拦即请需求方人工执行
# 名单（最小集，误拦可加白名单，漏拦补名单）：
#   git push --force（--force-with-lease 放行并建议）/ git push --delete / git reset --hard /
#   git clean -f / git branch -D / git checkout -- . / git restore . /
#   rm 递归+强制（路径全在 /tmp、/var/folders 下放行）
# 决策边界（v18 复盘）：v18-A 撤销的是「意图判断类」hook（如判定用户是否授权 commit）；
# 本 hook 不判意图、deny-by-default，属边界外窄范围重开（v25 外审建议，v35 落地）。
import json, re, sys

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
cmd = (data.get("tool_input") or {}).get("command") or ""
if not cmd.strip():
    sys.exit(0)

def blocked(reason):
    print(json.dumps({"decision": "block", "reason": reason}, ensure_ascii=False))
    sys.exit(0)

for part in re.split(r";|&&|\|\|", cmd):
    s = part.strip()
    if re.match(r"git\s+push\b", s):
        if ("--force" in s or re.search(r"\s-f(\s|$)", s)) and "force-with-lease" not in s:
            blocked("破坏性命令（git push --force）：请人工确认后自行执行；确需强推建议人工用 --force-with-lease")
        if "--delete" in s or re.search(r"\s:[^\s]", s):
            blocked("破坏性命令（git push 删除远端分支）：请人工确认后自行执行")
    if re.match(r"git\s+reset\b", s) and "--hard" in s:
        blocked("破坏性命令（git reset --hard）：请人工确认后自行执行")
    if re.match(r"git\s+clean\b", s) and re.search(r"(^|\s)-\w*f", s):
        blocked("破坏性命令（git clean -f）：请人工确认后自行执行")
    if re.match(r"git\s+branch\b", s) and re.search(r"(^|\s)-D\b", s):
        blocked("破坏性命令（git branch -D 强删分支）：请人工确认后自行执行")
    if re.match(r"git\s+checkout\b", s) and re.search(r"--\s*\.\s*$", s):
        blocked("破坏性命令（git checkout -- . 丢弃全部工作区改动）：请人工确认后自行执行")
    if re.match(r"git\s+restore\b", s) and re.search(r"(^|\s)\.(\s|$)", s):
        blocked("破坏性命令（git restore . 丢弃工作区改动）：请人工确认后自行执行")
    if re.match(r"rm\b", s):
        tokens = s.split()
        joined = "".join(t.lstrip("-") for t in tokens if t.startswith("-") and not t.startswith("--"))
        if "r" in joined and "f" in joined:
            paths = [t for t in tokens[1:] if not t.startswith("-")]
            if not all(p.startswith(("/tmp/", "/var/folders/")) for p in paths):
                blocked("破坏性命令（rm 递归+强制，非临时目录）：请人工确认后自行执行")
sys.exit(0)
