# 需求简述 · Density

> req-id: `req-density` · SOP: agile-vibe · EDD 模板: v2.0  
> 本文件定义**做什么 / 做到什么程度**。行号与公式见同目录源码地图。

## 背景与目标

将 PhET **Density**（HTML5/TypeScript，本地薄壳 `1.3.0-dev.0` + `density-buoyancy-common` HEAD `0c835c6`）迁入 KartosLab Flutter。学生通过改材料/质量/体积、比较四块、辨认神秘块，建立 ρ = m/V 与沉浮关系。

优先级：功能正确 > 物理关系 > 交互 > 状态 > 布局 > 视觉一致 > 额外美化。

**WHY**：补齐力学组「密度与浮力」实验（现有 forces 不含密度）。

来源：S1 用户主任务 Prompt；S2 本地 density 仓库；S3 已 clone 的 density-buoyancy-common；S4 项目知识库 MVC/L0/NineGrid。

## 范围

### 做

- Flutter 原生三屏：**Intro / Compare / Mystery**
- Home：物理 → 新增分组「密度与浮力」→ Density 卡片（不改其它 sim）
- Intro：6 种具名材料 + Custom；One/Two Blocks；A/B 独立材料；密度数轴
- Compare：Same Mass / Volume / Density；四块约束与默认 cubesData
- Mystery：Set 1/2/3/Random + Refresh；Density Table；台秤
- 水池沉浮（水 ρ=1000，g=9.8）；拖拽经世界坐标
- Reset All 按各屏源码
- 体积单位 L（Preferences 可切 dm³，数值等同）
- NineGrid + Pad 横屏；Model / Solver / View 分离
- GPL 署名 + Adapted from PhET + CC0 纹理声明

### 不做

- WebView / iframe / HTML / JS runtime / p2.js / THREE.js 运行时
- Buoyancy 专有：换液、力矢量、船/瓶/鸭、重力行星、% submerged
- 改其它 simulation、主主题、学生系统、网络服务
- 自制缺失的 joist 抓放 mp3
- 完整 PhET-iO / 动态 locale / Projector

## 验收标准

| ID | 标准 | 证据 |
|---|---|---|
| AC-F1 | Home → Density → 三屏可进、返回、再进；切屏状态不串 | S2 `density-main.ts` |
| AC-F2 | Intro 默认 ONE_BLOCK；A=Wood 2 kg @ (-0.2,0.2) V=0.005；B 隐藏 Al 13.5 kg V=0.005 | S3 `DensityIntroModel.ts` |
| AC-F3 | 具名材料改 mass → volume 变、ρ 不变；改 volume → mass 变；选材料 → ρ 换、mass 重算 | S3 `MaterialMassVolumeControlNode.ts` |
| AC-F4 | Custom 改 mass 或 volume → ρ=m/V；Intro Custom 质量上限 10 kg；体积 1–10 L | S3 Intro view `maxCustomMass:10` |
| AC-F5 | Two Blocks 显示 B 且可不同材料；无 total density | S3 `modeProperty` 只改 B 可见 |
| AC-F6 | Compare 默认 Same Mass 5 kg；四块体积 0.01/0.005/0.0025/0.00125 | S3 `DensityCompareModel.ts` |
| AC-F7 | Same Volume 默认 0.005 m³；质量 8/6/4/2 | S3 cubesData |
| AC-F8 | Same Density 默认 500；体积 0.006/0.004/0.002/0.001；范围 100–2000 | S3 |
| AC-F9 | Mystery Set1 五块体积/密度与源码表一致（含 Gold 19320、Diamond 3510） | S3 `DensityMysteryModel.ts` |
| AC-F10 | Set2 含 density 11340（不要改成 11342）；Set3 含 950/1000/400/7800/950 | S3 |
| AC-F11 | Random 5 块；体积来自 1–6 L 抽 3 + 7–10 L 抽 2；密度来自 13 种表；Refresh 重生成 | S3 |
| AC-F12 | Density Table 手风琴默认折叠；13 行按 ρ 升序；kg/L 2 位 | S3 `DensityTableNode.ts` |
| AC-F13 | 拖拽改位置不改 V；ρ_block<1000 浮、>1000 沉 | S3 Mass.startDrag + model.md |
| AC-F14 | Reset 按各屏；Mystery Reset 重 roll Random | S3 |
| AC-F15 | Painter/Widget 不直接改核心状态；Solver 纯函数 | S4 |
| AC-F16 | `flutter analyze` 对本 sim 0 issues；单元+Widget 测试覆盖 AC-F2–F12 | — |
| AC-F17 | 1024×768 / 1280×800 / 1366×1024 / 840×520 无溢出；NineGrid 中格≥70% | S4 80-checklist §七 |
| AC-F18 | 无 iframe/WebView；资源在 `assets/density/`（或用户确认的 simlab 路径） | S1 |
| AC-F19 | About/NOTICE：Adapted from PhET · GPL-3.0 · CC0 纹理 | S2 LICENSE |

## 约束与假设

- 代码落点 `lib/density/`，入口改 `lib/screens/home_screen.dart` 最小接线。
- `[待确认]` Windows `ExcludeSemantics` 是否在本需求解开。
- `[待确认]` 贴图用提取的 jpg，或第一期纯色+第二期贴图。推荐一期就提取 col 贴图。
- `[基于假设]` 抓放音一期可静默。
