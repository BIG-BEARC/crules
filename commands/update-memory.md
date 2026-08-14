---
description: 触发 .claude/memory/ 全量刷新（对比源码现状，增量更新所有索引）
disable-model-invocation: true
---

# /update-memory

触发 `.claude/memory/` 全量刷新。适用于：长时间未维护、或批量重构后索引大面积失效时，做一次兜底扫描。

## 执行步骤

1. 读 `.claude/memory/NAVIGATION.md`，获取全部索引文件清单
2. 扫描源码目录，与各 `indexes/*.md` 现状对比
3. 对每个索引：
   - 新建 / 重命名 / 删除的源文件 → 更新「文件清单」表
   - 过期条目（源文件已删但索引仍记）→ 删除
   - 复用提示失效 → 修正
4. 本轮若有影响多模块的未记录决策 → 补 `decisions/YYYY-MM-DD-<slug>.md`
5. 更新各索引的「最后更新」日期
6. 输出本次更新摘要（改了哪些索引、增删多少条目）

## 依据

- 完整维护规则：`进阶/记忆库体系.md`
- 运行时触发规则：`.claude/memory/MAINTENANCE.md`

## 注意

- `/update-memory` 是**兜底**，不替代「写代码时顺手更新索引」（后者是最高优先级）。
- 全量刷新不等于重写：仍遵守「只记是什么/在哪里，不记完整 API、不复制代码」。
