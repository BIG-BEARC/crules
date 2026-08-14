# Agent 角色

> 本目录是启用 [Agent 编排](../进阶/Agent编排.md) 时的**配套资源**。不使用多 agent 协作的项目不需要本目录。
> 角色分工、调度、主控复核责任的完整规则见 [`../进阶/Agent编排.md`](../进阶/Agent编排.md)；本目录每个文件只定义单个角色的边界。

---

## 角色速查

> 主控 = 主对话本身（不在本目录，无独立文件；职责见 [`../进阶/Agent编排.md`](../进阶/Agent编排.md)）。本目录只列**通用**可派发角色；Flutter 专属角色（frontend / backend / i18n / platform）在 [`../../flutter/agents/`](../../flutter/agents/)。

| Agent | 职责一句话 | 任务难度 |
|---|---|---|
| [`error.md`](error.md) | 运行时错误、崩溃、编译异常排查（频繁 reset） | 中 |
| [`reviewer.md`](reviewer.md) | 代码 Review、质量检查、安全审计（实施**后**） | 高 |
| [`plan-reviewer.md`](plan-reviewer.md) | 方案评审（实施**前**，独立第三方，只读） | 中 |

> 模型档位按「任务难度」选型，不写死——难度越高用越强模型。具体选型由调用方决定。

---

## 怎么启用

```bash
# 复制本目录到项目的 .claude/agents/（Claude Code 自动发现）
cp -r agents/  <你的项目>/.claude/agents/
```

各 agent 文件会被 Claude Code 作为可派发的 subagent 类型加载。

## 约定

- 每个 agent 的**提交流程**统一见项目根 [`../CLAUDE.md`](../CLAUDE.md) §2（不在各文件重复）
- `reviewer` 的**审查方法论与 Checklist**见 [`../进阶/审查与复核纪律.md`](../进阶/审查与复核纪律.md)（权威正文）
- `plan-reviewer` 的**评审闭环与纪律**见 [`../进阶/方案评审闭环.md`](../进阶/方案评审闭环.md)（权威正文）
- 角色边界冲突（如 frontend vs backend）的判定见 [`../进阶/Agent编排.md`](../进阶/Agent编排.md)「主责判定」
