# 迁移 PhET Density 到 KartosLab Flutter（req-density）

> 当前在做什么的快速视图。细节在源码地图各文件。

## 1. 总目标

基于本地 PhET Density + `density-buoyancy-common` 源码，把 Intro / Compare / Mystery 三屏迁为 Flutter 原生行为等价实现。

## 2. 里程碑

| 里程碑 | 完成标志 | 状态 |
|---|---|---|
| M0：源码登记与地图 | `source-map.md` 等 9 份分析文档 | in_progress（本轮交付） |
| M1：需求简述 + AC | `spec/需求简述.md` | in_progress（本轮交付） |
| M2：State + Material + Solver | 纯 Dart 单测绿 | pending |
| M3：Intro 可视 | One/Two Blocks + 材料联动可操作 | pending |
| M4：Compare | Same Mass/Volume/Density | pending |
| M5：Mystery + Density Table | Set 1/2/3/Random | pending |
| M6：拖拽/浮力/布局/无障碍 | Pad 横屏 + Semantics | pending |
| M7：测试 + analyze | flutter test / analyze | pending |
| M8：Close | reviewer → closer → KM | pending |

## 3. 本轮目标

Phase 1 Intake：只读源码、建立事实模型、停。不写 Flutter 业务代码。

## 4. 关键决策点

- [x] 事实源 = density 薄壳入口 + density-buoyancy-common（已 clone）
- [x] 代码目录用 `lib/density/`，不用 prompt 候选 `lib/src/simlab/`（本工程无 SimLab）
- [x] 接入用 `HomeScreen` Navigator.push，不用 `/simlab/:simId`
- [ ] 3D/PBR 纹理：提取 jpg.ts base64 作贴图，还是简化为程序着色？推荐提取原纹理
- [ ] p2.js：不嵌入 JS；用 Dart 2D Solver 行为等价（重力/浮力/接触/粘滞/指针约束）
- [ ] Windows `ExcludeSemantics`（`lib/main.dart`）是否为本需求解开？推荐本 sim 屏自己提供 Semantics，不改全局除非用户拍板

## 5. 关联资源

- 本地 density：`phet sourses/density-main/density-main`
- 本地 common：`phet sourses/density-buoyancy-common-main`
- 官方页：https://phet.colorado.edu/sims/html/density/latest/density_all.html
- 类似迁移：`requirements/req-my-solar-system/`
