#!/usr/bin/env python3
"""deny-list 回归测试（v37 沉淀——修正 v35「单测 15/15 跑完即弃、无文件无痕」）。

跑法：python3 hooks/test_deny_list.py（scripts/check-consistency.sh 的 H 查调用）
fixture 原则：该拦全拦（含 v37 外审 5 绕过）、该放全放（含 --force-with-lease / /tmp 白名单）；
新增绕过形态时**先加 fixture（红）→ 修 deny-list（绿）**，测试即对抗样本库。
"""
import json, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))

# 应拦：v35 原 10 例 + v37 外审绕过 5 例 + 加固新增 4 例
BLOCK_CASES = [
    # --- v35 原有 ---
    "git push --force origin main",
    "git reset --hard HEAD~1",
    "rm -rf ~/Downloads",
    "rm -rf build",
    "git clean -fd",
    "git branch -D feat",
    "cd src && rm -rf lib",
    "echo hi && git reset --hard",
    "git checkout -- .",
    "git push origin :old-branch",
    # --- v37 外审绕过（回归防线）---
    "echo hi\ngit reset --hard HEAD",        # 换行切分
    "true | git push --force origin main",   # 单管道切分
    "git push origin +main:main",            # +refspec 强推
    "git checkout .",                        # 裸 . 不带 --
    "git restore :/",                        # 全树 pathspec
    "rm --recursive --force build",          # 长选项
    # --- v37 加固新增 ---
    "git restore .",
    "git checkout :/",
    "FOO=1 git reset --hard",                # 前缀环境变量赋值
    "command git clean -fd",                 # command 前缀
]

# 应放：正常命令 / 白名单 / 安全变体
ALLOW_CASES = [
    "git push origin main",
    "git push --force-with-lease",           # 安全强推变体
    "git push origin main:main",             # 普通 refspec（无 +）
    "git status",
    "rm -rf /tmp/junk",                      # 临时目录白名单
    "rm build",                              # 无递归
    "rm -r build_dir",                       # 只递归无强制
    "ls -la",
    "git log --oneline",
    "git checkout main",                     # 切分支（非丢弃）
    "git checkout -b feat",                  # 建分支
    "git restore -s stash@{1} .",            # 指定源恢复（非丢弃工作区）
    "echo 'a|b'",                            # 引号内的管道符
    "pip install --force",                   # 非 git push 的 --force
]

def should_block(case: str) -> bool:
    p = subprocess.run(
        [sys.executable, os.path.join(HERE, "deny-list.py")],
        input=json.dumps({"tool_input": {"command": case}}),
        capture_output=True, text=True,
    )
    return '"block"' in p.stdout

def main() -> int:
    fails = []
    for c in BLOCK_CASES:
        if not should_block(c):
            fails.append(f"应拦未拦: {c!r}")
    for c in ALLOW_CASES:
        if should_block(c):
            fails.append(f"应放未放: {c!r}")
    for f in fails:
        print("FAIL", f)
    print(f"deny-list 测试: {len(BLOCK_CASES)} 拦 + {len(ALLOW_CASES)} 放, 失败 {len(fails)}")
    return 1 if fails else 0

if __name__ == "__main__":
    sys.exit(main())
