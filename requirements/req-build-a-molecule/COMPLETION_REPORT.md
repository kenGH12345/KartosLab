# COMPLETION_REPORT · Build a Molecule

## 摘要

已将本地 PhET **build-a-molecule `1.1.0-dev.2`**（SHA `9f605a7f…`）迁入 KartosLab：完整分子/结构数据集、图同构匹配、Kit 成键门控、Collection、**正确拼成后的 cue+黑盒闪烁反馈**、三屏与 Home 入口；3D 为 Canvas 投影（不引入全局 WebGL 框架）。

## 状态总表

| 维度 | 状态 |
|---|---|
| 源码版本锁定 | `[已确认]` 不以 latest 替换 |
| 分子数据 | `[数据一致]` |
| 结构匹配 / 允许搭建 | `[源码一致]` |
| Collection 规则 | `[源码一致]` |
| **Correct-match 反馈** | `[源码一致]` KitCollection → cue / acceptedMoleculeCreation；blink 1.3s@100ms |
| 成键交互 | `[行为一致]` |
| 3D | `[有意差异：Canvas 非 WebGL]` |
| 视觉精细对齐 | `[视觉近似]`（布局）+ 反馈链路 `[行为一致]` + runtime 截图 `[待确认]` |
| 测试 | **25 passed**（含 `bam_collection_feedback_test`） |
| analyze | 仅元素符号 `info`（刻意保留 H/O/… 名） |
| 独立 Game | 源码无 → 未实现 |

## 正确反馈链路（源码）

```
Kit.addMolecule
 → KitCollection (triggerCue)
 → box.willAllowMoleculeDrop (isEquivalent + capacity)
 → cueVisible = true
 → !hasBlinkedOnce → acceptedMoleculeCreationEmitter
 → CollectionBoxNode.blink (1.3s, 100ms toggle, blue border)
```

Flutter：`BamKit` → `BamKitCollection` → `BamBoxFeedbackState` → `BamCollectionFeedbackDriver` → `BamYourMoleculesPanel`。

## 入口

Home → **化学** → **分子搭建** → **搭建分子**  
Tabs：Single Molecule / Multiple Molecules / Free Build

## 代码落点

`lib/chemistry/build_a_molecule/`  
`assets/data/build_a_molecule/`  
`assets/images/build_a_molecule/`  
`test/chemistry/build_a_molecule/`  
`requirements/req-build-a-molecule/`

## 未改

其他已完成 simulation；common API；全局 Theme；Navigation 架构。

## 后续可选（非阻塞）

1. Ball-and-Stick 3D 模式  
2. 原版悬停剪刀游标  
3. SphereBucket 堆叠几何  
4. 收集完成音效  
5. 本机 runtime 截图 A–E → Phase 10 overlay 精修  

## 暂停条件

均未触发（3D 未引入新全局 framework）。
