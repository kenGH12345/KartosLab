# FUNCTIONAL_GAP_CLOSURE · Build a Molecule

| 功能 | 状态 | 说明 |
|---|---|---|
| 三 Screen 顺序 Single/Multiple/Playground | `[源码一致]` | Tab 文案：Single Molecule / Multiple Molecules / Free Build |
| 页面级布局 | `[视觉已对齐]` | Column(Row(viewport\|panel), inventory)；比例见 GEOMETRY_CALIBRATION |
| Atom Inventory | `[行为一致]` | 箭头 / 桶 / 元素名 / count / page dots（Model 驱动） |
| Your Molecules cards | `[行为一致]` | 公式+名 + 黑盒 Canvas 缩略图 + 3D；Collection N |
| **Correct-match 反馈** | `[源码一致]` / `[行为一致]` | KitCollection：cue + 首次 blink；指向 isEquivalent 对应 box |
| Cue 箭头 | `[行为一致]` | 蓝箭头在黑盒左侧（ArrowNode）；非 index 猜测 |
| 黑盒边框闪烁 | `[源码一致]` | 1.3s / 100ms / 13 ticks；蓝边 `BORDER_BLINK`；FeedbackState→Driver→View |
| 黑盒 Preview | `[源码一致]` | 黑底容器；有收集物时 Thumbnail Canvas（非纯黑代替 3D 节点） |
| Molecule Workspace | `[行为一致]` | 独立 viewport；拖放成键；浮动名/3D |
| Collection 缩略图 | `[源码一致]` | Molecule3DNode 路径 → BamMoleculeThumbnail Canvas |
| 分子数据集迁移 | `[数据一致]` | collection 26 / other 9329 / structures 29882 |
| isEquivalent 图同构 | `[源码一致]` | 移植 MoleculeStructure |
| isAllowedStructure | `[源码一致]` | structures 加载后；未加载时回退 isValid（仅测试） |
| CollectionBox drop / capacity | `[源码一致]` | isEquivalent + capacity |
| Next Collection 随机生成 | `[行为一致]` | generateKitCollection + Random |
| Lewis 四向成键 + 距离阈值 | `[行为一致]` | Kit.attemptToBond |
| Refill / Reset | `[行为一致]` | |
| 名称 / 公式显示 | `[行为一致]` | catalog match + strings；Single=`collectionSinglePattern`，Multiple=`Goal`/`You have` |
| Next Collection 文案 | `[源码一致]` | `nextCollection` / `yourMolecules` 来自 strings |
| 3D Dialog | `[有意差异]` | Canvas 投影，非 WebGL THREE |
| Ball-and-Stick 模式切换 | `[待实现]` | 目前 Space-fill |
| 剪刀断键游标交互 | `[视觉近似]` | 长按/右键断键 + scissors 资产按钮；非原版悬停剪刀 |
| Bucket 球体堆叠几何 | `[有意差异]` | chip UI + 简化布局 |
| 收集拖入命中区域 | `[有意差异]` | 窄栏点选收集为主 |
| vegas 正确音效 | `[待实现]` | 静默 |
| 独立 Game 关卡 | N/A | 源码无 |
| Home 入口 | `[行为一致]` | 化学 → 分子搭建 → 搭建分子 |
| 其他 sim 未改 | `[源码一致]` | 仅 home 增卡 |

## 边界覆盖（测试）

| 项 | 覆盖 |
|---|---|
| known water match | bam_structure_test |
| invalid / not equivalent | bam_structure_test |
| collection accept/reject/capacity | bam_collection_test |
| correct-match cue / blink / reset / once | bam_collection_feedback_test |
| bond allow gate | bam_kit_bond_test |
| reset first collection | bam_reset_test |
| home nav tabs | bam_home_nav_test |
| catalog counts | bam_catalog_test |
