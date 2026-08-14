---
description: 初始化 crules——检测新/老项目，自动全装模板 + 引导填附录（新项目）或合并规则（老项目，禁静默覆盖）
disable-model-invocation: true
---

# /crules-init

把 crules 装到当前项目。自动检测新/老项目，走两分支：

- **新项目**（根目录无 `CLAUDE.md`）→ 全装（进阶门控默认关）→ 引导填附录必填项
- **老项目**（根目录已有 `CLAUDE.md`）→ 体检冲突 → 逐条取舍 → 合并（**禁静默覆盖**）

> 不必预先选规模——进阶篇自带「启用条件」门控，默认不开，用到才开（常驻成本为根 `CLAUDE.md` + `项目附录.md` 合计 ≈4–5k token，进阶篇不占常驻）。

## 执行步骤

### 0. 定位 crules 源

本命令随 crules plugin 分发，模板源在 plugin cache（固定路径 `~/.claude/plugins/cache/crules-market/crules/<version>/`）。AI 优先用 `ls ~/.claude/plugins/cache/crules-market/crules/` 取当前版本目录；cache 不存在（如手动 cp 部署）则问需求方 crules 模板包路径（如 `~/Downloads/ai-code/crules`）。找不到则提示需求方指定后停止。

> **分工说明**（plugin 化后）：本命令与 `/update-memory` 等能力经 `/plugin install crules` 分发；本命令只负责把**规则文档**（CLAUDE.md / 项目附录 / 进阶 / agents / memory）cp 或合并到消费项目——能力不重复 cp。

### 1. 检测新/老项目

读当前项目根目录：

- **无** `CLAUDE.md` → 新项目分支（步骤 2a）
- **有** `CLAUDE.md` → 老项目分支（步骤 2b）

### 2a. 新项目分支（全装）

1. 问技术栈（纯通用 / Flutter / 其他）→ 若 Flutter，提示同时装 `../flutter/`（App 或 Plugin 模板）
2. **全装规则文档**（进阶门控默认关，用到才开——不必选规模删文件；能力已随 plugin 安装，不重复 cp）：
   - `cp crules/CLAUDE.md` → 项目根 `CLAUDE.md`
   - `cp crules/项目附录.md` → 项目根 `项目附录.md`
   - `cp -r crules/进阶` → 项目根 `进阶/`
   - `cp -r crules/agents` → 项目根 `.claude/agents/`
   - `cp -r crules/memory` → 项目根 `.claude/memory/`
3. 引导填 `项目附录.md` 的 **3 个必填**（项目名 / 技术栈 / 构建·分析·测试命令）
4. 提示：进阶篇按「启用条件」门控自开，默认不影响；记忆库启用时按 `CLAUDE.md` §七 加会话级声明

### 2b. 老项目分支（合并，禁静默覆盖）

> ⚠️ 两个坑都要防：
> - **规则冲突**（如 crules「人工提交」vs 老项目「自动提交」）—— 体检必须显式列冲突
> - **资产覆盖**（老项目自己的 `.claude/agents|memory` 被 `cp -r` 吞掉）—— 进阶/agents/memory 也要体检，**逐个取舍**，不是一把 `cp -r`
>
> **禁静默覆盖是整个老项目分支的最高纪律**——既适用于 CLAUDE.md，也适用于 .claude/ 下的资产。

0. **硬护栏（动手前必做，E4）**：
   - **git 干净树检查**：项目是 git 仓库时先跑 `git status`，工作树不干净 → 提示需求方先 commit / stash 再继续（保证合并改动可 `git diff` 审阅、`git restore` 回退）
   - **时间戳备份**：`cp CLAUDE.md CLAUDE.md.bak.$(date +%Y%m%d%H%M%S)`；`.claude/` 下将被触及的同名资产，同样**先备份再动**
1. **体检 CLAUDE.md 冲突**：读老 `CLAUDE.md` + crules `CLAUDE.md`，列**冲突条款**（提交策略 / 双 Gate / 验证证据 / 不虚构 / 范围边界 / 敏感数据等），逐条标「仅老项目有 / 仅 crules 有 / 双方都有但不同」
2. **取舍 CLAUDE.md**：需求方逐条定——保留老的 / 用 crules 的 / 融合（融合写明怎么融）
3. **合并 CLAUDE.md**：据取舍生成合并 `CLAUDE.md`（老规则在前 + crules 纪律，冲突按取舍）；取舍记录落 `.claude/memory/decisions/`（为何保留 / 为何用 crules）
4. **附录对齐**：把老项目实际信息（技术栈 / 命令 / 红线）填进 `项目附录.md`，不重复造
5. **进阶 / agents / memory 体检合并**（**不是** `cp -r` 一把梭）：
   - **进阶/**：老项目若已有 `进阶/` 同名文件 → 同 CLAUDE.md 流程（体检→取舍→合并），冲突落 `decisions/`；无则直接复制
   - **`.claude/agents|memory`**：老项目若已有同名 → **默认保留老项目的**（那是该项目的真资产），crules 的同名文件作为参考并排（如 `crules-plan-reviewer.md`）或按需求方取舍；**禁止覆盖老项目既有文件**。无则直接复制
   - 老项目无 `.claude/` 目录时，方可 `cp -r` crules 的 agents/memory（无冲突 = 安全）；commands 不 cp（能力经 plugin 分发）

### 3. 收尾

- 列出装了哪些文件 / 老项目合并了哪些条款
- 提示下一步：开始用 Claude Code 开发（`CLAUDE.md` 自动加载）
- 若装了 `memory/`，提示会话级声明（参考 `CLAUDE.md` §七）

## 依据

- 模板包结构：`crules/README.md`「文件清单」
- 门控原则：进阶篇「启用条件」自门控，默认不开
- 老项目合并纪律：禁静默覆盖（对应 `CLAUDE.md`「先读后改」「风险操作先确认」「守住范围边界」）；硬护栏（git 干净树 + 时间戳备份）见步骤 2b.0

## 注意

- `/crules-init` 只装/合并规则文件，**不写业务代码**
- 重跑安全：新项目分支幂等（覆盖前确认）；老项目分支重跑会重新体检（已合并的条款标「已合并」）
- 老项目合并后，建议跑一遍 `/update-memory` 建立代码索引（若装了 memory/）
