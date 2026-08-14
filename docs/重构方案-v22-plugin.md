# 重构方案 v22 · crules plugin 化（定案）

> 本方案是 v20「裸 skill 方案」经 v21 评审 + v22 plugin 实测后的**定案修订**。裸 skill 方案已放弃（见 [`archive/重构方案-v20-skills.md`](archive/重构方案-v20-skills.md) 顶部废弃标注）。本轮定案未动 `commands/` 源文件，属待执行方案。
>
> **v28 决议修订（08-14，需求方裁决 R1 收口）**：① `review-review` **不进 plugin**——只服务 crules 仓库自身（审 `docs/评审.md`），留仓库本地 `.claude/commands/`；② `update-memory` **改 command**（原案 skill 与「兜底全量刷新·显式发起」定位矛盾，三分法统一为显式 command + `disable-model-invocation`）；③ plugin.json/marketplace.json 旧名已改 crules（N1）。下文已按此更新。

---

## 零、与 v20 的关系

| 维度 | v20 裸 skill（放弃） | **v22 plugin（本方案）** |
|---|---|---|
| 分发形态 | 裸 skill 文件夹，手动 cp | 打包成 plugin，`/plugin install` |
| 命名空间 | 裸名（撞车风险） | `crules:` 命名空间（根治撞名） |
| 三分法隔离 | 靠**目录位置**（全局/项目/仓库） | 靠**触发形态**（command 显式 / skill 主动）+ description 语义 |
| bootstrap | 手动 cp -r | `/plugin install` 一键可逆 |
| 本地使用 | 天然 | 本地路径源 + user scope（享全部优势） |

核心理解（v22 概念澄清）：**plugin 是 skill 的容器，不是 skill 的替代**。crules 的能力仍写成 skill/command，只是打包成 plugin 分发。

---

## 一、关键设计：plugin 与 crules-init 分工

crules 的资产分两类，plugin 化后由不同机制处理：

| 资产 | 形态 | 谁负责分发 |
|---|---|---|
| **能力**（crules-init / update-memory） | command（均显式发起） | **plugin 机制**（`/plugin install`，带 `crules:` 命名空间） |
| **仓库内部工具**（review-review） | command | **不进 plugin**——crules 仓库本地 `.claude/commands/`（v28 决议：受众仅本仓库，消费项目不装） |
| **规则文档**（CLAUDE.md / agents/ / memory/ / 进阶/ / 项目附录） | 常驻上下文文件 | **crules-init command**（cp/合并到消费项目根——这些不是 skill，plugin 不自动"装"到项目根） |

**为什么规则文档仍要 cp**：消费项目的 Claude 要把 CLAUDE.md/agents/memory 当**常驻上下文**读（每次会话加载），它们必须是消费项目里的实际文件，不是 plugin 里的命名空间能力。plugin 管"能力分发"，crules-init 管"规则文档本地化"，两者分工。

---

## 二、crules 仓库 plugin 化结构

```
crules/
├─ .claude-plugin/
│  ├─ plugin.json              # plugin 清单
│  └─ marketplace.json         # 本地 marketplace（source: "./"，self-hosted）
├─ commands/                   # 用户显式发起的能力（v28：统一 command，无 skills/）
│  ├─ crules-init.md
│  └─ update-memory.md
├─ CLAUDE.md / agents/ / memory/ / 进阶/ / 项目附录.md   # 规则文档（不变，crules-init cp 它们）
└─ docs/ ...
```

> `review-review.md` 留在 `commands/` 作模板源，**不进 plugin 分发**；crules 仓库自己的 `.claude/commands/` 放一份供本仓库使用（v28 决议）。

三分法从"部署位置"改为"触发形态"：

| 能力 | 形态 | 触发 | 解决的问题 |
|---|---|---|---|
| `crules-init` | **command** | 显式（`disable-model-invocation: true`） | 解 P2（不主动推销） |
| `update-memory` | **command** | 显式（`disable-model-invocation: true`） | 兜底全量刷新·显式发起（v28：贯彻三分法，R1 收口） |
| `review-review` | **不进 plugin**（仓库本地） | 显式 | 受众=crules 仓库自身，消费项目不装（v28：消除"死命令装活位置"） |

---

## 三、两个能力的 frontmatter（修正 P1/P2；v28 收口 R1）

### 1. crules-init（command，解 P2）

```yaml
---
description: Install or merge the crules rule package into the current project. Detects new vs existing project; installs fresh (gated defaults) or triages conflicts and merges without silent overwrite. Run only when explicitly requested by the user.
disable-model-invocation: true
---
```

- `disable-model-invocation: true`（实测验证有效）= 模型不主动触发，只用户敲 → **解 P2 误推销**
- 正文：迁移自现 `commands/crules-init.md`，但步骤 0「定位源」改为**从 plugin cache 读**（见第六节，解 v15 CRULES_HOME）

### 2. update-memory（command，v28 决议改形态）

```yaml
---
description: 对 .claude/memory/ 做全量兜底刷新——对比源码现状，增量更新所有索引。长时间未维护或批量重构后索引大面积失效时使用。索引同步工具，不用于沉淀规则（业务规则/不变量走 business-rules.md/INVARIANTS.md 常规纪律）。
disable-model-invocation: true
---
```

- description 保持**真实语义「索引同步」**（P1 修正沿用），明确不用于沉淀规则
- **v28 改 skill → command**：原案 skill（模型主动）与正文自定位「兜底工具·显式发起」矛盾（R1）；改 command + `disable-model-invocation: true`，与 crules-init 标准统一
- 正文：`commands/update-memory.md` 原文基本不动（本就按显式命令写）

### 3. review-review（不进 plugin，v28 决议）

- **原 A 选项（skill + description 软门控）废弃**——与 P2 硬开关标准不统一（R1），且消费项目闲置 ~20 tok/session 无意义
- **改为**：不进 plugin 分发；`commands/review-review.md` 留作模板源，crules 仓库自己的 `.claude/commands/` 放一份（受众=本仓库，审 `docs/评审.md`）
- 消费项目完全不装 → 「死命令装活位置」（v19 病）从根上消除

---

## 四、plugin.json + marketplace.json（本地 self-hosted）

`.claude-plugin/plugin.json`：
```json
{
  "name": "crules",
  "version": "0.1.0",
  "description": "crules——CLAUDE.md 协作规则 + agents + memory + skills/commands",
  "author": { "name": "chuxiong" }
}
```

`.claude-plugin/marketplace.json`（本地路径源，source "./"）：
```json
{
  "name": "crules-market",
  "owner": { "name": "chuxiong" },
  "plugins": [
    {
      "name": "crules",
      "source": "./",
      "version": "0.1.0",
      "description": "crules 项目协作规则模板包"
    }
  ]
}
```

---

## 五、本地使用（用户需求：不团队共享）

```bash
# crules 仓库作为本地 marketplace 源（本地路径 = 天然不共享）
claude plugin marketplace add ~/Downloads/ai-code/crules --scope user
# 安装（user scope = 声明进 ~/.claude/settings.json，不进任何项目 git）
claude plugin install crules@crules-market --scope user
```

| 选择 | 取值 | 效果 |
|---|---|---|
| marketplace 源 | 本地路径 | 只在本机有效，换机/换人失效 → 天然不共享 |
| install scope | `user` | `~/.claude/settings.json`，不进项目 git |

本地用 plugin 仍享全部优势（命名空间 / 一键装/卸 / disable-model-invocation / 版本）。将来要共享：源改 git repo + scope 改 `project`，平滑升级。

---

## 六、bootstrap + update（连带解 v15 CRULES_HOME）

**bootstrap**：一次性 `marketplace add` + `install`（比裸 skill 的 cp -r 更简单，且可逆）。

**update**：改 crules 源后 `claude plugin update crules@crules-market` 同步到 cache。
> ⚠️ update 链路**未实测**（v22 实测只覆盖 install/uninstall/discover），落地时验证：改一处源 → update → 新会话确认生效。

**连带解 v15 CRULES_HOME**：plugin 安装时把整个 crules 仓库（含 CLAUDE.md/agents/memory）copy 到固定 cache 路径 `~/.claude/plugins/cache/crules-market/crules/<version>/`。crules-init 的步骤 0「定位源」改为**从 plugin cache 读**——cache 是已知固定路径，不再需要 v15 反复纠结的 `CRULES_HOME` 环境变量或每次问需求方。
> ⚠️ cache 路径含版本号，crules-init 如何定位当前版本路径（glob `cache/crules-market/crules/*/` 或 plugin 自路径机制）**待落地验证**。

---

## 七、落地步骤

1. crules 仓库补 `.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json`
2. `commands/update-memory.md` 加 `disable-model-invocation: true`（v28：不迁 skills/，原位改 command 形态）
3. `commands/crules-init.md` 加 `disable-model-invocation: true`（解 P2）；步骤 0 改"从 plugin cache 读源"
4. `commands/review-review.md` 留模板源**不进 plugin**；crules 仓库自己的 `.claude/commands/` 放一份（v28 决议）
5. `marketplace add ~/Downloads/ai-code/crules` + `install crules@crules-market`（user scope）
6. 新会话验证：
   - `claude plugin details crules@crules-market` 组件清单 = 2 command（crules-init / update-memory）
   - 两个 command 的 slash 调用形态（`/crules-init` 还是 `/crules:crules-init`）**待确认**
7. 交叉引用同步：crules/README.md（commands 行说明 plugin 分发）、记忆库体系.md「维护时机」、MAINTENANCE.md、crules-init 步骤 4——update-memory 的分发描述改 plugin
8. crules-init 正文 step 2a/2b 调整：消费项目通过 `/plugin install crules` 已装能力，crules-init 只负责 cp/合并**规则文档**（CLAUDE.md/agents/memory/进阶/项目附录）到项目根

---

## 八、风险与未验证（诚实标注）

| 项 | 状态 |
|---|---|
| plugin 命名空间 + command 发现 + disable-model-invocation | ✅ v22 实测通过 |
| `claude plugin update` 同步链路 | ⚠️→✅ **v31 修正**：update 以版本号为键——**同版本号不刷新 cache**（v29「实测通过」实为 `plugin details` 读源，cache 未变）；**每次改 plugin 内容须 bump `plugin.json` + `marketplace.json` 版本号**，update 才落新 cache 目录（v31 实测 0.1.0→0.1.1 ✅） |
| crules-init 从 plugin cache 定位源（解 CRULES_HOME） | ✅ v29 实测 cache 路径 `~/.claude/plugins/cache/crules-market/crules/<version>/` 成立 |
| command 的 slash 调用形态（带不带 `crules:` 前缀） | ✅ v34 实测：须用 **`/crules:crules-init`**（裸名 Unknown command）；`-p` 端到端验证命令可执行且行为正确（正确走新项目分支 / 步骤 0 取版本号最大 / 找不到源按纪律停+给选项） |
| review-review 隔离 | ✅ v28 决议不进 plugin + v29 移至仓库本地 `.claude/commands/`（原 A 选项废弃） |

---

## 九、一句话

plugin 化不是"用 plugin 替代 skill"，是"把 crules 的能力装进 plugin 容器"——换得 `crules:` 命名空间根治撞名、一键装/卸、`disable-model-invocation` 解 P2、cache 定位解 CRULES_HOME；本地路径源 + user scope 满足纯本地不共享。v28 收口 R1 后形态更简：**两个显式 command 进 plugin，review-review 留仓库本地，无 skills/**。
