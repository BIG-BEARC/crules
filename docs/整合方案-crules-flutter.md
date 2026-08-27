# crules-flutter 独立整合方案（待评审）

> **状态**：首轮独立评审（§九）已逐条裁定吸收（2026-08-27，裁定含两处技术修正），正文已按条修订——**待需求方最终批准后执行**。本文档不含任何已执行改动。
> **决策链**：组合使用复杂度（漏装风险/mount 讨论）→ 需求方拍板 **fork 式整合**（flutter 包吸收 crules 通用层、独立演进、互不同步）→ 架构定版**种子库模式**（crules = 通用层母版 + fork 起点；crules-java 延后，需要时再建）。
> **评审要点**：§三整合映射（范围圈定）、§四批次、§六风险落实。批准后按批放行。
> **首轮独立评审**：2026-08-26 完成——6 修订 + 4 增强 + 2 小瑕疵，**2026-08-27 全部裁定采纳**（D/F 两处技术依据修正，见 §九裁定表），正文已按条吸收。

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
| `app/CLAUDE.md`（重组主体） | §一协作红线 / §二提交策略（含 commit=本地·push=推送语义分离）/ §四验证证据（含 v65 长输出裁剪）← crules 对应节**全量**（红线节从过期孪生升级为本尊）；§三双 Gate ← 裁剪版（任务分类保留、工具降级表简化为 plugin 场景措辞）；§五完成定义 + §六后台 agent diff ← crules；**§七技术栈约定** ← 现有必填三选一（保留交互）；**§八 Flutter 专项规范** ← 新建，拆两小节：**全栈通用**（主子工程 assets package 加载 / 文件头注释 / Import 排序——任何预设都生效）+ **预设 A（Riverpod）特有**（Notifier 模式 / Provider 组织表 / ConsumerWidget 强制——标「选 A 时生效」，选 B/C 不适用）；批 3 上移时每条做**适用面判定**并记入 fork-coverage；尾部并入简化版附录字段（3 必填） |
| `plugin/CLAUDE.md` | 同构重组，plugin/工具库场景裁剪 |
| `rules.md`（777 行） | **skill 化**（非常驻——description 写清触发场景，777 行常驻是显著 token 税）+ **dart-flutter 去重审计**（一次性清理：与官方 skill 重叠部分删掉留指针 `见 dart-flutter:<skill>`，只留 skills 不覆盖的实战经验——静态参考非同步孪生，无持续义务） |
| `checklist.md` | 扩充：crules 审查纪律通用 8 类**合并自带**（独立后不能引用 `../crules`）+ 现有 Flutter 专项 |
| `进阶/`（新目录，5 篇 fork） | 审查与复核纪律 / 工程化流程 / Agent编排 / 方案评审闭环 / 记忆库体系——按 Flutter 语境裁剪（去 spec-kit 映射、触发词移动端形状改技术栈中性——与 Java 无关）；**不搬**插件工作流（改为模板内 superpowers + dart-flutter 映射节）；术语表裁 Flutter 相关子集。实证依据：saas_pos 三期五篇全用上（358 次实现调用 + 评审链 + 索引），非纸面能力 |
| `agents/`（7 角色） | 通用 3（error 只诊断形态 / reviewer / plan-reviewer 物理只读）+ Flutter 4（frontend / backend / i18n / platform） |
| `hooks/` + fixture | **复制** deny-list.py / pending-updates.py / test_deny_list.py；文件头加 `# SYNCED-FROM: crules@<hash>` 戳，**CI 加同步比对步**（拉 crules 主分支两文件 diff，不一致 exit 1——同步义务机械化，见 §六 🔴1）；README 声明降为辅助说明 |
| `scripts/` + `.claude-plugin/` + `.github/` | 抄 crules 成熟件改造：install.sh（lite/full + 版本戳 + 老项目护栏）/ check-imports.sh / release.sh（含 draft）/ test-self.sh / ci.yml（四步）——v31 bump 必 update、v48 CI 首跑红等坑直接继承 |
| `memory/` | 模板复制（含 v61 后 git 分层头注、v69 twin 锚点） |
| `README.md` | 新写：安装（两条命令 + git URL）/ 环境要求与更新信任 / 停用与恢复 / **与 crules 的关系**（fork 自基线 tag、独立演进、deny-list 同步义务、**双 plugin 共存指引**——同一项目二选一；同机器共存时两套 hooks 双跑：deny-list 并集拦截无害、pending-updates 写同一队列文件经 flock 幂等，结论以 test-self 断言背书）/ 维护节（边界判据 + **跟/不跟查表**：安全修复必跟 / 规则演进默认不跟 / 跟则 bump fork minor） |

## 四、实施批次（逐批放行，每批完成即停、验证、汇报、等确认）

| 批 | 内容 | 量级 | 交付物 |
|---|---|---|---|
| **1** | flutter 目录 `git init` + 首提交（现状入版本控制）；`crules-flutter` plugin 骨架（双 json + README 完整版）；本地 marketplace 可装；**crules 侧打 tag `v74-fork-base`**（基线锚点——覆盖 diff / fork-kit / README 声明三处统一锚定该 commit，防跨会话基线漂移） | 半小时 | 可安装的空壳 plugin（内容未动）+ 基线 tag |
| **2a** | **模板层**：两 CLAUDE.md 重组（§八拆全栈通用/预设特有两小节）+ **覆盖 diff 紧跟其后**（对 `v74-fork-base` 逐节核对，三态标记：已整合 / 裁剪·留痕理由 / 不适用·留痕理由） | 一个会话 | 重组后的两模板 + 三态标记表 |
| **2b** | **知识层**（相对机械，2a 三态标记作输入）：checklist 扩充 + 进阶 5 篇裁剪 fork + agents 合并 + rules.md skill 化与 dart-flutter 去重 | 一个会话 | 知识层齐 |
| **2c** | **基建层**：hooks 复制 + `SYNCED-FROM` 戳 + **CI 同步比对步** + scripts 改造（install/check-imports/release/test-self）+ **grep -rn "crules" 残留排查**（防改漏路径致 CI 测错对象）+ fork-kit 沉淀 | 一个会话 | 自洽的 crules-flutter 0.1.0 |
| **3a** | saas_pos：上移（含逐条**适用面判定**入 fork-coverage）+ 接入 crules-flutter + 新会话加载验证 | 半小时-一会话 | saas_pos 双包切换完成 |
| **3b** | **新规则稳定运行后**再瘦身：CLAUDE.md 546 → 约 200 行（业务架构/购物车算价下沉 `.claude/memory/`，**资损敏感规则留硬指针**——「改算价/价格逻辑前必读 memory 对应节」，不全下）+ token 对比 | 半小时 | 瘦身后的 saas_pos |
| **4** | crules 侧收尾：README 种子库定位声明 + 评审.md 记账 + CHANGELOG；fork-kit.md 头部锚定基线 hash + **快照性质声明**（crules 演进后清单不自动更新，crules-java 建仓须重跑覆盖 diff，禁照单直抄） | 半小时 | crules v75 |

## 五、验证设计

- **每批**：flutter 仓自建简化一致性检查（悬空链接/版本一致）+ test-self 断言（红绿双向 + **deny-list 重复调用幂等断言**——双 plugin 共存结论的可测背书）+ plugin install 后 `release.sh verify-cache` 特征串验证
- **批 2a 终验（验收门）**：`覆盖 diff`——对 tag `v74-fork-base` 的 CLAUDE.md 各节 + 进阶各篇逐项核对三态标记（已整合 / 裁剪·留痕 / 不适用·留痕），防"整合了但悄悄丢了三节"；结果落 `docs/fork-coverage.md`（批 3a 的适用面判定追加于此）
- **批 2c 追加**：`grep -rn "crules"` 残留排查清零（改漏的路径/文件名会让 CI 测错对象甚至假绿）
- **批 3a 终验**：saas_pos 新会话实际加载（`@` 导入可达 / hooks 生效）；**批 3b 终验**：token 对比口径 + 资损硬指针就位

## 六、风险与回退

| # | 风险 | 落实 |
|---|---|---|
| 🔴1 | **安全补丁断供**（deny-list 是对抗性资产，crules 红队修复到不了 fork） | **CI 同步比对步机械化**（首轮评审 A 修订：README 软约束与 AUTO-SYNC 同为已被证伪的机制）：crules-flutter CI 拉 crules 主分支 deny-list.py + test_deny_list.py 与本地 diff，不一致 exit 1 + `SYNCED-FROM` 戳——断供面从「维护者自觉」缩到「merge 时想不看见都难」；不抽独立仓（多仓治理成本 + 割断红队喂补丁链路） |
| 🔴2 | **单向门**（fork 后差异累积，合回基本要重写） | 决策已需求方确认接受；crules 母体零改动 = 放弃窗口在批 2 完成前始终存在，之后弃 flutter 分支即可归位 |
| 🟡3 | 双线维护税 | flutter 不复制治理体系（五维雷达/评审轮次/元账本不搬），只留 README + CHANGELOG + 最简检查——治理成本延后到真有痛感再付 |
| 🟡4 | 边界判断成本 | 判据入 README 维护节（§一图）+ **跟/不跟查表**（增强：安全修复必跟 / 规则演进默认不跟 / 跟则 bump fork minor）——把每次开放式判断变查表 |
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
| 首轮评审吸收（08-27） | 6 修订 + 4 增强 + 2 小瑕疵**全部采纳**：A 同步义务 CI 机械化 / B 批 2 拆 2a-2c / C 基线 tag 锚定 / D 共存指引（**修正**：pending-updates 双跑实为同文件 flock 幂等，非双份提醒） / E §八拆全栈通用与预设特有 / F rules.md skill 化 + 一次性去重（**修正**：静态参考非同步孪生，无持续义务）；增强四项（跟不跟查表 / fork-kit 快照声明 / 资损硬指针 / grep 残留排查）；批 3 拆 3a/3b（瘦身在稳定后） |

## 八、执行前提

- GitHub 远端：批 1 可先本地建仓，远端 URL 由需求方随后提供（或私有仓自行创建后告知）
- saas_pos 批 3 前保持工作树干净（合并纪律）
- 全程不自动 commit——每批完成等指令

---

## 九、首轮独立评审意见（2026-08-26 · 已于 08-27 裁定吸收，正文已按条修订）

> 评审视角：资深 Flutter 工程 + 深度 AI coding。总评：方案成熟度高（决策链留痕完整、风险表诚实、批 1 留退路、覆盖 diff 是好机制）；**架构层（fork / 种子库 / §七已裁决项）不推翻**——fork 的技术依据是实的（install.sh 自身已警告 lite 模式 @导入行的 plugin cache 静默版本漂移；AUTO-SYNC 孪生漂移已实证）。以下均只动执行层。**裁定结果（08-27，主控技术裁定 + 需求方确认采纳）**：6 修订 + 4 增强 + 2 小瑕疵全部采纳，两处技术依据修正——
- **D 修正**：pending-updates 双跑写的是当前项目 cwd 下同一队列文件，flock 串行 + 集合去重 = 实际幂等（非「双份提醒」）；deny-list 版本不一致时为并集拦截（任一 block 即 block），保守无害。断言表述改为可测的「脚本自身重复调用幂等」。
- **F 修正**：rules.md 与 dart-flutter 的重叠是**一次性去重清理**（静态参考、单向、无持续同步义务），非「AUTO-SYNC 问题换位重现」——严重度降级，修法不变。
修订已落入 §三/§四/§五/§六/§七 各节，裁定明细见 §七 追加行。

### 修订项（按优先级）

| # | 级 | 问题 | 修订方案 | 影响节 |
|---|---|---|---|---|
| A | 🔴 | **deny-list 落实用的是已被本项目证伪的机制**——「README 写死同步义务」与 AUTO-SYNC 注释同为软约束，却用来对付 🔴1 最高级风险（本方案立论依据正是「AUTO-SYNC 挡不住漂移，漂至 v49 前」） | ci.yml 加同步比对步：拉 crules 主分支 `hooks/deny-list.py` + `test_deny_list.py` 与本地 diff，不一致 exit 1（两仓均在 GitHub，约 20 行）；文件头加 `# SYNCED-FROM: crules@<hash>` 戳。断供面从「维护者自觉」缩到「merge 时想不看见都难」。**不抽独立仓**（多仓治理成本 + 割断 crules 红队喂补丁链路） | §六🔴1、§三 hooks 行、批 2c |
| B | 🔴 | **批 2 粒度过粗**——10+ 类资产跨 2-3 会话，恰是 v65 复盘「单轮累积上下文最大化」形态；覆盖 diff（最需精细核对）压在批末，返工发生在上下文最贵、离起点最远处 | 拆三子批各自可停可验：**2a 模板层**（两 CLAUDE.md 重组 + 覆盖 diff 紧跟其后）/ **2b 知识层**（checklist 扩充 + 进阶 5 篇 + agents 合并，相对机械）/ **2c 基建层**（hooks / scripts / plugin json / CI 复制改造）；2a 产出的三态标记作 2b/2c 输入 | §四批次表 |
| C | 🟡 | **覆盖 diff 基线是移动靶**——「对 v74 核对」中 v74 是版本号非锚点；批 2 跨多会话，期间 crules 任何演进（哪怕顺手修 deny-list）都使基线漂移，fork-kit 沉淀的也是漂移后映射 | 批 1 顺手 `git tag v74-fork-base`；覆盖 diff、`docs/fork-kit.md`、README「fork 自 v74」声明三处统一锚定该 commit hash（一行命令换三处口径一致） | §四批 1/批 2、§五 |
| D | 🟡 | **双 plugin 共存场景零讨论**——plugin 用户级安装，同机器双装（crules 仓 + Flutter 项目）是需求方自身常态而非边角；两套 hooks 同注册：deny-list 双跑幂等无害，pending-updates 双跑 = 双份提醒，两份 deny-list 版本不一致时行为未定义 | README「与 crules 的关系」节加安装互斥指引（同一项目二选一；同机器共存时写明双跑幂等性结论）；「与 crules 同 matcher 下双跑幂等」入 test-self 断言——可验证属性，非文字安慰 | §三 README 行、§五 |
| E | 🟡 | **§八 内容来源与多预设结构冲突**——saas_pos 上移的是 Riverpod 规范，但 §七技术栈 A(Riverpod)/B(Bloc)/C(Provider) 三选一，选 B/C 的项目会拿到不适用的 A 专属强制条款（ConsumerWidget 强制等）；批 3 本身就是 🟢6「规则滑向 saas_pos 特有」的直接入口，「保留定期外审」是事后救济非事前结构 | §八 拆两小节：**全栈通用**（assets package 加载 / 文件头注释 / Import 排序）直接进正文；**预设 A 特有**（Riverpod 细则）挂预设 A 块下标「选 A 时生效」。上移时每条规范做适用面判定，判定记录入 fork-coverage，让偏斜在验收时可见 | §三 §八行、批 3 |
| F | 🟡 | **rules.md「保留不动」缺两个决策**——①挂载方式缺位（常驻 vs skill 按需？777 行常驻是显著 token 成本，按需则触发词未定义）；②与 dart-flutter 官方 skills 内容面高度重叠且权威源关系未定义（冲突时听谁的没定义——与 AUTO-SYNC 漂移同构，问题换位重现） | ①做成单 skill（description 写清触发场景）非常驻；②批 2 加去重审计——与 dart-flutter skill 重叠部分删掉留指针（`见 dart-flutter:<skill>`），只留 skills 不覆盖的实战经验（踩坑 / 清单类）。两项决策显式补进 §三 | §三 rules.md 行 |

### 增强项（合理设计的加强，不阻塞批准）

| 原设计 | 增强 |
|---|---|
| fork 跟/不跟决策税（🟡4 已识别） | README 维护节给**默认查表答案**：安全修复必跟 / 规则演进默认不跟 / 跟则 bump fork minor——把每次开放式判断变查表，降判断税 |
| 种子库 + fork-kit 沉淀 | fork-kit.md 头部锚定基线 hash + 声明**快照性质**：crules 演进后清单不自动更新，crules-java 建仓时须重跑覆盖 diff，禁照单直抄 |
| 批 3 saas_pos 下沉 memory（546→200） | 资损敏感规则不全下：购物车算价在 CLAUDE.md 留硬指针「改算价/价格逻辑前必读 memory/business-rules.md 对应节」——memory 按需触发，资损失守成本 >> 省 token 收益（沿 INVARIANTS.md 哲学：约束丢失按问题类型 gate，与规模无关） |
| scripts/CI 复制成熟件 | 验证补一条：改造后 `grep -rn "crules"` 排查残留引用——改漏的路径/文件名会让 CI 测错对象甚至假绿（v48「本机绿 CI 红」的镜像问题） |

### 小瑕疵

- §三「触发词移动端形状改 **Java**/Flutter 中性」疑笔误（Java 属 crules-java 事），含糊表述批 2 执行易走样，宜改准确
- 批 3 一个会话塞四件事（上移/接入/瘦身/验证）——瘦身宜在新规则稳定运行后做才有意义，备拆分预案：3a 上移+接入验证 / 3b 瘦身+token 对比
