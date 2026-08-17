#!/usr/bin/env python3
# crules 破坏性命令 deny-list（PreToolUse 硬闸，随 plugin 分发）
# 原则：只 deny 无歧义的破坏性命令，**不做任何意图判断**；被拦即请需求方人工执行
# 名单（六类 git + rm）：
#   git push --force（--force-with-lease 放行）/ +refspec 强推 / push --delete·:branch /
#   git reset --hard / git clean -f（-n dry-run 放行）/ git branch -D /
#   git checkout·restore 丢弃工作区（裸 . / ./ / -- . / :/ 全树 / * glob）/ rm 递归+强制
# 匹配策略（v39，收敛 v38 红队六类绕过）：
#   - 分段（; && || | 换行）后，git/rm 签名用**非锚定搜索**——前缀（sudo/env/FOO=1/带参）、
#     包裹（( )/$( )/反引号）、全局选项（git -C dir）一次吃掉，不枚举前缀词（打地鼠）
#   - rm 白名单用 **normpath 而非 realpath**（macOS /tmp→/private/tmp 符号链接，realpath 反而
#     误拦合法白名单；符号链接别名攻击明确不在防线内）
# 边界与局限（诚实声明）：
#   - 非锚定搜索会把字符串里的破坏命令一并拦下（如 echo '…git reset --hard…'）——按
#     deny-by-default 哲学接受，误拦走白名单调整
#   - **黑名单无法穷尽**（变量拼接 / 嵌套 eval / 写脚本再执行等不在防线内）——本 hook 是
#     安全网而非沙箱，终极防线是 Claude Code 原生权限确认与需求方审阅
# 决策边界（v18 复盘）：v18-A 撤销的是「意图判断类」hook；本 hook 不判意图、deny-by-default
import json, os, re, sys

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

GIT_SIG = re.compile(r"\bgit\b[^;|]*?\b(push|reset|clean|branch|checkout|restore)\b")
RM_SIG = re.compile(r"(^|[\s(`$!])rm\b")

def parse_flags(tokens):
    """返回 (短旗标串, 长旗标集)：-nfd→'nfd'，--force→'force'"""
    short, longs = "", set()
    for t in tokens:
        if t.startswith("--") and len(t) > 2:
            longs.add(t[2:])
        elif t.startswith("-") and len(t) > 1:
            short += t[1:]
    return short, longs

def checkout_discards(seg_after_sub):
    """checkout/restore 子命令之后的 pathspec 是否丢弃形态：. ./ :/… *（-- 直通）"""
    for tok in seg_after_sub.split():
        if tok == "--":
            continue
        if tok.startswith("-"):
            if tok in ("-b", "--branch", "-s", "--source"):
                return False  # 建分支 / 指定源，非丢弃
            continue
        core = tok.rstrip("/") or tok
        if core in (".", "*") or tok.startswith(":/") or core == ":":
            return True
    return False

for part in re.split(r";|&&|\|\||\||\r?\n", cmd):
    seg = part.strip()
    if not seg:
        continue

    m = GIT_SIG.search(seg)
    if m:
        sub = m.group(1)
        if sub == "push":
            if ("--force" in seg or re.search(r"(^|\s)-f(\s|$)", seg)) and "force-with-lease" not in seg:
                blocked("破坏性命令（git push --force）：请人工确认后自行执行；确需强推建议人工用 --force-with-lease")
            if "--delete" in seg or re.search(r"\s:[^\s]", seg):
                blocked("破坏性命令（git push 删除远端分支）：请人工确认后自行执行")
            if re.search(r"(^|\s)\+\S+", seg):
                blocked("破坏性命令（git push +refspec 强制覆盖远端）：请人工确认后自行执行")
        elif sub == "reset" and "--hard" in seg:
            blocked("破坏性命令（git reset --hard）：请人工确认后自行执行")
        elif sub == "clean":
            short, longs = parse_flags(seg.split())
            if ("f" in short or "force" in longs) and not ("n" in short or "dry-run" in longs):
                blocked("破坏性命令（git clean -f）：请人工确认后自行执行")
        elif sub == "branch" and re.search(r"(^|\s)-D\b", seg):
            blocked("破坏性命令（git branch -D 强删分支）：请人工确认后自行执行")
        elif sub in ("checkout", "restore") and checkout_discards(seg[m.end(1):]):
            blocked("破坏性命令（git checkout/restore 丢弃工作区改动）：请人工确认后自行执行")

    r = RM_SIG.search(seg)
    if r:
        tokens = seg[r.start():].split()  # rm 及其后 token（跳过前缀/包裹）
        short, longs = parse_flags(tokens)
        has_r = "r" in short or "recursive" in longs
        has_f = "f" in short or "force" in longs
        if has_r and has_f:
            paths = [os.path.normpath(os.path.expanduser(t)) for t in tokens[1:] if not t.startswith("-")]
            if not all(p == "/tmp" or p.startswith("/tmp/") or p.startswith("/var/folders/") for p in paths):
                blocked("破坏性命令（rm 递归+强制，非临时目录）：请人工确认后自行执行")
sys.exit(0)
