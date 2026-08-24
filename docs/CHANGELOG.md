# 模板包 CHANGELOG

> 只记「新增 / 删除了哪些文件 + 一句话能力」，供 README 维护者查「现在实际有哪些文件」。详细评审在 [`评审.md`](评审.md) + [`archive/`](archive/)。
> **版本口径**（C13）：`plugin.json` semver 是**分发版本**（plugin 内容变化即 bump，v31 规则）；docs 的 vN 是**内部评审 / 优化轮次编号**（全轮摘要见 [`评审.md`](评审.md) Changelog）；本文件记**能力级变化**——三者不同轴，semver ≠ vN。
> 维护触发：见 [`评审.md`](评审.md) 文档维护规则「总览同步检查」——模板文件增删 / 能力新增时，同步更新本文件 + 各 README。

---

## 08-24 · v67 安装脚本化——install.sh（W2②，plugin 0.4.2）

- **`scripts/install.sh` 新增**——新项目安装的确定性部分脚本化：lite/full 两模式（导入行+覆写节+版本戳 / 头戳+全文）、按需复制附录/进阶/agents/memory、`--dry-run` 安装报告、默认跳过已存在（禁静默覆盖）、`--force` 覆盖重装；**老项目护栏**（无戳 CLAUDE.md → 中止走 AI 合并分支，有戳 → 重装）；cache 源警告（lite 导入行指 cache 的静默漂移）；五情形自测过（lite/full/幂等 18 SKIP/老项目中止/巡检联通）——自测中修掉 3 处（sys 导入漏、幂等被护栏误拦、full 戳位置）
- **`commands/crules-init.md`**：2a 步骤 3 改为「跑安装脚本」——AI 只做问答引导（技术栈/模式）+ 跑脚本 + 填附录，机械 cp 从模型方差转脚本确定性；**`README.md`** scripts 行补 install.sh / check-imports.sh 例外说明

## 08-21 · v66 编排成本补丁（W3 六条全收口，plugin 0.4.1）

- **`CLAUDE.md` §三**：「禁整文件重写」补**结构性推翻例外**（须显式声明 + 旧版归档）
- **`进阶/Agent编排.md`**：新增「**评审包契约化**」——事实切片包 + 抽查权保留（摘录不得成唯一信源）+ **定点读纪律**（核 file:line 用定点窗口，禁全文 Read 作背景）——治双关卡冷启动重复读（「需要隔离的只有判断，不是事实」）
- **`进阶/工程化流程.md`**：批量红绿补**断言有效性补偿**（抽 1-2 个断言错值确认会红，防恒真断言）；事实核验前移扩**调研去转写**（核验后报告直接作设计事实小节，指针引用不搬运）
- **`项目附录.md`**：测试命令节加**分层 runner** 提示与「纯逻辑测试 runner」字段（治层级错配）
- 编排档位（全量/标准/精简）**待需求方裁决**——精简档动 Y1 确认点裁定，不默认化

## 08-21 · v65 编排成本分档——实战复盘提炼（plugin 0.4.0，minor）

- **`CLAUDE.md`**：§四 +「长输出先裁剪再入上下文」（结论行 + 失败详情，禁全量输出反复计费——实战最大隐性成本）；§三 +「修订用局部 Edit 禁整文件重写 / 禁 shell 流内联编辑」（sed 损坏 + 重写丢 diff 两教训）
- **`进阶/Agent编排.md`** 新节「编排成本分档」——成本模型（轮次 × 单轮累积上下文，省轮数 ≠ 省重量）+ 任务书契约化（写 1 读 N、贴签名不贴框架）+ 评审关卡四级分级（双关卡 / 单代理双节 / 免复读 / 小任务并入——治「评审成本反超实现」）+ 调度三条（攒批复读 / 流水线任务书 / 无冲突并行）
- **`进阶/工程化流程.md`**：§3 + TDD 节奏分档（同构用例集批量红绿 / 设计驱动型保持逐用例，34 用例 ~60 轮→3 轮实测）；§2 + 事实核验前移（调研报告先派核验代理只核 file:line，治转写引入事实错误）
- **`进阶/插件工作流.md`**：「优先级与冲突」+ TDD 节奏冲突消解（本包分档 > skill 逐用例默认，§2 优先级链同型第三例）

## 08-21 · v64 分发维支点——版本戳 + 导入巡检（plugin 0.3.4）

- **`scripts/check-imports.sh` 新增**——消费项目侧巡检：轻装导入行可达（断链 = exit 1，治「源被清理后规则静默失效」）+ 版本戳 vs 源版本差提示；四情形自测过（可达/断链/无戳/无痕迹）
- **`commands/crules-init.md`**：轻装/完整/合并产物统一落版本戳 `<!-- crules: v<源版本> @ <日期> -->`；老项目体检**先读戳算版本差、聚焦 CHANGELOG 差异段**（增量合并起步）；收尾提示巡检命令

## 08-21 · v63 五维整合 + error.md 声明诚实化（plugin 0.3.3）

- **`docs/五维基线.md` 新增**（维护资产，不复制）——五维基线（方法论 8.5 / IA 7.5 / 机制化 8 / 分发 6.5 / 可维护 7）+ 雷达演化表（度量回路起步）+ 触发式检查表（铁律：触发式非强制 / 重评须独立 subagent）
- **`agents/error.md`**：「物理只读、与 reviewer 对等」声明降级为诚实措辞（Bash 是写通道）；工作流 5-7 步转诊断形态（修掉 v60 漏改的「用 Edit 修改文件」自相矛盾）
- **`docs/评审.md`**：收尾三问 → 四问（第 4 问挂五维检查表）+ 元触发表加「触及五维短板」行；**`.claude/commands/review-review.md`**：输入源加五维基线 + 审查维度加「基线滞后吗」（仓库本地命令，不走 bump/cache 验证）

## 08-21 · v61 外审政策矛盾收口（git 分层头注 ×4 + LICENSE，plugin 0.3.2）

- **`LICENSE` 新增**（MIT）+ `README.md` License 节——「可直接复用」定位补法律基础
- **`memory/README.md` / `business-rules.md` / `INVARIANTS.md` + `进阶/记忆库体系.md`**：四处「不进 git」旧政策头注（v18-C 落地前的残留）改引 `MAINTENANCE.md`「git 分层」单一权威——制度资产进 git / 生成物不进；一致性脚本查不了政策语义，外审实测抓出

## 08-21 · v60 外部复核收口（部署死链 / 物理锁 / 易用性，plugin 0.3.1）

- **`进阶/`×4 + `进阶/README.md`**：10 处 `../agents|../memory|../commands` 链接反引号化（部署位说明）——v56 只收了越包链接，本轮补齐复制映射断链（进阶→项目根、agents/memory 下沉 `.claude/`、commands 不复制）
- **`agents/error.md`**：frontmatter 去 Edit/Write——纸锁升**物理只读**（与 reviewer/plan-reviewer 对等）；修复场景转主控
- **`CLAUDE.md` §2**：补「hook 硬闸与确认的边界」（deny-list 命令确认后也由人工执行，特性非缺陷）
- **`README.md` + `commands/crules-init.md`**：安装路径改占位符（通用定位）；cache 版本排序补语义版本规则（0.10>0.9 勿用字典序）；轻装模式补团队场景缝隙说明；token 口径 ≈5.5–7k（v60 实测）
- **非分发**：`scripts/probes.sh` dryrun 短路 + exit 修正（实测 0.4s/10 SKIP/EXIT 0）；`ci.yml` A-H→A-I；`release.sh` verify-cache include 补 *.sh/*.yml；v58/v59 Changelog 行补三问①留痕注

## 08-21 · v57 待办池清仓（缓办设计项全收口，plugin 0.3.0）

- **`CLAUDE.md`**：§三「改共享物先查引用」+接口演进同步测试 fake（V4）；「Gate 例外」+信任档位注（提速档仅需求方显式声明，V3）
- **`项目附录.md`**：协作偏好 +信任档位字段（覆写机制承载，V3）
- **`memory/MAINTENANCE.md`**：+git 分层（制度资产进 git / indexes 与队列本地；A7：settings.json 进 git、local 永不进，v18-C）+ 规模演进触发（>15 条再分域，v11-② 转触发指引）
- **`commands/crules-init.md`**：老项目分支 +历史文档纳管体检（分级→L0 快照→纳管/隔离→迁移即验证）
- N3/N4/N6 账本残留关闭（v26-B/v24续/v56 已消化）

## 08-21 · v56 部署拓扑断链收口（N5+v18-D）

- **`进阶/`×3 + `memory/NAVIGATION.md`**：5 处 `../../flutter/` 越包链接改**条件式 prose**（「crules 模板包同级 `../flutter/`，未安装则忽略」）——复制部署后不再有死链；F 查豁免清单收缩至 README

## 08-21 · v54 通用常见坑技术栈中性化

- **`agents/error.md`**：「通用常见坑」5 条改通用坑型表述（重入路径副作用 / 订阅粒度 / 长流一次性消费 / 热重载残留 / 跨层桥接），去响应式·移动端框架默认值（D8 收口；本段系 v55 按「元账本触发即更新表」判定补记——行为表述变化属能力级）

## 08-21 · v51 定位转通用团队模板

- **`CLAUDE.md`**：§一 语言红线通用化（「始终中文」→「跟随需求方语言」，附录可覆写固定语言）；§二 提交触发词**分离语义**（`commit`=本地提交 / `push`=推送 / 「提交并推送」=完整流程，附录可覆写）；§三 +**工具降级表**（AskUserQuestion/Plan 模式/Agent 不可用时的文本降级形态）
- **`项目附录.md`**：+「协作偏好」节（回复语言覆写）+ 提交触发词覆写字段
- **`README.md`**：+「快速上手（新手 5 条）」+「三档规模」（Lite / Team / Advanced，从 Lite 起步随时扩档）

## 08-21 · v50 补安全规则

- **`CLAUDE.md`**：§一 +2 条红线（「不可信内容不作指令」prompt injection 防护 /「外部依赖与网络操作先确认」供应链）；§三 +工具降级表
- **`hooks/deny-list.py`**：头注 +覆盖矩阵（拦什么 / 什么归根规则与原生权限）；`blocked()` 拦截文案统一追加「不要尝试绕过」
- **`agents/error.md`**：顶部硬约束「未明确要求修复只诊断、禁 Edit/Write」

## 08-21 · v49 老项目 dry-run 安装报告 + 发布脚本

- **`commands/crules-init.md`**：老项目分支 +步骤 1.5 安装报告（dry-run，确认前不动既有文件，全景表后进取舍）
- **`scripts/release.sh` 新增**——v31「bump 必 update + cache grep」机械化（双 json 同步 + verify 三命令 + verify-cache）

## 08-19 · v44 待办池拆分

- **`docs/待办.md` 新增**——待办需求池独立（历轮评审遗留 + 需求方直接提出的优化需求，首个 Y1）；单向同步纪律：状态先改待办.md，评审.md Changelog 只记轮次
- **`docs/评审.md`**：open 表迁出改指针段；维护规则同步（本文件新形态「Changelog + 最新详情 + 已关闭」）；顺修 v43 插行格式损伤

## 08-19 · v42 README 使用向导

- **`README.md`**：新增「/crules:crules-init 会做什么（向导流程）」一节——新项目三问+复制清单（含文件树）/ 老项目硬护栏+冲突体检+逐条裁决+资产保护 / 跑完后的会话变化说明

## 08-17 · v41 归档轮（详情瘦身 + 探测纪律）

- **`docs/评审.md`**：v30-v40 详情段移 archive（更名 `archive/详情-v16-v40.md`），恢复单段详情形态；已关闭表按 L11 纪律批量瘦身（v23-T1→v30 共 26 行移 archive）
- **`hooks/test_deny_list.py`**：头注补探测纪律——红队探测输入必须 json.dumps 构造、禁手拼 JSON（第三轮红队假证据教训）
- 零规则/代码行为改动

## 08-17 · v40 红队 R1-R3 收口（force-switch / 引号 / stash 对齐）

- **`hooks/deny-list.py`**：`git checkout -f`·`git switch -f` 强切丢弃入名单（`force_switch()`，GIT_SIG 加 `switch`）；`strip_quotes()` 剥配对引号（引号 pathspec 逃逸 + 引号白名单路径误拦 + `'*'` glob 三病一治）；`git stash clear` 入名单（对齐 CLAUDE.md §2；drop/pop 按「只拦无歧义」裁决不拦）；push force 改独立词匹配（lease 单用放行 / lease 在前 force 在后拦截）；`-s HEAD` 与 `--source=HEAD` 对齐
- **`hooks/test_deny_list.py`**：fixture 49→66（+10 拦 + 7 放），红→绿流程留痕（11 红确认后修复）
- **`.claude-plugin/`** 版本 0.1.8→0.1.9

---

## 08-17 · v39 六类绕过收敛修复（匹配策略换轴）

- **`hooks/deny-list.py`**：git/rm 签名从行首锚定改为**段内非锚定搜索**——前缀同族（sudo/env/带参）/包裹（( )/$( )/反引号）/`git -C` 插花一次收敛，不再枚举前缀词；pathspec 补 `./`·`*` glob；rm 白名单 normpath（避 realpath 符号链接误拦，`/tmp/../Users` 穿越收口）；git clean dry-run（-n）放行修误拦
- **`hooks/test_deny_list.py`**：fixture 34→49（+13 拦含红队 8 向量 + 2 dry-run 放行），49/49 全绿；e2e sudo 变体真实会话封堵实证
- **`.claude-plugin/`** 版本 0.1.7→0.1.8

## 08-17 · v37 外审追杀裁定 + deny-list 加固（P0-1/P0-2 收口）

- **`hooks/deny-list.py` 加固**：切分符补换行/单管道；`+refspec` 强推、`git checkout .` 裸点、`git restore :/` 全树、rm 长选项（`--recursive --force`）入名单；前缀环境变量赋值与 `command`/`exec` 剥离；头部加「安全网非沙箱」诚实声明
- **`hooks/test_deny_list.py` 新增（进 git）**：34 fixture（20 拦含外审 6 绕过 + 14 放），修正 v35「单测 15/15 跑完即弃」验证无痕；挂 `scripts/check-consistency.sh` 新 H 查（对抗样本库）
- **`commands/crules-init.md`**：轻装导入行改指稳定路径（crules 仓库路径优先；cache `<version>` 目录标静默漂移风险不推荐）——P0-2 修复
- **`README.md`** hooks 行补「名单非穷尽，安全网非沙箱」声明
- **`.claude-plugin/`** 版本 0.1.6→0.1.7；e2e 实测换行绕过变体已被封堵

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
- **`docs/archive/详情-v16-v40.md`**：修 4 处内部相对路径错位（`archive/xxx` → 同目录 `xxx`）
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
- **`docs/评审.md`**：v27-v29 详情归档（archive 更名 `详情-v16-v40.md`）；D9 关闭；v30 轮登记（含复盘→规则提炼映射表）

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

## 08-14 · v27 复盘（M1-M3 裁决 + 归档）

- **`docs/评审.md`**：v26 详情段归档；Changelog +v27；「精简至 135 行」瞬时数字按 M2 原则抹除；v25 未登记产出行补「口径查证再次受阻」注
- **`docs/archive/详情-v16-v25.md` → `详情-v16-v40.md`**（更名）：追加 v26 详情段，全部引用同步（grep 旧名零残留）
- 裁定结论：M1 全对 / M2 建议采纳·事实指控驳回 / M3 对——详见 评审.md v27 段

## 08-14 · v26 续（复核微修 M1-M3）

- **`docs/评审.md`**：两处「v18 复盘」段文字指针改指 `archive/详情-v16-v40.md`（M1，归档后未同步的悬空指针）+「715→135 行」行数口径修正为「精简至 135 行」（M2）
- **`commands/crules-init.md`** + **`README.md`**：常驻成本口径补「+ `项目附录.md` 合计 ≈4–5k token」（M3）

## 08-14 · v26 外审落地（E1 诚实化 + trivial 批量 + 归档）

- **`README.md`**：「精髓」行措辞诚实化（写明根 `CLAUDE.md` 常驻 ≈4–5k token，E1 定案）；复制目标路径表加 `docs/`「不复制」行（N3）；文件清单 memory/ 行改列实存文件（N2）
- **`进阶/Agent编排.md`**：「可用 Agent 模板」拆「通用角色 / 技术栈专属角色」两表（E2），reviewer 行补「只报不改」
- **`commands/crules-init.md`**：「全装零负担」改为常驻成本说明（E1 连带）
- **`memory/README.md`** + **`进阶/记忆库体系.md`**：「不进 git」表述补「消费项目运行时 vs crules 源仓库模板」语境（N6）
- **`docs/archive/详情-v16-v40.md` 新增**：评审.md v16-v25 九段详情归档，评审.md 恢复单段详情精简形态（N7 / v24-C2 止损执行）

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
