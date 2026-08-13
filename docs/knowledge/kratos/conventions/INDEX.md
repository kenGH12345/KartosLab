# conventions 索引

## 文档清单
| 文档 | 说明 | 最近更新 |
|---|---|---|
| [add-draggable-component.md](add-draggable-component.md) | 向拖拽工作区新增元件模板 | 2026-07-17 |
| [add-circuit-component.md](add-circuit-component.md) | 新增电路元件类型（含 Sentinel 陷阱） | 2026-07-17 |
| [add-interaction.md](add-interaction.md) | 新增交互（走闭环、不可变修改） | 2026-07-17 |
| [add-custom-painter.md](add-custom-painter.md) | 新增 Canvas 绘制组件（构造注入 / toScreen / shouldRepaint） | 2026-07-17 |

## 跨引用
- 回写机制: `managing-knowledge` Skill（`convention` 类型候选默认落本目录）
- INDEX 同步: 由 `docs-index-updater` Skill 承担（`.codebuddy/skills/core/docs-index-updater/` 已落地）
- CustomPainter 规范源头: [../frontend/ui-framework.md](../frontend/ui-framework.md) 第三节（已抽取为 add-custom-painter.md）
