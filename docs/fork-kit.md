# fork-kit · 技术栈 fork 操作手册

> **快照性质声明**：本手册沉淀自 crules-flutter fork 实践（批 1-4，2026-08-27），锚定基线 `v74-fork-base`（ea4d25c）。**crules 此后演进不自动更新本清单**——新技术栈（如 crules-java）fork 时**必须重跑覆盖 diff**（对当时最新基线 tag），禁照单直抄。
> 配套：完整实战方案与覆盖 diff 见 crules-flutter 仓 `docs/fork-coverage.md`；批 2c 双坑复盘见该仓 `docs/复盘-2026-08-27-批2c双坑.md`。

## 一、前提决策（fork 前想清楚）

1. **架构定位**：crules = 通用层母版 + fork 起点（保持活跃）；各 fork 独立演进、互不依赖
2. **唯一例外**：deny-list 安全修复以 **crules 为单一权威**——fork 背单文件同步义务，用 **CI 同步比对步**机械化（README 软约束已被 AUTO-SYNC 漂移实证证伪）
3. **单向门确认**：fork 后差异累积，合回基本要重写——需求方显式接受
4. **边界判据**：与具体技术栈无关的协作改进 → 在 crules 改，fork 按查表决定跟随（安全修复必跟 / 规则演进默认不跟 / 跟则 bump fork minor）；技术栈相关 → 只进对应 fork

## 二、批次结构（每批独立验证放行）

| 批 | 内容 | 量级参考 |
|---|---|---|
| 1 | 建仓（git init + GitHub）+ plugin 骨架（双 json + README 完整版）+ **crules 侧打基线 tag**（`v<NN>-fork-base`——覆盖 diff / fork-kit / README 三处统一锚定） | 半小时 |
| 2a | **模板层**：两 CLAUDE.md 重组（通用层本尊化）+ **覆盖 diff 紧跟其后** | 一个会话 |
| 2b | **知识层**：checklist 自持（通用 8 类合并）+ 进阶 fork（链接重定位）+ agents/memory 落位 + rules skill 化 | 一个会话 |
| 2c | **基建层**：hooks 复制 + SYNCED-FROM 戳 + CI 同步比对 + scripts 四件 + 残留排查 | 一个会话 |
| 3a | 消费工程上移（逐条**适用面判定**）+ 接入验证（plugin details + 消费侧新会话实测） | 半小时-一会话 |
| 3b | **新规则稳定运行后**再瘦身（消费工程 CLAUDE.md 减负，业务域知识下沉记忆库，资损规则留硬指针） | 半小时 |
| 4 | crules 侧收尾：种子库声明 + fork-kit 更新 + 记账 | 半小时 |

## 三、整合映射模板（根 CLAUDE.md 逐节三态）

| 基线节 | 默认去向 |
|---|---|
| §一红线（含安全两条）/ §五完成定义 / §六后台 diff | **全量**进 fork 根模板（红线节若旧模板有孪生，从孪生升级为本尊） |
| §二提交策略 | 全量（保留 commit=本地 / push=推送语义分离 + skill 冲突降级 + hook 边界注） |
| §三双 Gate | 主干全量；深度纪律（二手摘要 / 事实锚定 / 新建先查 / 语义来源链 / 信任档位 / 工具降级）可裁至进阶工程化流程篇「补遗节」（效力等同根规则，覆盖 diff 记归位） |
| §四验证证据 | 主干全量 + 场景实例替换（验证命令换技术栈实际命令；证据 5 级的目标环境行按技术栈重映射）；「接口真实响应 / 构建≠规范合规」归审查篇 |
| §七扩展入口 | 裁剪版（附录并入模板尾部） |
| 技术栈节 | 各 fork 自建【复制后必填】交互节（多预设 + 自定义模板——**预设相关规范挂对应预设块下**，选其他预设不生效） |

## 四、基建件清单（crules 成熟件直抄 + 改名）

- hooks 三件 + fixture（+`SYNCED-FROM: crules@<基线hash>` 戳）+ hooks.json
- CI 四步：fixture / py_compile / test-self / **deny-list 同步比对**（拉 crules 主分支两文件 diff 剥戳比对，不一致 exit 1）
- scripts：install（`--<kind>` 选模板 + 版本戳 `<!-- <fork名>: v… -->` + 老项目护栏 `v[0-9]`）/ check-imports（戳巡检）/ release（**cache 路径改 fork 自己的 market/plugin 名**——实测残留高发点）/ test-self（含 deny-list 幂等断言）
- skill 目录：**plugin 根级 `skills/`**（不是 `.claude/skills/`——项目级约定，放错不挂载，消费侧首验抓过）
- 残留排查收尾：`grep -rn "crules" scripts/ .github/ | grep -v <合法引用>` 逐条清

## 五、验收门与实战坑

- **覆盖 diff**（批 2a 交付 + 批 2b 归位核对 + 批 3a 适用面判定追加）：三态表「已整合 / 裁剪·留痕 / 不适用·留痕」，无静默丢失
- **消费侧首验必须做**（批 3a）：`claude plugin details` 看 Skills/Agents/Hooks 计数 + 消费工程目录 `claude -p` 实测可见性
- **跨仓操作一律绝对路径**（crules §三纪律）：Bash cwd 会话间重置——批 2c 曾 5 文件误写母版；含破坏命令字面串的测试文件用 Write 工具落盘（Bash heredoc 触发 deny-list 误拦）
- fork-kit 本身是快照：新 fork 重跑覆盖 diff，勿直抄本清单的映射结论
