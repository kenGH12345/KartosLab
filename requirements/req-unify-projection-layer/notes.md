# Notes — req-unify-projection-layer

## 已确认发现

1. **SceneProjection 存在两处完全相同的定义**（`circuit_canvas.dart:5-9` + `circuit_screen.dart:1156-1172`），违反 DRY；重构时应一次性收敛为一处。

2. **`_hitTestWire` 两份实现逻辑平行但风格略异**（circuit_canvas 版有 threshold 参数，circuit_screen 版硬编码 15）——合并时需统一为可配置 threshold。

3. **optics 无 zoom 需求**：当前 optics 仅使用 `CanvasProjection`（scale 参数固定传入），无 zoom 字段消费；统一后 zoom=1.0 默认值即可兼容。

4. **公共层已有 `PositionElement.hitTest`（矩形命中）作为基础**，导线命中检测（线段距离）是补充能力，两者不冲突。

5. **DragDropWorkspace 当前在 `_DropCanvas` 内部自行构建 CanvasProjection**（`LayoutBuilder` 拿尺寸后 new）；统一后是否改为外部注入投影实例是关键技术决策点（影响公共 API 签名）。

## 关键依赖

- 本需求完成后，`shared-abstraction-plan.md` 需新增候选条目记录统一投影类。
- 后续新 sim 接入 `DragDropWorkspace` 时将直接受益（无需再处理投影不一致问题，参考 S3 的"同类风险"警告）。

---

## 收尾追加（2026-08-25 · closer）

### 已确认发现（含依据）

1. **技术方案勘察漏 grep 符号名，导致第三份平行实现遗留（M1）**：方案 §0 只 grep 了 `_hitTestWire`，漏了 `_pointToSegmentDistance`。评审发现 `circuit_state.dart:155` 有逐行同构的活代码副本。**教训：上抽类需求勘察时，除目标符号外，必须 grep 同义/同构的其他符号名**（如距离函数的不同命名），否则会"漏网一份平行实现"。

2. **死文件删除前必须独立 grep 复核**：`circuit_canvas.dart`（354 行）删除安全，因删前 grep `CircuitCanvas` 零引用 + 全量测试通过交叉印证。但同一批平行实现里，`circuit_state.dart` 的副本却是活代码——**"看起来是死代码"不能靠直觉，要靠 grep 每个符号的使用者**。

3. **等价性重构的最强锚定范式**：`hit_test_test.dart` 把旧内联公式原样复制为 `legacyInline` 函数做逐位对拍——比"往返恒等"更能证明"行为不变"（往返恒等是自证循环，对拍是真断言）。后续重构类需求应复用此范式。

### 踩坑经验（描述坑 + 解决方案）

- **坑：大段 replace 误删相邻类定义**（MT-3 删 circuit_screen 重复 SceneProjection 时一次 replace 误删 `CircuitPainter` 类头）。**解**：即时发现修复。**教训**：删重复定义时，replace 的目标串必须带足够上下文锚点，避免匹配到相邻代码；且每次编辑后立即编译/analyze 验证。
- **坑：中文字符 + 中文 Windows 下 PowerShell 读 git diff 乱码**（本次 closing 用 `git --output=<file>` 规避管道编码问题）。**解**：git diff 用 `--output=` 写文件再读；PowerShell 读 UTF-8 文件需 `-Encoding UTF8`（同 notes.md 并行需求已记录的踩坑）。

### 决策记录

- **D1 不抽基类**：两投影数学 100% 同构，无第二形态支撑——"统一"用参数化而非继承，避免过度抽象。
- **D2 只抽几何原子不抽编排**：`pointToSegmentDistance` 纯函数上抽，遍历编排（阈值/命中顺序）留 Screen 层唯一份——分层职责清晰，符合"命中检测在 Screen 层"约定。
- **D3 工厂回调是唯一正解**：投影需"外部参数 + 内部 LayoutBuilder 尺寸"，实例无法提前构造。

### 对后续需求的提示

- 涉及 DropCanvas / 投影 / 坐标换算的改动，**必须阅读 `shared-abstraction-plan.md` 候选 10**，遵循"禁建平行投影类 + projectionFactory 注入"范式。
- 后续接 DragDropWorkspace 的新 sim：光轴类 sim 走默认工厂（0.55），居中类 sim 走 projectionFactory 注入——两种范式见候选 10。
- **M3 遗留已落实**：本需求 commit 拆分（公共层 / 消费者迁移 / 知识库+产物），pathspec 精确加文件（禁 git add -A）。任何 future 重构需求应从一开始就"每 MT 独立 commit"，而非 closing 补。
- **m2 后续建议**：`SceneProjection.toWorld` 除零（scale/zoom=0 → NaN）无防护，新 sim 接公共工厂时注意——建议后续加 debug-only `assert`（本次守 C1 最小变更未加）。
