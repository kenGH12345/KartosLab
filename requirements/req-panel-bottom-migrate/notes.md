# Notes — req-panel-bottom-migrate

## 已确认发现

1. **optics 不迁移**：midRight `_RightPanel` 是只读文本面板（教学目标/约束条件），与 footer 横排交互控件条的设计初衷不符，保留原位。（S8）

2. **circuit 遗留纳入**：NineGridLayout 顶部行 ~51px 空间不足 + 3 个 skip 测试，确认在本需求批次 4 一并修复。（S7）

3. **实际迁移 8 屏**（非 9 屏）：optics 保留 → 实际迁移 sound / wave_interference / radio_waves / rgb_bulbs / single_bulb / motion / netforce / circuit。

4. **分批策略**：4 批按面板相似度分组，低复杂度优先（声学波动 → 力学 → 色觉 → 电路），每批可独立验收。

## 技术待确认项（交 tech-leader）

- circuit 工具条拖拽交互迁到 footer 后，hit test 区域是否需要调整（影响用户拖拽电池/开关/灯泡的操作体验）
- 各屏控件总宽度在 320px 下经 FittedBox scaleDown 后是否仍可操作（触摸目标尺寸是否过小）

## 待观察

- 批次 4 复杂度可能需拆为子批次（4a 迁移 + 4b 遗留修复）

## 知识沉淀（closer 追加 · 2026-08-12）

### 已确认发现（带依据）

1. **AppliedForceSlider 200161px 溢出是真实产品 bug 而非测试误判**（D3）：独立 pump 异常值（scenario null 导致值异常）会掩盖真实窄格溢出（255px）。**依据**：app 链路测试（forces_home_test ForcesHome→运动 tab）实证真实溢出 255px；根因是 `SizedBox(200)` 固定宽在窄格内放不下。**教训**：独立 pump 暴露的大数溢出值不要直接判定为"测试方法误判"，需先用真实 app 链路（tab 导航）验证后再下结论。应用 Expanded 自适应宽度。

2. **独立 pump 缺 Scaffold 会造成纵向溢出误判**（D4）：SingleBulbScreen 无 Scaffold，独立 pump 需 MaterialApp+Scaffold 包裹（color_vision_test 先例）。**教训**：写 widget 测试前先确认 Screen 是否自带 Scaffold，缺则手动包裹，否则溢出是假的。

3. **circuit 320 AppBar 21px 是 AppBar 布局深层问题**（D9）：窄屏 11 按钮超宽，ComboBox 响应式隐藏(<600px) + FittedBox 双保险均无法消除。**依据**：closing 修复期间 M2 处理实证。**教训**：按钮数量过多的 AppBar 在 320px 下无法靠 FittedBox 消除溢出——需布局层方案（底部工具条/按钮合并），不是样式层能解决的。

### 踩坑经验

4. **Fixed-size 控件（SizedBox(200) / Container(width:100)）在窄格中必溢出**（D5/D6）：AppliedForceSlider（200px）与 sound SphericalLegend（100px）均是固定宽导致窄视口/窄格溢出。**解法**：改 Expanded 自适应（宽度由外部约束定），而非硬编码宽度。**通用规律**：footer 横排容器宽度随视口变化，固定宽子控件在 320px 下必溢出——推广 footer 方案时先扫一遍固定宽子控件。

5. **FittedBox scaleDown 不能解决按钮超宽问题**（D9）：FittedBox 只对单一 Widget 的布局缩放有效，AppBar 多按钮超宽时无效。**教训**：overflow 修复先判断是否单一可缩放根节点，多子节点/深层布局需换方案。

### 决策记录

6. **回退 → 攻关 → 恢复迁移 的三段式处理**（D3/D4）：批次2/3 motion 与 single_bulb 均先回退（保 midRight 竖排）再攻关（独立 app 链路验证 + 根因修复）后恢复 footer。**决策依据**：避免既有技术债阻塞迁移批次进度；先交付已验证的批次，遗留债单独立项。此模式值得推广。

7. **closing 阶段延伸处理 320 遗留**（D8）：code-reviewer rework 后，用户选择"处理 320 遗留"延伸至 closing 修复（而非退回 dev）。**决策依据**：320 遗留均已在 closing 阶段有明确根因，修复成本可控（FittedBox/Expanded/单行化），直接处理避免二次迭代。

### 对后续需求的提示

8. **涉及类似模块时注意**：
   - 推广 footer 方案的新屏：先检查该屏是否有固定宽子控件（SizedBox/Container(width:)），有则预判 320px 溢出
   - 写 layout test 前确认 Screen 是否自带 Scaffold
   - AppBar 按钮过多的屏（>8）在 320px 需独立布局方案，FittedBox 无法兜底
