#!/usr/bin/env python3
# crules 破坏性命令 deny-list（PreToolUse 硬闸，随 plugin 分发）
# 原则：只 deny 无歧义的破坏性命令，**不做任何意图判断**；被拦即请需求方人工执行
# 名单（最小集，误拦可加白名单，漏拦补名单）：
#   git push --force（--force-with-lease 放行）/ +refspec 强推 / push --delete·:branch /
#   git reset --hard / git clean -f / git branch -D /
#   git checkout·restore 丢弃工作区（裸 . / -- . / :/ 全树）/ rm 递归+强制（/tmp、/var/folders 放行）
# 边界与局限（诚实声明）：
#   - 切分覆盖 ; && || | 换行 及前缀环境变量赋值（FOO=1 git ...）——v37 补外审 5 绕过
#   - **黑名单无法穷尽**（变量拼接 / 嵌套 eval / 写脚本再执行等不在防线内）——本 hook 是
#     安全网而非沙箱，终极防线是 Claude Code 原生权限确认与需求方审阅
# 决策边界（v18 复盘）：v18-A 撤销的是「意图判断类」hook；本 hook 不判意图、deny-by-default
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

# 任一分隔符切出的子命令独立判定：; && || | 换行 回车
for part in re.split(r";|&&|\|\||\||\r?\n", cmd):
    s = part.strip()
    # 剥离前缀环境变量赋值与 command/exec 前缀（FOO=1 git … / exec git …）
    while True:
        s2 = re.sub(r"^([A-Za-z_]\w*=\S*\s+)|(^(command|exec)\s+)", "", s)
        if s2 == s:
            break
        s = s2
    if not s:
        continue
    if re.match(r"git\s+push\b", s):
        if ("--force" in s or re.search(r"\s-f(\s|$)", s)) and "force-with-lease" not in s:
            blocked("破坏性命令（git push --force）：请人工确认后自行执行；确需强推建议人工用 --force-with-lease")
        if "--delete" in s or re.search(r"\s:[^\s]", s):
            blocked("破坏性命令（git push 删除远端分支）：请人工确认后自行执行")
        if re.search(r"(^|\s)\+[^\s]+:", s):
            blocked("破坏性命令（git push +refspec 强制覆盖远端）：请人工确认后自行执行")
    if re.match(r"git\s+reset\b", s) and "--hard" in s:
        blocked("破坏性命令（git reset --hard）：请人工确认后自行执行")
    if re.match(r"git\s+clean\b", s) and re.search(r"(^|\s)-\w*f", s):
        blocked("破坏性命令（git clean -f）：请人工确认后自行执行")
    if re.match(r"git\s+branch\b", s) and re.search(r"(^|\s)-D\b", s):
        blocked("破坏性命令（git branch -D 强删分支）：请人工确认后自行执行")
    if re.match(r"git\s+(checkout|restore)\b", s):
        # 丢弃工作区形态：裸 . / -- . / :/（全树 pathspec）；-b/--branch（建分支）与 -s/--source（指定源）除外
        if re.search(r"(^|\s)(--\s*)?(\.|:/)(\s|$)", s) and not re.search(r"\s(-b|--branch|-s|--source)\b", s):
            blocked("破坏性命令（git checkout/restore 丢弃工作区改动）：请人工确认后自行执行")
    if re.match(r"rm\b", s):
        tokens = s.split()
        flags = [t.lstrip("-") for t in tokens[1:] if t.startswith("-")]
        has_r = any(f in ("r", "recursive") or (len(f) <= 2 and "r" in f) for f in flags)
        has_f = any(f in ("f", "force") or (len(f) <= 2 and "f" in f) for f in flags)
        if has_r and has_f:
            paths = [t for t in tokens[1:] if not t.startswith("-")]
            if not all(p.startswith(("/tmp/", "/var/folders/")) for p in paths):
                blocked("破坏性命令（rm 递归+强制，非临时目录）：请人工确认后自行执行")
sys.exit(0)
