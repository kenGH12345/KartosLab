# PHASE 1 — Model / VSEPR

没有 Screen UI，没有 Home 入口。模型在 `lib/molecule_shapes/model/`，测试在 `test/molecule_shapes/`。

## 从 source 迁过来的规则

- Domain = 连在中心原子上的 pair group。单键、双键、三键各算 **1** 个。`wouldAllowBondOrder` 不看键序。
- 上限 6。第 7 个键或孤对被拒绝。不按“化学上不存在”额外拦截。
- 几何名称只查 `(x, e)`，与 `MoleculeGeometry.getConfiguration` 相同。拖原子只改键角。
- 理想位置使用 `ElectronGeometry` 的单位向量，孤对占前 `e` 个槽（`placeRadialGroupsAtIdealSlots`）。四面体常数与 source 相同，显示 `109.5°`。
- 键角是两个径向原子 orientation 的夹角，格式 `toFixed(1)°`，短标签左侧补 `0`。
- 旋转写在 `quaternion` 上。局部坐标不动，`worldPosition` 才变。与 `moleculeQuaternionProperty` → `MoleculeView.quaternion` 一致。
- Real 列表是 `TAB_2_MOLECULES` 的 13 个，初始 H2O + Real。BeCl2 只留在数据里，不进菜单。
- Real 键角来自 shape 坐标（水 104.5°，氨 107.8°）。Model 视图用理想槽（水 109.5°）。切换不改 `displayName`。
- `showOuterLonePairs` 是 preference，还要同时打开 Show Lone Pairs。Screen reset 不关 preference。
- Model reset 回到中心原子 + `(8,0,3)`、`(2,8,-5)` 两个单键（长度 10）。

## 刻意没在这一阶段做的

`AttractorModel` 的 SVD 逐帧积分没有移植。几何名称和理想键角不依赖它；拖拽后的角度直接来自新坐标。Real ↔ Model 切换使用各自的目标坐标，没有做 source 里“按上一帧朝向做最小二乘旋转”的连续性。这两项留给后面的行为对齐，不能当成另一套 VSEPR 角度表。

## 验证

```text
flutter test test/molecule_shapes/
21 tests, All tests passed

dart analyze lib/molecule_shapes test/molecule_shapes
No issues found
```
