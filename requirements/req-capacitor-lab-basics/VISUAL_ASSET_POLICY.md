# 原版 Assets 与视觉一致性 —— 强制规则

本项目对视觉还原的最高要求是：

> **Flutter 页面必须尽可能与原 PhET 页面保持一致。**

这里的“一致”不仅指布局大致相同，还包括：

* 原版图片 / 图标 / 贴图 / 装饰 / 按钮视觉
* 原版电池 / 电容器 / 导线等组件
* 原版 panel / 阴影 / 渐变 / 边框 / 文字
* 原版粒子 / 测量工具 / 交互反馈

配套产物：`ASSET_MAP.md`  
Cursor / Codebuddy 摘要规则：`.cursor/rules/85-phet-original-assets.mdc`、`.codebuddy/rules/85-phet-original-assets.mdc`

---

## 1. 原项目图片必须优先使用

在本地 PhET 源码中完整扫描 `assets/`、`images/`、`mipmaps/` 以及所有 `.png` / `.svg` / `.jpg` / `.webp` / `.gif` 等资源，建立 `ASSET_MAP.md`，至少记录：

`Original Asset` · `Original Path` · `Used By` · `Flutter Path` · `Scale` · `Rotation` · `Crop` · `Opacity` · `Transform`

---

## 2. Asset 使用优先级

```
原 PhET Asset
        ↓
原 PhET SVG / PNG / Mipmap
        ↓
原 PhET Scenery geometry
        ↓
根据 Scenery 源码用 Flutter Canvas 重建
        ↓
最后才允许自行绘制
```

- 原项目有图片 → **必须优先使用原图片**
- 原项目没有图片，但源码使用 Path / Shape / Node 绘制 → 才用 CustomPainter / Canvas / Path 等价重建

---

## 3. 严禁使用替代素材

禁止：Material Icons、Cupertino Icons、Emoji、网络图片、第三方图片、AI 生成图片、随手画的替代图标、「差不多」的电池/电容器/按钮。

尤其禁止：`Icons.battery_std` / `Icons.add` / `Icons.close` / `Icons.refresh` 冒充 PhET 原版图形。

---

## 4. 不能因为 Flutter 方便而替换原图

PhET 使用 `battery.png` / `capacitor.png` / `probe.png` 等时，Flutter 用 `Image.asset(...)` 优先复用。  
不要因为「Canvas 更方便」就重画；SVG 不要先转成「看起来类似」的 Flutter Icon。

---

## 5. Scenery Node 必须区分「图片」和「程序绘制」

分析时必须确认 Node 子树：`Image` / `Path` / `Rectangle` / `Circle` / `Line` / `Text` / Composite。  
不能看到 `new Node(...)` 就默认自行绘制；必须继续追踪子节点，Flutter 尽可能保持同一视觉层级。

---

## 6–8. 尺寸、透明区、Anchor

- 禁止非等比拉伸 / 压缩 / 错误裁剪（除非源码有对应 transform）
- 禁止擅自 `crop transparent padding`（除非源码明确裁剪）
- 必须对齐 PhET origin / center / topLeft / bottomCenter / localBounds → Flutter transform  
- 不能把 Flutter 图片左上角直接当成 PhET Node origin

---

## 9. 图片与动态绘制必须组合

原版若是「原始图片 + 动态 Path + 文字 + 阴影」，Flutter 应保持：`Image` + `CustomPainter` + `Text`，不能只保留其中一个。

---

## 10. Capacitor Lab 特别检查对象

capacitor · battery · plates · wires · dielectric · voltmeter · electric field · charge · measurement tools · buttons · control elements · background graphics  

每个对象状态：`[已确认：原图]` / `[已确认：源码绘制]` / `[已确认：复合对象]` / `[待确认]`

---

## 11–13. Visual QA / 禁止截图替代 / Diff 顺序

Visual QA 除位置大小外，还必须比较：Asset 是否相同、是否被拉伸/裁剪、旋转、anchor、透明区。

禁止：原版截图 → crop → 当作 Flutter asset（除非该文件本身是官方原始 asset）。

Diff 顺序：Asset → 加载 → 尺寸 → anchor → transform → Layer → Painter → Text → Color/Gradient → Micro geometry。  
不要一看到位置不对就改 `left`/`top`。

---

## 14–16. 目标标准与 Final QA

目标链路：原版 PhET → 原版 assets → 源码真实 geometry → Flutter 等价实现 → 截图对比 → 逐项修正。  
禁止：截图 → 猜 → 自己画 → 差不多。

Final 报告必须输出：

```
Assets:
Original Assets Reused: XX
Original SVG Reused: XX
Original PNG Reused: XX
Original Mipmap Reused: XX
Canvas Reconstructed: XX
Custom Assets: XX
Substituted Assets: XX   # 原则上必须为 0
```

若 Substituted ≠ 0，逐项说明：Asset / Reason / Original Source Evidence / Why Direct Reuse Was Impossible / Flutter Replacement / Visual Impact。

视觉完成必须进一步说明：

`[原版资源一致]` `[布局已对齐]` `[动态绘制已对齐]` `[字体已对齐]` `[交互反馈已对齐]` `[动画已对齐]` `[存在近似项]` `[存在有意差异]`

禁止只写 `Visual: PASS`。

---

## 最终原则

> **优先复用原 PhET 图片，而不是重新绘制。**  
> **优先复用原 PhET SVG，而不是使用 Flutter Icon。**  
> **只有原项目本身使用 Scenery geometry 动态绘制时，才用 Canvas / Path 做等价重建。**  
> **不能为了代码方便牺牲视觉一致性。**

目标：**换了运行平台，但用户看到的仍然尽可能是原来的 PhET Simulation。**
