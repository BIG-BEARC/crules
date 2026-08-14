# 重构方案 v22 · crules plugin 化（定案）

> 本方案是 v20「裸 skill 方案」经 v21 评审 + v22 plugin 实测后的**定案修订**。裸 skill 方案已放弃（见 [`archive/重构方案-v20-skills.md`](archive/重构方案-v20-skills.md) 顶部废弃标注）。本轮定案未动 `commands/` 源文件，属待执行方案。

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
| **能力**（crules-init / update-memory / review-review） | skill / command | **plugin 机制**（`/plugin install`，带 `crules:` 命名空间） |
| **规则文档**（CLAUDE.md / agents/ / memory/ / 进阶/ / 项目附录） | 常驻上下文文件 | **crules-init command**（cp/合并到消费项目根——这些不是 skill，plugin 不自动"装"到项目根） |

**为什么规则文档仍要 cp**：消费项目的 Claude 要把 CLAUDE.md/agents/memory 当**常驻上下文**读（每次会话加载），它们必须是消费项目里的实际文件，不是 plugin 里的命名空间能力。plugin 管"能力分发"，crules-init 管"规则文档本地化"，两者分工。

---

## 二、crules 仓库 plugin 化结构

```
crules/
├─ .claude-plugin/
│  ├─ plugin.json              # plugin 清单
│  └─ marketplace.json         # 本地 marketplace（source: "./"，self-hosted）
├─ skills/                     # 模型主动触发的能力
│  ├─ update-memory/
│  │  └─ SKILL.md
│  └─ review-review/
│     └─ SKILL.md
├─ commands/                   # 用户显式发起的能力
│  └─ crules-init.md           # （update-memory.md / review-review.md 已迁出）
├─ CLAUDE.md / agents/ / memory/ / 进阶/ / 项目附录.md   # 规则文档（不变，crules-init cp 它们）
└─ docs/ ...
```

三分法从"部署位置"改为"触发形态"：

| 能力 | 形态 | 触发 | 解决的问题 |
|---|---|---|---|
| `crules-init` | **command** | 显式（`disable-model-invocation: true`） | 解 P2（不主动推销） |
| `update-memory` | **skill** | 模型主动 | 索引同步，适时触发 |
| `review-review` | **skill** | 模型主动（description 限定） | 复审（A 选项隔离消费项目） |

---

## 三、三个能力的 frontmatter（修正 P1/P2 + A）

### 1. crules-init（command，解 P2）

```yaml
---
description: Install or merge the crules rule package into the current project. Detects new vs existing project; installs fresh (gated defaults) or triages conflicts and merges without silent overwrite. Run only when explicitly requested by the user.
disable-model-invocation: true
---
```

- `disable-model-invocation: true`（实测验证有效）= 模型不主动触发，只用户敲 → **解 P2 误推销**
- 正文：迁移自现 `commands/crules-init.md`，但步骤 0「定位源」改为**从 plugin cache 读**（见第六节，解 v15 CRULES_HOME）

### 2. update-memory（skill，修 P1）

```yaml
---
name: update-memory
description: Trigger a full refresh of the project's .claude/memory/ code index — rescans source against the NAVIGATION index, updates file lists, prunes stale entries, fixes reuse hints. Use as a fallback when the index is broadly stale (long inactivity or batch refactoring). This is an index-sync tool, NOT for sedimenting rules — business rules/invariants go in business-rules.md/INVARIANTS.md via the normal discipline.
---
```

- description 改回**真实语义「索引同步」**（P1 修正），明确 `NOT for sedimenting rules`
- 正文：迁移自现 `commands/update-memory.md`（原命令自定位「兜底工具」，保留）

### 3. review-review（skill，A 选项）

```yaml
---
name: review-review
description: Use ONLY when the project contains a decision/review tracking document like the crules repo's own docs/评审.md. Dispatches an isolated-context subagent to audit decision soundness, dogfooding consistency, and whether documented discipline actually landed (not just written). Consumer projects without such a tracking doc will not trigger this.
---
```

- **A 选项**：description 写死「仅当项目存在评审追踪文档时」→ 消费项目（无 `评审.md`）Claude 不主动触发
- 代价：消费项目仍占 ~20 tok/session 闲置，但不会误触发；可接受
- 升级路径：若未来消费项目多且闲置困扰，再拆 `crules` / `crules-dev` 两 plugin（B 选项）

---

## 四、plugin.json + marketplace.json（本地 self-hosted）

`.claude-plugin/plugin.json`：
```json
{
  "name": "crules",
  "version": "0.1.0",
  "description": "通用项目规则模板包——CLAUDE.md 协作规则 + agents + memory + skills/commands",
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
      "description": "通用项目规则模板包"
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
2. 建 `skills/update-memory/SKILL.md`、`skills/review-review/SKILL.md`（迁移自 commands/，按第三节 frontmatter）
3. `commands/crules-init.md` 加 `disable-model-invocation: true`（解 P2）；步骤 0 改"从 plugin cache 读源"
4. 删 `commands/update-memory.md` + `commands/review-review.md`（已迁 skills/）；crules-init 留 commands/
5. `marketplace add ~/Downloads/ai-code/crules` + `install crules@crules-market`（user scope）
6. 新会话验证：
   - `claude plugin details crules@crules-market` 组件清单 = 2 skill + 1 command
   - 新会话能见 `crules:update-memory` / `crules:review-review` skill
   - crules-init command 的 slash 调用形态（`/crules-init` 还是 `/crules:crules-init`）**待确认**
7. 交叉引用同步（约 6 处）：crules/README.md、记忆库体系.md、memory/README.md、MAINTENANCE.md、crules-init 自身、review-review 自身——把「命令 / cp 到 commands/」改「skill / plugin」
8. crules-init 正文 step 2a/2b 调整：消费项目通过 `/plugin install crules` 已装能力，crules-init 只负责 cp/合并**规则文档**（CLAUDE.md/agents/memory/进阶/项目附录）到项目根

---

## 八、风险与未验证（诚实标注）

| 项 | 状态 |
|---|---|
| plugin 命名空间 + skill 发现 + command/skill 并存 + disable-model-invocation | ✅ v22 实测通过 |
| `claude plugin update` 同步链路 | ⚠️ 未实测，落地验证 |
| crules-init 从 plugin cache 定位源（解 CRULES_HOME） | ⚠️ 设计推断，cache 版本路径定位待验证 |
| command 的 slash 调用形态（带不带 `crules:` 前缀） | ⚠️ 未实测，落地确认 |
| review-review A 选项在真实消费项目不误触发 | ⚠️ 待消费项目出现后观察 |
| skill 主动触发可靠性（description 写得好才恰当触发） | ⚠️ 长期观察 + 迭代 description 措辞 |

---

## 九、一句话

plugin 化不是"用 plugin 替代 skill"，是"把 crules 的能力装进 plugin 容器"——换得 `crules:` 命名空间根治撞名、一键装/卸、`disable-model-invocation` 解 P2、cache 定位解 CRULES_HOME；本地路径源 + user scope 满足纯本地不共享。代价是 review-review 闲置（A 选项 description 隔离，~20 tok 可接受）。
