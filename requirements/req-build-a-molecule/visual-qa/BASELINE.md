# Visual Baseline · Build a Molecule

> Phase 2  
> 参考图：`visual-qa/ref/`（来自本地 PhET `assets/` 宣传截图）  
> **[待确认：缺少本机原版 runtime 截图]** — 不得伪造。布局锚点以源码常量 + ref 图为准。

---

## Screens（默认态）

| Screen | Ref 文件 | 观察（从宣传图） | 源码锚点 | 标记 |
|---|---|---|---|---|
| Single | `build-a-molecule-screenshot-screen1.png` | 左/中 play；底 kit carousel；右 collection boxes | `MoleculeCollectingScreenView` | `[已确认]` 图存在 |
| Multiple | `…-screen2.png` | 类似；boxes 显示数量目标 | MultipleModel capacity | `[已确认]` |
| Playground | `…-screen3.png` | 无右侧 collection；更多元素 kit | `CollectionLayout(false)` | `[已确认]` |

通用背景色 play：`rgb(198,226,246)`（`BAMConstants.PLAY_AREA_BACKGROUND_COLOR`）`[已确认]`。

---

## 区域划分（源码语义）

| 区域 | 内容 | 布局 | 标记 |
|---|---|---|---|
| Kit Play Area | 拖原子/分子、断键剪刀 | 主区域 | `[已确认]` doc |
| Kit Panel | buckets + carousel + refill | 底部 | `[已确认]` |
| Collection Panel | boxes + next/prev collection | 右侧（Single/Multiple） | `[已确认]` |
| 3D Dialog | 全屏黑底对话框 | 模态 | `[已确认]` |

Flutter NineGrid：中格 = Play；底 footer = Kit；右 = Collection（Playground 右格空或折叠）。

---

## 重要交互态（源码驱动）

| 状态 | 预期 | 标记 |
|---|---|---|
| 默认空 | buckets 满；play 空；boxes 空黑盒 | `[已确认]` 模型 |
| A. 正确拼成前 | 无 cue；黑盒灰边；无 blink | `[行为一致]` |
| B. 正确拼成瞬间 | `willAllowMoleculeDrop`（isEquivalent）→ cue + 首次 `acceptedMoleculeCreation` | `[源码一致]` KitCollection |
| C. feedback 指向目标 | 蓝色 Arrow cue 在**匹配** box 黑盒左侧（非 list index） | `[源码一致]` / `[行为一致]` |
| D. 黑色 target preview 闪烁 | 黑盒边框蓝/灰交替；1.3s、100ms、13 ticks；色=`MOLECULE_COLLECTION_BOX_BORDER_BLINK` | `[源码一致]` CollectionBoxNode.blink |
| E. 完成后最终状态 | blink 结束恢复灰边（满箱黄边）；cue 在可 drop 期间保持 | `[行为一致]` |
| 错误结构 | 不触发 cue / blink | `[源码一致]` |
| 同 Collection 再拼对 | cue 可再显；blink **仅一次**（hasBlinkedOnce） | `[源码一致]` |
| reset() | 清 cue/blink + hasBlinkedOnce=false | `[源码一致]` |
| resetKitsAndBoxes | 清 cue/blink；**保留** hasBlinkedOnce | `[源码一致]` |
| Box 满箱 | 黄边；cue 关闭 | `[源码一致]` |
| 黑色 Preview 区域 | Rectangle 黑底容器；quantity>0 时 Molecule3DNode/Canvas 缩略图；非装饰黑块 | `[源码一致]` / `[视觉已对齐]` |
| All filled | Dialog + Next Collection | `[已确认]` |
| 3D 打开 | 名称 + formula + 旋转 | `[已确认]` |
| WebGL 失败 | WarningDialog | `[已确认]` 源码；Flutter `[有意差异]` |

### Visual QA 截图状态清单（正确反馈）

| ID | 状态 | 截图 | 标记 |
|---|---|---|---|
| A | 正确拼成前 | `[待确认：缺 runtime 截图]` | 逻辑 `[行为一致]` |
| B | 正确拼成瞬间 | `[待确认：缺 runtime 截图]` | `[源码一致]` 触发 |
| C | feedback 指向目标 | `[待确认：缺 runtime 截图]` | `[行为一致]` |
| D | 黑盒边框闪烁 | `[待确认：缺 runtime 截图]` | timing `[源码一致]`；像素 `[待确认]` |
| E | blink 结束后 | `[待确认：缺 runtime 截图]` | `[行为一致]` |

> **禁止**把缺失的正确反馈标成「视觉近似」。反馈链路已接好；runtime 像素对齐仍待本机截图。

---

## 字体 / 颜色 / 资源

| 项 | 值 | 标记 |
|---|---|---|
| Collection 背景 | `rgb(238,238,238)` | `[已确认]` |
| Kit 背景 | white / black border | `[已确认]` |
| 剪刀 | `images/scissors*.png` | `[已确认]` — 需复制到 assets |
| 分子图标 | 几何绘制，非 PNG 库 | `[已确认]` |

---

## Calibration 备注

Phase 10 将用：Source layout → normalized coords → overlay diff。  
禁止 screenshot tracing 硬编码像素。
