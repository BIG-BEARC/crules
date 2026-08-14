# 模板包 CHANGELOG

> 只记「新增 / 删除了哪些文件 + 一句话能力」，供 README 维护者查「现在实际有哪些文件」。详细评审在 [`评审.md`](评审.md) + [`archive/`](archive/)。
> 维护触发：见 [`评审.md`](评审.md) 文档维护规则「总览同步检查」——模板文件增删 / 能力新增时，同步更新本文件 + 各 README。

---

## 08-12 · v18 复盘落地（hooks 方案撤销，纯文档修正）

- **`CLAUDE.md` 两处改**：①§二 提交策略「绿灯即 commit」误述改精确描述（superpowers 是 finishing-branch 选选项后执行，非绿灯即；冲突真实存在=触发点不同，crules §二 优先级链覆盖）②删顶部「版本：v1.1」行（无维护机制=误导）
- **未新增 hooks**：v18-A 经 superpowers 实测（零 PreToolUse）后整体撤销——crules 与 superpowers 在提交/破坏性纪律上都靠 prompt+原生工具确认，无 hook 层差距
- **`docs/评审.md`**：修正复盘自身两处事实误述（"superpowers 不自动 commit"等）+ 闸口 4 措辞微调

## 08-12 · v18 二审（`/review-review` 实战，仅评审意见，未落地）

- **未新增/删除文件**——本轮是对 v18-A 方案的独立复审，只产评审意见落 `docs/评审.md` v18 二审详情段
- 复审机制：`/review-review` 首次实战（独立 subagent + superpowers 调研 + transcript 格式实测）
- 结论：v18-A 方向对、实施否决（R1-R4），详见 `docs/评审.md`「v18 二审」段。落地路径待需求方定

## 08-12 · v17 落地（meta-review 机制 + 评审.md 精简）

- **`commands/review-review.md`** **新增**——`/review-review` slash command：独立上下文 subagent 审评审文档（复用方案评审闭环信息隔离：独立上下文 + 只读 + 结论不过滤）。**加强 2 点**：①subagent 可抽查 crules 源文件核验「已落地」声明（不只信评审.md 自报）②meta-review 落 `docs/meta-review/` 子目录（防 docs/ 膨胀）
- **`commands/crules-init.md`** 步骤 0 补 D（CRULES_HOME）不动代价注
- **`crules/README.md`** 文件清单 commands/ 行加 `review-review`
- **`docs/评审.md`** 精简：v12/v13 详情归档 → `docs/archive/详情-v12-v13.md`，详情段 5→3 轮（dogfooding 活跃/历史分离，v17 B1）；补 v16 落地 L14 执行证据留痕（v17 M1）；open 表编号笔误修正

## 08-12 · v16 落地（派生滞后第三次复发修复）

- **顶层 `README.md`**（ai-code/README.md）叙事对齐：「怎么选/三档复制」→「怎么用 / /crules-init + 进阶门控」（v15 叙事上溢上层）
- **`crules/README.md`** 文件清单表补 `commands/` 行（原漏，与自身「复制目标路径」表矛盾）
- **`commands/crules-init.md`** 修复两处：①老项目分支 2b.5 覆盖 bug——`cp -r` 改逐个体检合并（CLAUDE.md / 进阶 / .claude/ 全走体检→取舍→禁覆盖，同名资产默认保留老项目的）；②术语「用户」→「需求方」（L18 + 2b 全段）
- **`进阶/Agent编排.md`** 角色表后补归属注：主控/error/reviewer 在通用 agents/，frontend/backend/i18n/platform 在 flutter/agents/（Flutter 专属），plan-reviewer 属方案评审子系统不参与实现编排
- **评估后不动（带理由）**：CRULES_HOME 约定（治标，违背减负）/ NAVIGATION 占位死链（L58 总注已免责）/ CLAUDE.md 标题（复制后此标题对消费项目正确）
- **转缓办**：v13续 A/B2（元触发表+自检 checklist，属设计新机制）+ 历史文档分级纳管（v15续方法论未落入命令显式步骤）

## 08-11 · v14 包重命名 + v15 使用方式简化

- **v14**：包名「通用项目规则模板包」→ `crules`（目录 + 7 活文件自称 / 交叉引用 / AUTO-SYNC 标记全改；archive 历史评审保留旧名）
- **v15**：
  - `commands/crules-init.md` **新增**——`/crules-init` slash command（新项目全装 / 老项目合并 4 步，禁静默覆盖）
  - `README.md` 叙事反转：「怎么用」改一条命令 `/crules-init`；「三种规模」→「进阶门控」（默认全装，用到才开，不教选规模）
  - `项目附录.md` 减负：【必填】5→3（项目名 / 技术栈 / 构建·分析·测试命令）；仓库授权 / 数据红线降【可选】（通用兜底见 CLAUDE.md）

## 08-11 · v11-① 约束丢失类（INVARIANTS）

- `memory/INVARIANTS.md` **新增**——技术不变量载体（硬约束，每条配「可执行检查」字段，破坏即测试拦），与 `business-rules.md`（软约束·审查 Gate 拦）区分
- `进阶/记忆库体系.md` 加「约束分治 4 类」认知段（不变量 / 业务规则 / 决策 / 假设）+ 文件结构表 + 加载清单 + 触发表
- 接入点：审查与复核纪律（Gate 查约束）/ 方案评审闭环（plan-reviewer 查不变量破坏）/ plan-reviewer（检查维度）/ MAINTENANCE（触发表）/ CLAUDE §七（启用声明）

## 08-11 · v10 业务可达性知识层 + 分工层

- `memory/business-rules.md` **新增**——业务真实规则载体（防无知型可达性误判；称重域示例 3 条）
- `进阶/审查与复核纪律.md` 改造：定级前查规则 + L2「须需求方确认」+ AI 能力上限 L1 + 疑问单 + 撤条沉淀闭环
- 接入点：记忆库体系 / 方案评审闭环 / plan-reviewer / MAINTENANCE / CLAUDE §七
- 审查与复核纪律.md 悬空引用修复（`review-verify-business-reachability` → 指向 `business-rules.md`）

## 08-10 · v8 方案评审闭环

- `进阶/方案评审闭环.md` **新增**——实施前独立第三方方案评审（核心区分 / 信息隔离 / 角色四分 / 7 步闭环 / 循环守卫最多 3 轮 / 评审纪律只读锁 / spec-kit 交集待实测）
- `agents/plan-reviewer.md` **新增**——只读方案评审角色卡（`tools: Read, Glob, Grep`；写盘由主控原样落盘，非自己写）
- 接入点：CLAUDE §3（方案 Gate 大需求强化）+ §7（扩展入口）/ 工程化流程 §4（方案评审时机）/ 审查与复核纪律（审代码 vs 审方案区分）/ agents-README（角色速查 + 约定）

## 08-10 · v8 前既有

- `进阶/`：审查与复核纪律 / 工程化流程 / Agent编排 / 记忆库体系 / 插件工作流 / README
- `memory/`：NAVIGATION / MAINTENANCE / patterns / README
- `agents/`：error / reviewer / README
- `commands/`：update-memory
- 根：`CLAUDE.md` / `项目附录.md` / `README.md`
