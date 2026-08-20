# crules

一套**可直接复用**的项目协作规则模板——spec-kit + superpowers 的**通用约定层** + 技术栈目录（[`../flutter/`](../flutter/)，未来可加 `java/` 等）。核心原则**渐进增强**：核心规则零依赖、开箱即用；spec-kit / superpowers 桥接作为可选增强层。

> 与技术栈目录的关系：本包是**通用约定**（不限语言 / 框架的红线、流程、提交、审查）；技术栈专属内容（Flutter 角色、checklist、技术栈模板）在对应子目录，如 [`../flutter/`](../flutter/)。通用项目用本包，Flutter 项目用本包 + flutter/。

---

## 怎么用（两条命令）

```bash
# ① 一次性：装 crules plugin（本地路径源，user scope，不进任何项目 git）
claude plugin marketplace add ~/Downloads/ai-code/crules --scope user
claude plugin install crules@crules-market --scope user

# ② 在项目根目录跑（装好 plugin 后任何项目可用；plugin 命令带命名空间，裸名不可用）
/crules:crules-init
```

> `/crules:crules-init` 默认装**轻装模式**：项目根 `CLAUDE.md` 仅数行（`@` 导入 crules 源 + 本项目覆写节），规则更新**下次会话自动生效**、零复制零合并；可选**完整模式**全量 cp（团队多机 / 不依赖本机源路径时选）。进阶 / agents / memory 两种模式都照常复制。

`/crules-init` 自动检测新/老项目：

- **新项目**（无 `CLAUDE.md`）→ 全装（进阶门控默认关，用到才开）→ 引导填附录必填项
- **老项目**（有 `CLAUDE.md`）→ 体检规则冲突 → 逐条取舍 → 合并（**禁静默覆盖**）

不必预先选规模——进阶篇自带「启用条件」门控，默认不开，用到才开。`CLAUDE.md` 放项目根，启动时自动加载，红线 / 流程 / 提交策略直接生效。

> 不想用命令？手动 `cp` 见下方「复制目标路径」+「文件清单」，按需复制。

### `/crules:crules-init` 会做什么（向导流程）

交互式向导，**一步步问你，不是黑盒一键跑完；只动规则文件，不碰业务代码**。

**准备（自动）**：从 plugin cache 定位模板源（取版本号最大目录）；被权限挡住时问你 crules 仓库路径。
**分流（自动）**：项目根有无 `CLAUDE.md` → 新项目 / 老项目。

**新项目分支——三问 + 复制：**

1. 问技术栈（Flutter → 提示同时装 [`../flutter/`](../flutter/)）
2. 问安装模式：**轻装（默认）**——CLAUDE.md 仅数行 `@` 导入 + 覆写节，规则更新下次会话自动生效；**完整**——全量 cp（团队多机 / 高定制），更新须重跑本命令合并
3. 引导填**附录 3 必填**（项目名 / 技术栈 / 构建·分析·测试命令——crules 的验证纪律靠它知道在你项目里该跑什么命令）

复制清单（两种模式的按需文档相同）：

```text
你的项目/
├── CLAUDE.md            轻装：数行导入 / 完整：全文
├── 项目附录.md           模板，待填
├── 进阶/                6 篇，门控默认关、用到才读
└── .claude/
    ├── agents/          error / reviewer / plan-reviewer（均只报不改）
    └── memory/          NAVIGATION / MAINTENANCE / patterns / business-rules / INVARIANTS
```

**老项目分支——「禁静默覆盖」最高纪律：**

0. **硬护栏**：`git status` 确认工作树干净（不干净先 commit/stash）→ 现有 CLAUDE.md 与 `.claude/` 资产打时间戳备份——**全程可回退**
1. **体检冲突**：逐条列出老规则 vs crules 规则差异（提交策略 / 双 Gate / 验证 / 范围边界……），标「仅老项目有 / 仅 crules 有 / 双方都有但不同」
2. **你逐条裁决**：保留老的 / 用 crules 的 / 融合（说明怎么融）
3. **生成合并 CLAUDE.md**：取舍记录落 `.claude/memory/decisions/`（留审计）；也可产轻装形态（`@` 导入 + 老规则整体放覆写节）
4. **附录对齐**：把老项目实际命令 / 红线填进附录，不重复造
5. **资产体检**：老项目 `.claude/agents|memory` 同名文件**默认保留你的**（那是真资产），crules 的并排参考，禁止覆盖

**跑完后，每次会话自动生效**：规则常驻（先方案后动手 / 不自动 commit，你说 `commit` 才提交 / 完成必贴验证输出）；破坏性命令硬闸与 plugin 能力属 user 级，独立于 init 全局生效。

### 工具链（可选增强）

本包不依赖任何插件即可用。若装了 spec-kit / superpowers，工作流的 skill 映射见 [`进阶/插件工作流.md`](进阶/插件工作流.md)——两者在需求 / 方案阶段重叠，**选一个为主或混搭**，由你指定。没装则用内置兜底（Plan 模式等），仍是完整工作流。

### 复制目标路径

| 模板内容 | 复制到 |
|---|---|
| `CLAUDE.md` | 轻装模式**不复制**——项目根 CLAUDE.md 仅写 `@` 导入 + 覆写节；完整模式复制到项目根 |
| `项目附录.md` / `进阶/` | 项目根（保持相对路径） |
| `agents/` | `.claude/agents/` |
| `memory/` | `.claude/memory/` |
| `docs/` | **不复制**——评审 / 重构方案 / CHANGELOG 属 crules 仓库自身的维护资产，消费项目无需 |

> 命令（crules-init / update-memory）**不走 cp**——经 plugin 分发（上方「怎么用」①步），`claude plugin update` 即更新；`review-review` 是 crules 仓库内部命令，在仓库本地 `.claude/commands/`，不随包分发。**hooks 亦随 plugin 自带**：破坏性命令 deny-list 硬闸（`git push --force` / `reset --hard` / `clean -f` / `branch -D` / `rm -rf` 等，被拦即提示人工执行），消费项目零配置获得。

---

## 进阶门控（默认全装，用到才开）

`/crules-init` 默认全装；进阶篇各带「启用条件」门控，**默认不开**，用到才开——不必预先选规模删文件。下表仅作「什么场景自然启用哪篇」参考：

| 进阶篇 | 何时自然启用 | 适合规模 |
|---|---|---|
| `审查与复核纪律.md` | 需要 code review / 资损评估 | 标准↑ |
| `工程化流程.md` + `方案评审闭环.md` | 新页面 / 跨模块 / 大需求 | 标准↑ |
| `Agent编排.md` | 用多 agent 协作 | 重度 |
| `记忆库体系.md`（含 `business-rules.md` / `INVARIANTS.md` 约束载体） | 大项目代码索引 / 约束外化 | 重度 |
| `插件工作流.md` | 装了 superpowers / spec-kit | 任意 |

**精髓**：`CLAUDE.md` 零依赖、单独可用，作为根规则常驻会话（与 `项目附录.md` 合计 ≈4.6–5.3k token；v47 提炼 +4 条实施 / 验证纪律后的口径）；进阶全装但门控默认关，用到才开。

---

## 文件清单

| 文件 | 职责 | 何时用 |
|---|---|---|
| `CLAUDE.md` | **根规则**：协作红线 / 提交策略 / 双 Gate 工作流 / 验证证据 / 完成定义。自包含，不依赖其他文件 | 任何项目，必复制 |
| `项目附录.md` | 项目特有信息填空位（技术栈 / 命令 / 模拟器 / 红线） | 必复制，复制后填 |
| `进阶/审查与复核纪律.md` | 代码审查、资损评估的方法论（业务可达性 Gate / 子代理复核 / 资损克制 / 专家否决）+ Review Checklist | 需要 code review 时 |
| `进阶/工程化流程.md` | 新页面 / 跨模块大改动的 PRD 流程、任务粒度、两阶段审查、worktree | 大需求时 |
| `进阶/Agent编排.md` | 多 agent 协作的角色分工、调度、主控复核 | 用多 agent 时 |
| `进阶/记忆库体系.md` | `.claude/memory/` 代码索引、决策日志、触发即更新 | 大项目代码索引时 |
| `进阶/方案评审闭环.md` | 大需求方案评审：独立第三方 agent 审方案（实施**前**），与代码审查（实施**后**）区分；角色四分、7 步闭环、循环守卫 | 大需求方案评审时 |
| `进阶/插件工作流.md` | superpowers / spec-kit 与本包工作流的 skill 映射；两者重叠选一个为主或混搭 | 装了插件时 |
| `agents/` | 各角色 agent 描述（启用 Agent 编排时的配套资源） | 用 Agent 编排时 |
| `memory/` | 记忆库目录框架：`NAVIGATION.md`（导航入口）/ `MAINTENANCE.md`（自动维护规则）/ `patterns.md` / `business-rules.md`（业务规则·软约束）/ `INVARIANTS.md`（技术不变量·硬约束）；`indexes/`、`decisions/` 为启用记忆库后按需创建（NAVIGATION 中为占位示例） | 用记忆库时 |
| `commands/` | 2 个 slash 命令（均 `disable-model-invocation`，显式发起）：`crules-init`（初始化新/老项目）/ `update-memory`（重建代码索引）——**经 plugin 分发**，不随 cp 走 | 装为 Claude Code plugin 时 |
| `hooks/` | **破坏性命令 deny-list 硬闸**（PreToolUse，无意图判断、deny-by-default，被拦即请人工执行；名单非穷尽——安全网而非沙箱，终极防线是原生权限确认）+ 记忆库漂移提醒队列（PostToolUse）——随 plugin 分发零配置，`hooks/test_deny_list.py` 为对抗样本库 | 随 plugin 自动生效 |

---

## 规则用词（元规则）

本包所有规则统一用词，编写或修改规则时遵循：

- **必须**：不可默认跳过的步骤。
- **禁止**：范围、安全或证据红线。
- **默认**：没有其他明确说明时采用的行为。
- **例外**：只能由需求方明确授权，不得从模糊表述推断。

规则尽量按以下结构编写，使其可执行、可验收：

> 触发条件 → 必须动作 → 例外条件 → 完成证据

---

## 维护原则

- **权威正文单一**：同一套规则只保留一份权威正文，其他入口只链接或摘要，避免多个不一致版本。
- **通用 / 项目分离**：通用规则写进 `CLAUDE.md`（开箱即用）；项目特有信息只进 `项目附录.md`，不污染通用正文。
- **新增优先于修改**：加规则是安全的；改已有规则要考虑对已复用项目的影响。

---

## 来源说明

本包从多份实战方法论整合提炼，已剔除原项目业务与技术栈细节，保留纯方法论：

- 某项目工作规则文档集（协作红线、agent 编排、记忆库体系、分层架构纪律）
- 《协作与交付工作规则》v1.0（双 Gate、验收证据分级、完成定义、范围边界、不虚构条款）
- 一次称重功能审查的 feedback（审查与复核纪律：业务可达性、子代理复核、资损克制）
