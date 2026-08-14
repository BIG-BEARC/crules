# 模板包 CHANGELOG

> 只记「新增 / 删除了哪些文件 + 一句话能力」，供 README 维护者查「现在实际有哪些文件」。详细评审在 [`评审.md`](评审.md) + [`archive/`](archive/)。
> 维护触发：见 [`评审.md`](评审.md) 文档维护规则「总览同步检查」——模板文件增删 / 能力新增时，同步更新本文件 + 各 README。

---

## 08-14 · v29 执行 v22 plugin 化（能力上线 plugin）

- **`.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json`** 新增——crules plugin（本地路径源，user scope）
- **`commands/crules-init.md`** + **`commands/update-memory.md`**：frontmatter 加 `disable-model-invocation: true`；crules-init 步骤 0 改 plugin cache 定位源（CRULES_HOME 终结）、2a/2b 适配分工（不再 cp commands）
- **`commands/review-review.md` → `.claude/commands/`**（移动）：仓库内部命令不进 plugin（plugin 收录 commands/ 全部 .md）
- **`agents/README.md` 删除**（N9）：plugin 把它收录为伪 agent；链接孤儿，内容已被 Agent编排 / 根 README / 角色卡覆盖
- **`README.md`**：「怎么用」改两条命令（装 plugin + /crules-init）；复制表与文件清单的 commands 行改 plugin 分发说明

## 08-14 · v28 裁决落地（R1 收口 + E4 硬护栏 + E3 + N1）

- **`commands/crules-init.md`**：老项目分支新增步骤 0 硬护栏——git 干净树检查 + 时间戳备份（E4：「禁静默覆盖」从纯 prompt 升级为硬护栏）
- **`进阶/插件工作流.md`**：spec-kit 列标「⚠️ 实验性，未经本包实测」，说明段区分 superpowers（已实测）/ spec-kit（待实测）（E3）
- **`docs/重构方案-v22-plugin.md`**：按 v28 裁决修订——review-review 不进 plugin（留仓库本地）、update-memory 改 command（+`disable-model-invocation`）、plugin 清单旧名改 crules（N1）；R1 收口，v22 主线可执行

## 08-14 · v36 外审裁定落地（脚本 F/G 查 + pending-updates 漂移队列）

- **`scripts/check-consistency.sh`** +两查：F 跨包链接（规范化后越出包根即报，v18-D 5 文件豁免）——治「源仓库通过、分发场景失明」盲区；G 双 json 版本号一致性
- **`hooks/pending-updates.py`** 新增 + **`hooks/hooks.json`** 加 PostToolUse（Edit/Write/NotebookEdit）——记忆库启用项目改源文件自动记 `.claude/memory/.pending-updates` 漂移队列（flock 防并发），「记得更新索引」从记忆问题变成看得见的待办
- **`memory/MAINTENANCE.md`** 自检清单加队列首条；**`进阶/记忆库体系.md`** 维护时机 4 补队列提示
- **`.claude-plugin/`** 版本 0.1.4→0.1.6（0.1.5 首发 + flock 修复）
- 外审图评裁定：P0-2/P1-2/P1-3 采纳落地；P1-1 数字驳回（实测 31 行 / 3967 汉字，README 4-5k 恰准），优先级标注缓议待真实消费驱动

## 08-14 · v35 deny-list hook（首条机制级硬约束，三草案收口）

- **`hooks/hooks.json` + `hooks/deny-list.py`** 新增——PreToolUse 破坏性命令硬闸，随 plugin 分发零配置：拦 `git push --force`（--force-with-lease 放行）/ `push --delete` / `reset --hard` / `clean -f` / `branch -D` / `checkout -- .` / `restore .` / `rm 递归+强制`（/tmp 放行）；零意图判断、deny-by-default（v18-A 撤销边界外窄范围重开）
- 验证：单元 15/15（含复合命令危险段）；端到端 `claude -p` 拦截成功、block 原因正确传导、无害命令不受扰
- **`.claude-plugin/`** 版本 0.1.3→0.1.4；**`README.md`** 文件清单加 hooks/ 行 + 分发注

## 08-14 · v34 slash 形态收口 + 一致性脚本

- **`scripts/check-consistency.sh`** 新增——五查一致性脚本（悬空链接 / 旧名 / README 清单 / 段落级文字指针 / 归档引用，含白名单）；首跑捕获归档文件 4 处内部路径错位（已修），v13续 B2 机械化底座
- **`README.md`**：「怎么用」命令改 `/crules:crules-init`（实测裸名 Unknown command，W4 修正）
- **`docs/archive/详情-v16-v29.md`**：修 4 处内部相对路径错位（`archive/xxx` → 同目录 `xxx`）
- **`docs/重构方案-v22-plugin.md`**：§八 slash 形态行实测收口
- **`.claude-plugin/`** 版本 0.1.2→0.1.3

## 08-14 · v33 E5 定案（双模式默认轻装）

- **`commands/crules-init.md`**：2a 新增安装模式询问——**轻装（默认）**：项目根 CLAUDE.md 仅 `@` 导入 crules 源 + 覆写节（单一权威 / 源更新下次会话自动生效 / 覆写优先）；**完整**：全量 cp（团队多机 / 高定制）。附录/进阶/agents/memory 两模式照常复制；2b 老项目合并亦可产轻装形态（老规则放覆写节）
- **`README.md`**：「怎么用」加轻装说明；复制目标路径表 CLAUDE.md 行拆轻装 / 完整两态
- **`.claude-plugin/` 版本 0.1.1→0.1.2**（dogfood「改内容必 bump」），cache 已 update 验证

## 08-14 · v31 外审补漏（W1-W3 + update 机制修正）

- **`CLAUDE.md` §三**：「改共享物先查引用」补运行时耦合句（引用检索只覆盖静态依赖，布局联动/生命周期/状态重建另列下游影响链）——补提炼复盘一规则 2（W1）
- **`.claude-plugin/` 版本 0.1.0→0.1.1**（W2）：实测发现 `plugin update` 以版本号为键、同版本号不刷新 cache（v29 结论修正：彼时证据实为 details 读源）——**此后每次改 plugin 内容须 bump 版本号**；cache 0.1.1 已含 v30+v31 规则（grep 验证）
- **`commands/crules-init.md`**：步骤 0 补「多版本目录并存，取版本号最大」
- **`进阶/插件工作流.md`**：调试行内置兜底改指 error 角色根因定位方法论（W3）
- **`docs/重构方案-v22-plugin.md`**：§八 update 链路行按 v31 实测修正

## 08-14 · v30 实战复盘提炼（规则合并）

- **`CLAUDE.md`**：§三 实施纪律 +5 条（改共享物先查引用 / 参照物优先 / 二手摘要只用于定位 / 修一坑查同类 / 补丁死结止损）；§四 验证 +2 条（接口数据结构以真实响应为准 / 构建·测试通过≠规范合规盲区自查）——提炼自 `../复盘/` 三份实战复盘（订单模块返工 15+ 次 / 修 bug 连环失败 / 同一违规三次），通用化措辞
- **`agents/error.md`**：新增「根因定位方法论」节（分层探针 / 对照实验分离变量 / 看日志判定 / 补丁死结止损线 / 修一坑查同类）；修 D9（「频繁 reset」原项目语境残留 → 「每次调用视为独立任务」）
- **`docs/评审.md`**：v27-v29 详情归档（archive 更名 `详情-v16-v29.md`）；D9 关闭；v30 轮登记（含复盘→规则提炼映射表）

## 08-14 · v27 复盘（M1-M3 裁定 + 归档）

- **`docs/评审.md`**：v26 详情段归档；Changelog +v27；「精简至 135 行」瞬时数字按 M2 原则抹除；v25 未登记产出行补「口径查证再次受阻」注
- **`docs/archive/详情-v16-v25.md` → `详情-v16-v29.md`**（更名）：追加 v26 详情段，全部引用同步（grep 旧名零残留）
- 裁定结论：M1 全对 / M2 建议采纳·事实指控驳回 / M3 对——详见 评审.md v27 段

## 08-14 · v26 续（复核微修 M1-M3）

- **`docs/评审.md`**：两处「v18 复盘」段文字指针改指 `archive/详情-v16-v29.md`（M1，归档后未同步的悬空指针）+「715→135 行」行数口径修正为「精简至 135 行」（M2）
- **`commands/crules-init.md`** + **`README.md`**：常驻成本口径补「+ `项目附录.md` 合计 ≈4–5k token」（M3）

## 08-14 · v26 外审落地（E1 诚实化 + trivial 批量 + 归档）

- **`README.md`**：「精髓」行措辞诚实化（写明根 `CLAUDE.md` 常驻 ≈4–5k token，E1 定案）；复制目标路径表加 `docs/`「不复制」行（N3）；文件清单 memory/ 行改列实存文件（N2）
- **`进阶/Agent编排.md`**：「可用 Agent 模板」拆「通用角色 / 技术栈专属角色」两表（E2），reviewer 行补「只报不改」
- **`commands/crules-init.md`**：「全装零负担」改为常驻成本说明（E1 连带）
- **`memory/README.md`** + **`进阶/记忆库体系.md`**：「不进 git」表述补「消费项目运行时 vs crules 源仓库模板」语境（N6）
- **`docs/archive/详情-v16-v29.md` 新增**：评审.md v16-v25 九段详情归档，评审.md 恢复单段详情精简形态（N7 / v24-C2 止损执行）

## 08-14 · v25 落地（reviewer 只报不改）

- **`agents/reviewer.md`**：tools 锁 `Read, Glob, Grep`（去 Bash/Edit/Write）+ 纪律首条「只报不改（硬约束）」+ 工作流改「输出清单→主控上报→需求方裁决→主控修复→reviewer 只读复读」（D7 修复，全包唯一审查独立性缺口）
- **`进阶/方案评审闭环.md`** 核心区分表 + **`agents/README.md`** 速查表同步「只报不改」
- （本轮漏记 CHANGELOG，v26-N8 补记）

## 08-13 · v23 外审落地（3 项 trivial）

- **`CLAUDE.md` §四**：证据尺度泛化——「模拟器/真机证据」→「测试环境/目标环境证据」（移动端术语降为括注示例）+ 重映射说明；`进阶/工程化流程.md` §7 交付汇报模板同步
- **`agents/error.md`**：frontmatter 补 `tools: Read, Glob, Grep, Bash, Edit, Write`
- **`docs/archive/重构方案-v20-skills.md`**：v20 方案文档归档（已废弃），7 处引用改 archive/ 路径
- （本轮漏记 CHANGELOG，v26-N8 补记）

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
