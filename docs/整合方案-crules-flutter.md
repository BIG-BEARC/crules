# crules-flutter 独立整合方案（待评审）

> **状态**：方案已完成，**待需求方评审批准后执行**——本文档不含任何已执行改动。
> **决策链**：组合使用复杂度（漏装风险/mount 讨论）→ 需求方拍板 **fork 式整合**（flutter 包吸收 crules 通用层、独立演进、互不同步）→ 架构定版**种子库模式**（crules = 通用层母版 + fork 起点；crules-java 延后，需要时再建）。
> **评审要点**：§三整合映射（范围圈定）、§四批次、§六风险落实。批准后按批放行。

---

## 一、背景与目标

Flutter 工程当前需组合 crules（通用协作层）+ flutter 包（技术栈层）两套，存在三个真实痛点：

1. **安装通道不同步**——crules 经 plugin 分发（cache 只含 crules 仓库快照），flutter 是仓库外文件包；向导提示是软的，漏装技术栈层后**静默降级无告警**
2. 组合维护两套心智（引用拓扑 / 条件式引用 / 孪生同步义务）
3. flutter/app 模板内嵌的 crules §一红线孪生（AUTO-SYNC 注释）**已漂移至 v49 前**——实证双份必漂移

**目标**：flutter 包吸收 crules v74 通用协作层，重组为独立的 `crules-flutter` plugin；此后与 crules 各自演进、互不依赖（唯一例外：deny-list 安全修复以 crules 为单一权威，fork 背单文件同步义务）。

**架构定版（种子库模式）**：

```text
crules（母版，保持活跃）──fork──► crules-flutter（独立演进）
              │                        ▲ deny-list 安全修复单向同步
              └──fork──► crules-java（延后，需要时再建）
边界判据：与具体技术栈无关的协作改进 → 在 crules 改，各 fork 自行决定 cherry-pick；
         技术栈相关 → 只进对应 fork
```

## 二、范围

**包含**：批 1-4（flutter 建仓与 plugin 骨架、内容整合、saas_pos 上移接入瘦身、crules 侧定位声明与 fork-kit 沉淀）。

**不包含**：
- crules-java（需求方 08-26 裁定延后：需要时按 fork-kit 照单执行 + 届时的 Java 项目约定做 Ground Truth）
- crules 通用层任何改动（母体零改动是本方案的安全属性，仅批 4 加声明）
- saas_pos 业务逻辑改动（只动规则文件与知识归位）

## 三、整合映射（文件级）

| flutter 包目标 | 来源与处理 |
|---|---|
| `app/CLAUDE.md`（重组主体） | §一协作红线 / §二提交策略（含 commit=本地·push=推送语义分离）/ §四验证证据（含 v65 长输出裁剪）← crules 对应节**全量**（红线节从过期孪生升级为本尊）；§三双 Gate ← 裁剪版（任务分类保留、工具降级表简化为 plugin 场景措辞）；§五完成定义 + §六后台 agent diff ← crules；**§七技术栈约定** ← 现有必填三选一（保留交互）；**§八 Flutter 专项规范** ← 新建（saas_pos 上移：Riverpod 规范——Notifier 模式 / Provider 组织表 / ConsumerWidget 强制；主子工程 assets package 加载；文件头注释格式；Import 排序）；尾部并入简化版附录字段（3 必填） |
| `plugin/CLAUDE.md` | 同构重组，plugin/工具库场景裁剪 |
| `rules.md`（777 行） | **保留不动**——Dart/Flutter 技术最佳实践，独立价值，与协作层正交 |
| `checklist.md` | 扩充：crules 审查纪律通用 8 类**合并自带**（独立后不能引用 `../crules`）+ 现有 Flutter 专项 |
| `进阶/`（新目录，5 篇 fork） | 审查与复核纪律 / 工程化流程 / Agent编排 / 方案评审闭环 / 记忆库体系——按 Flutter 语境裁剪（去 spec-kit 映射、触发词移动端形状改 Java/Flutter 中性）；**不搬**插件工作流（改为模板内 superpowers + dart-flutter 映射节）；术语表裁 Flutter 相关子集。实证依据：saas_pos 三期五篇全用上（358 次实现调用 + 评审链 + 索引），非纸面能力 |
| `agents/`（7 角色） | 通用 3（error 只诊断形态 / reviewer / plan-reviewer 物理只读）+ Flutter 4（frontend / backend / i18n / platform） |
| `hooks/` + fixture | **复制** deny-list.py / pending-updates.py / test_deny_list.py；README 声明同步义务（见 §六 🔴1） |
| `scripts/` + `.claude-plugin/` + `.github/` | 抄 crules 成熟件改造：install.sh（lite/full + 版本戳 + 老项目护栏）/ check-imports.sh / release.sh（含 draft）/ test-self.sh / ci.yml（四步）——v31 bump 必 update、v48 CI 首跑红等坑直接继承 |
| `memory/` | 模板复制（含 v61 后 git 分层头注、v69 twin 锚点） |
| `README.md` | 新写：安装（两条命令 + git URL）/ 环境要求与更新信任 / 停用与恢复 / 与 crules 的关系声明（fork 自 v74、独立演进、deny-list 同步义务）/ 维护节（边界判据） |

## 四、实施批次（逐批放行，每批完成即停、验证、汇报、等确认）

| 批 | 内容 | 量级 | 交付物 |
|---|---|---|---|
| **1** | flutter 目录 `git init` + 首提交（现状入版本控制）；`crules-flutter` plugin 骨架（双 json + README 完整版）；本地 marketplace 可装 | 半小时 | 可安装的空壳 plugin（内容未动） |
| **2** | **内容整合主体**：两模板重组 + checklist 扩充 + 进阶 5 篇裁剪 fork + agents 合并 + hooks/scripts 复制改造 + **覆盖 diff 验收**（对 crules v74 逐节核对无意外遗漏）+ crules 侧沉淀 `docs/fork-kit.md`（整合映射清单化——crules-java 那天照单执行） | 大战役，2-3 会话 | 自洽的 crules-flutter 0.1.0 |
| **3** | saas_pos：上移 Riverpod 规范等 → 接入 crules-flutter → CLAUDE.md 瘦身（546 → 约 200 行；业务架构/购物车算价下沉 `.claude/memory/`，CLAUDE.md 留指针） | 一个会话 | saas_pos 新会话加载验证 + token 对比 |
| **4** | crules 侧收尾：README 一行种子库定位声明 + 评审.md 记账 + CHANGELOG | 半小时 | crules v75 |

## 五、验证设计

- **每批**：flutter 仓自建简化一致性检查（悬空链接/版本一致）+ test-self 断言（红绿双向）+ plugin install 后 `release.sh verify-cache` 特征串验证
- **批 2 终验（验收门）**：`覆盖 diff`——crules v74 的 CLAUDE.md 各节 + 进阶各篇逐项核对在 crules-flutter 中「已整合 / 裁剪（留痕理由） / 不适用（留痕理由）」三态标记，防"整合了但悄悄丢了三节"；diff 结果落 `docs/fork-coverage.md`
- **批 3 终验**：saas_pos 新会话实际加载（`@` 导入可达 / hooks 生效 / 常驻 token 对比口径）

## 六、风险与回退

| # | 风险 | 落实 |
|---|---|---|
| 🔴1 | **安全补丁断供**（deny-list 是对抗性资产，crules 红队修复到不了 fork） | fork README 写死：「deny-list.py 与 test_deny_list.py 变更必须从 crules 同步」——断供面缩至单文件单类变更 |
| 🔴2 | **单向门**（fork 后差异累积，合回基本要重写） | 决策已需求方确认接受；crules 母体零改动 = 放弃窗口在批 2 完成前始终存在，之后弃 flutter 分支即可归位 |
| 🟡3 | 双线维护税 | flutter 不复制治理体系（五维雷达/评审轮次/元账本不搬），只留 README + CHANGELOG + 最简检查——治理成本延后到真有痛感再付 |
| 🟡4 | 边界判断成本 | 判据入 README 维护节（§一图）；每次通用改进在 crules 改完后多一个「fork 跟不跟」决策，接受 |
| 🟢5 | 基建翻倍 | 全抄 crules 成熟件（坑已踩） |
| 🟢6 | 验证偏斜（规则滑向 saas_pos 特有） | 保留定期外审选项（crules 的独立 subagent 复审模式可复用） |

**回退**：批 1 后回退 = 删 git 仓库；批 2 后 = 弃整合分支保 flutter 现状（批 1 已先入版本控制，现状有底）；crules 全程无损。

## 七、已裁决记录

| 决策 | 结论 |
|---|---|
| fork vs 引用/同步 | **fork 独立演进**（需求方两次确认） |
| 种子库架构 | crules = 母版 + fork 起点，保持活跃 |
| crules-java | **延后**（08-26 需求方裁定，需要时按 fork-kit 执行） |
| hooks 归属 | **带走**（fork 自持硬闸） |
| 进阶篇数 | **5 篇全搬**（saas_pos 实证全用上） |
| 命名 | `crules-flutter`（plugin 名与仓库名统一） |
| mount 命令 | **不做**（YAGNI：fork 模式下无多包挂载需求） |

## 八、执行前提

- GitHub 远端：批 1 可先本地建仓，远端 URL 由需求方随后提供（或私有仓自行创建后告知）
- saas_pos 批 3 前保持工作树干净（合并纪律）
- 全程不自动 commit——每批完成等指令
