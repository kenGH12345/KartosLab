# 项目级 vs 需求级 知识分类标准

> 本文件用于辅助 `managing-knowledge` Skill 判断一条候选发现是「项目级」（应回写到 context/）还是「需求级」（留在 notes.md）。

## 核心判断公式

> **下个不相关的需求会用到这条知识吗？**
>
> - 是 → 项目级，回写
> - 否 → 需求级，留在 notes.md
> - 不确定 → 默认按需求级（更安全；下次再用到时升级到项目级）

## 项目级（应回写）类型清单

| 类型 | 示例 | 推荐回写位置 |
|---|---|---|
| 模块职责 | "X 模块负责 Y，对外暴露 Z 接口" | `context/project/<project>/services/<service>/README.md` |
| 接口契约 | API 字段、错误码、版本约定 | `context/project/<project>/api/<service>.md` |
| 架构模式 | "本项目用 Hexagonal Architecture" | `context/project/<project>/architecture/INDEX.md` |
| 业务流程 | 关键流程的端到端时序 | `context/project/<project>/flows/<flow>.md` |
| 配置项 | "X 配置在 Y 文件，影响 Z" | `context/project/<project>/config.md` |
| 通用约定 | 命名、错误处理、日志格式、Git workflow | `context/project/<project>/conventions/<topic>.md` |
| 已验证的踩坑 | "这种场景下要注意 X，否则会 Y" | `context/project/<project>/experience/<topic>.md` |
| 数据模型 | 表结构、字段含义、关键索引 | `context/project/<project>/data-model/<topic>.md` |
| 依赖关系 | "服务 A 依赖服务 B 的 X 接口" | `context/project/<project>/dependencies.md` |
| 性能基线 | "首屏 < 2s / API p99 < 200ms" | `context/project/<project>/performance.md` |

## 需求级（留 notes.md）类型清单

| 类型 | 示例 | 为什么不回写 |
|---|---|---|
| 本需求特有的变通 | "这次因为 X，临时把 Y 写死成 Z" | 下次相关需求要重新评估 |
| 强绑定的边界 | "本需求场景下，A 字段只可能是 1 或 2" | 仅本场景成立 |
| 临时 workaround | "等 X 修复后这段可以删除" | 临时性，不应固化 |
| 已撤销的尝试 | "原本想用 A 方案，实测后改用 B" | 撤销的方案不进知识库 |
| 个人偏好 / 调试痕迹 | "我喜欢用 Y 工具调试" | 不属于团队约定 |
| 未验证的猜测 | "我怀疑 X 可能影响 Y" | 未验证不入库 |

## 边界场景

### "看起来像项目级但其实是需求级"

| 表面特征 | 真实属性 | 判断依据 |
|---|---|---|
| 涉及多个模块 | 仍可能是需求级 | 是否解决"全局问题" |
| 写得很正式 | 仍可能是需求级 | 看是否对未来有指导价值 |
| 用了"本项目"措辞 | 仍可能是需求级 | 措辞 ≠ 适用性 |

### "看起来像需求级但其实是项目级"

| 表面特征 | 真实属性 | 判断依据 |
|---|---|---|
| 写得很口语 | 可能是项目级 | 看内容本质 |
| 来自单个 commit | 可能是项目级 | 看是否是首次发现 + 普适 |
| 出现在 notes 末尾 | 可能是项目级 | 看是否被多个需求引用 |

## 升级机制

需求级知识在以下情况可升级为项目级：

- 同一条踩坑在多个需求中重复出现（≥ 2 次）→ 升级
- 用户在 review 中明确说"这应该写到项目知识库"→ 升级
- knowledge-maintainer 在定期维护中识别到模式 → 提交"升级建议"

升级方式：在新一次 `managing-knowledge` 调用时把这条作为 candidate 传入。

## 默认偏保守

> 不确定时**默认按需求级**——这样错只是"知识没及时进库"，下次再补；
> 反向错误是"无关紧要的内容污染了知识库"，长期会让知识库失去可信度。
