# 重构方案 v20 · commands → skills（裸 skill 方案，已废弃）


> ⚠️ **本方案已废弃**（v21 评审 + v22 plugin 实测后放弃）——裸 skill 方案 P1（update-memory description 与正文错配）/ P2（crules-init 主动触发误推销）为硬伤，且 plugin 化更优（`crules:` 命名空间根治撞名 + `disable-model-invocation` 解 P2 + cache 定位解 CRULES_HOME）。**定案方案见 [`重构方案-v22-plugin.md`](重构方案-v22-plugin.md)**。本文保留审计链，勿据此执行。


> 本方案是对评审.md v20「路线 C」的完整落地设计。前置实测已通过（见下）。属设计新机制，已过 v18 复盘闸口 1（参照物优先：superpowers / dart-flutter 已验证全 skill 零 command）+ 元闸口（本方案先实测再全面推行，非"草稿写成成品"）。

---

## 零、前置实测结果（已通过）

- 建 `~/.claude/skills/crules-init-test/SKILL.md`（最小 probe）。
- 用 `claude -p`（headless 全新会话，中性目录 `/tmp`）询问 → 新会话直接报 `FOUND: <description>`。
- **结论**：Claude Code 原生自动发现 `~/.claude/skills/`，无需 plugin 清单 / marketplace。路线 C 在本机可行。
- probe 用完已删。

---

## 一、为什么是 skill 而非 command（核心收益）

| 维度 | command（v19 撤的方案） | **skill（本方案）** |
|---|---|---|
| 触发 | 被动：用户敲 `/x`，记不住=触发不了 | **主动**：Claude 每次读 skill 的 `description`，判断该用就调用 |
| 防撞 | 文件名前缀（弱，人为约定） | 路径隔离（强，机制自带） |
| 团队共享 | cp 拷贝即脱钩 | 项目 `.claude/skills/` **随 git，pull 即有** |
| 生态对齐 | 否（自造命令体系） | **是**（同 superpowers / dart-flutter） |

**对 crules 的质变**：crules 的核心痛点是「纪律写了 ≠ 生效」。skill 的主动触发（Claude 在合适场景自动调用）正是治这个病——不靠用户记起「该敲 /update-memory」，而是 Claude 判断「这轮工作确立了新规则，该沉淀进记忆库」就主动触发。

---

## 二、三分法目录结构（核心设计）

三个 skill 服务范围不同，部署到三个不同位置（路径即 namespace，天然防撞，**无需 crules- 前缀**）：

### crules 仓库内的源文件组织

```
crules/
├─ .claude/
│  └─ skills/
│     └─ review-review/          ← 仓库内部工具，原位生效（审 docs/评审.md）
│        └─ SKILL.md
├─ skills/                        ← 待部署的模板源
│  ├─ crules-init/               ← → 部署到 ~/.claude/skills/（个人全局，引导器）
│  │  └─ SKILL.md
│  └─ update-memory/             ← → 部署到消费项目 .claude/skills/（项目级，进 git）
│     └─ SKILL.md
├─ CLAUDE.md / agents/ / memory/ / 进阶/ / 项目附录.md   ← 不变
└─ commands/                      ← 废弃（三文件迁出后删，或保留空目录 + README 指向 skills/）
```

### 部署后各 skill 的最终位置

| skill | 部署位置 | 进哪个 git | 触发时机 |
|---|---|---|---|
| `crules-init` | `~/.claude/skills/crules-init/` | 不进 git（个人全局） | Claude 见项目缺 CLAUDE.md / 要装规则时主动调 |
| `update-memory` | `<消费项目>/.claude/skills/update-memory/` | **进消费项目 git**（团队共享） | 这轮工作确立了该沉淀的业务规则/不变量/模式时主动调 |
| `review-review` | `crules/.claude/skills/review-review/` | 进 crules 仓库 git | crules 仓库的评审/决策文档更新后主动调 |

---

## 三、三个 SKILL.md 的 frontmatter（description 是灵魂）

`description` 决定 Claude 何时主动触发该 skill——必须写清"什么场景该用"。

### 1. crules-init（个人全局 · 引导器）

```yaml
---
name: crules-init
description: Use when setting up project collaboration rules for a new or existing project — installs the crules rule package (CLAUDE.md, agents, memory, skills) with gated defaults for new projects, or triages conflicts and merges for existing projects (never silently overwrites). Trigger when a project lacks CLAUDE.md or when the user wants crules rules applied.
---
```

正文：迁移自现 `commands/crules-init.md`（新/老项目两分支、步骤 0 定位源、2a 全装、2b 体检合并），把「cp commands/」改为「cp skills/update-memory/ → .claude/skills/」。

### 2. update-memory（消费项目级 · 运行时）

```yaml
---
name: update-memory
description: Use when the project's knowledge base needs updating — sedimenting a confirmed business rule, technical invariant, reusable code pattern, or decision into the crules memory system (business-rules.md / INVARIANTS.md / patterns.md / decisions). Trigger after completing work that established something worth persisting across sessions.
---
```

正文：迁移自现 `commands/update-memory.md`（更新记忆库的流程）。

### 3. review-review（crules 仓库级 · 内部工具）

```yaml
---
name: review-review
description: Use when a decision or review document (e.g. 评审.md) has been updated and needs an independent third-party meta-review — dispatches an isolated-context subagent to audit decision soundness, dogfooding consistency, and whether documented discipline actually landed (not just written). Trigger after updating review/evaluation docs in the crules repo.
---
```

正文：迁移自现 `commands/review-review.md`（独立 subagent 复审机制）。

---

## 四、git 共享策略（连带解决 v18-C 的一半）

| 资产 | 类型 | 进 git？ | 理由 |
|---|---|---|---|
| `crules/.claude/skills/review-review/` | crules 仓库工具 | ✅ crules git | 仓库内部工具，团队共享 |
| `crules/skills/crules-init/` | 模板源 | ✅ crules git | 模板，供首次部署 |
| `crules/skills/update-memory/` | 模板源 | ✅ crules git | 模板，供 crules-init 拷贝 |
| `<消费项目>/.claude/skills/update-memory/` | 部署副本 | ✅ 消费项目 git | **团队 pull 自动有，零部署** |
| `~/.claude/skills/crules-init/` | 个人全局 | ❌ 不进 git | 个人环境，每人自己装一次 |
| `memory/business-rules.md`、`INVARIANTS.md`、`patterns.md` | 制度模板 | ✅ git | 制度资产团队共享 |
| `memory/NAVIGATION.md`（索引）、`decisions/`（实例） | 运行时数据 | ❌ 本地或 .gitignore | 项目实例化数据 |

**对 v18-C 的连带**：v18-C 原标「memory git 分层，需 brainstorm 暂缓」。skill 化后边界已清晰——**制度资产（skill + memory 模板）进 git，运行时实例（indexes / decisions）本地**。v18-C 从「需 brainstorm」降级为「.gitignore 怎么写的工程问题」（印证独立 meta-review D4：v18-C 是被「trivial 推给 brainstorm」）。建议 v18-C 随本方案一并重新评估，大概率不需完整 brainstorm。

---

## 五、bootstrap（首次部署，一次性）

crules-init 自己第一次怎么进全局？任何方案都有第一次。skill 方案的 bootstrap 是**手动拷一个目录**（比命令方案更简单——skill 是自包含目录）：

```bash
# 一次性：把 crules-init 装进个人全局
cp -r ~/Downloads/ai-code/crules/skills/crules-init ~/.claude/skills/
```

之后 `crules-init` skill 在所有项目可用，引导其他项目时自动把 `update-memory` 拷进消费项目。

> 也可写进 crules/README.md 的「安装」节作为一行指令。

---

## 六、迁移映射（旧 → 新）

| 旧（commands/） | 新（skills/） | 部署位置 |
|---|---|---|
| `commands/crules-init.md` | `skills/crules-init/SKILL.md` | `~/.claude/skills/` |
| `commands/update-memory.md` | `skills/update-memory/SKILL.md` | 消费项目 `.claude/skills/` |
| `commands/review-review.md` | `.claude/skills/review-review/SKILL.md`（仓库级） | crules 仓库 `.claude/skills/` |

**命名**：三个 skill 名**保持原名**（crules-init / update-memory / review-review），**无破坏性 rename**。v19 想做的「统一加 crules- 前缀」被路径隔离取代——根本不需要前缀。

---

## 七、落地步骤

1. crules 仓库建 `skills/crules-init/`、`skills/update-memory/`、`.claude/skills/review-review/` 三目录。
2. 把 `commands/*.md` 内容迁入对应 `SKILL.md`（加 frontmatter，正文基本不变；crules-init 的 cp 路径改 skills/）。
3. 删 `commands/`（或保留 + README 指向 skills/）。
4. crules-init 正文 step 2a/2b 增加「cp update-memory → 消费项目 .claude/skills/」。
5. crules/README.md「安装」节补 bootstrap 一行（`cp -r skills/crules-init ~/.claude/skills/`）。
6. 交叉引用同步（6 处，独立 meta-review 已列：crules/README.md:70、记忆库体系.md:124、memory/README.md:26、MAINTENANCE.md:32、crules-init 自身、review-review 自身）——把「命令 / cp 到 commands/」措辞改「skill / .claude/skills/」。
7. v18-C 一并重新评估（边界已清晰，大概率随本方案定）。

---

## 八、风险与未覆盖

- **skill 主动触发的可靠性**未长期验证——description 写得好才会被恰当触发；写不好要么漏触发要么误触发。需上线后观察，迭代 description 措辞（参照 superpowers 的 description 写法）。
- **消费项目已有同名 update-memory skill** 的冲突——crules-init 装时应检测（体检步骤已有「禁静默覆盖」纪律，沿用即可）。
- **本方案只覆盖三个 skill**；crules 的 CLAUDE.md / agents / memory 仍是文档形态（不变），不强行 skill 化——它们是常驻上下文，不是触发式能力，skill 不是合适载体（superpowers 也把 CLAUDE.md 当文档、skills 当能力）。

---

## 九、一句话

v19 想「加前缀 + 全局 cp」是治标（命名层面）；本方案靠 skill 的**主动触发 + 路径隔离 + git 原生共享**治本——且零破坏性 rename，连带解了 v18-C。
