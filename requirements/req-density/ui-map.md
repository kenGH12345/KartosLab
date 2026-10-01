# UI Map · Density

原版布局是 joist ScreenView + `addAlignBox`（顶中 / 右上 / Reset 默认右下），**不是** NineGrid。Flutter 必须用 `NineGridLayout` 重排，语义对应如下。

## 1. 视觉层（原版）

```
THREE isometric scene (DensityBuoyancyScreenView)
  ├── Sky / ground meshes
  ├── Pool water (FluidMesh) + walls
  ├── Cuboid meshes (MaterialView PBR)
  ├── MassTagNode（角标 A/B/1A…）
  ├── MassLabelNode（kg 读数，pickable:false）
  └── Scale（Mystery）
Scenery overlay
  ├── Accordion / Panels / Radio / Reset
  └── popupLayer（ComboBox 列表）
```

相机：`DENSITY_CAMERA_LOOK_AT = Vector3.ZERO`。

## 2. Flutter 九宫格建议

| 格 | Intro | Compare | Mystery |
|---|---|---|---|
| center | 池+块+地面 | 同 | 池+块+秤 |
| top | Density 数轴手风琴 | （空或短标题） | Density Table 手风琴 |
| topRight / right | A/B 控制面板 | BlocksPanel | Blocks Set 面板 |
| bottom / footer | One-Two + Reset | Reset | Reset |
| bottomRight | — | BlocksValuePanel（对齐地面前沿） | Random Refresh 可并入右面板 |

中间格只放实验画面。禁止把整块控制面板塞进 center。

## 3. 材料外观

`DensityMaterials.getMaterialView`：

| 材料 | View | 贴图族 |
|---|---|---|
| Aluminum | AluminumMaterialView | Metal10 |
| Brick | BrickMaterialView | Bricks25 |
| Ice | IceMaterialView | Ice01 |
| PVC | PVCMaterialView | Plastic018B |
| Styrofoam | StyrofoamMaterialView | Styrofoam_001 |
| Wood | WoodMaterialView | Wood26 |
| Custom / hidden / mystery 纯色 | ColoredMaterialView(colorProperty) | 无；Custom 默认可灰度随密度 |
| Copper / Steel / Platinum / Gold… | 对应金属贴图 | Mystery 内部密度用，Intro 下拉不出现 |

块是立方体，不是 2D 矩形截图。阴影/高光随 THREE 灯光；Flutter 用等距立方体 + 贴图或三面着色近似。

Compare：四色黄蓝绿红，明暗随密度（`colorUtilsBrightness`，scale 0.4，range = sameDensityRange）。

## 4. 字体（原版 px，Flutter 按密度缩放）

| 用途 | PhET |
|---|---|
| TITLE_FONT | 16 bold |
| ITEM / RADIO / COMBO / READOUT | 14 |
| Table header/body | 12 |
| MassLabel | 18 |
| 面板圆角 | 5 |
| 边距 MARGIN | 10；小边距 5 |

## 5. Density Table UI

- AccordionBox + GridBox 两列：Material name | Density (kg/L)
- 表头背景 `chartHeaderColor`，单元格白底黑框
- 行序：材料按 density 升序
- 不是 Dialog；无独立滚动（材料 13 行固定）
- 关：折叠手风琴（Reset 也折叠）

## 6. 密度数轴（Intro）

宽 400、高 22，maxDensity 10000。标记名称 + `value kg/L`（2 位）。参考刻度来自材料名。

## 7. 字符串映射（PhET → Flutter key）

| PhET | Flutter 建议 key |
|---|---|
| density.title | density.title |
| screen.intro/compare/mystery | density.screen.* |
| material.* | density.material.* |
| mass / volume / density | density.mass / volume / density |
| blockSet.sameMass/Volume/Density | density.compare.same* |
| blockSet.set1/2/3/random | density.mystery.set* |
| densityTable | density.table.title |
| kilogramsPattern / litersPattern | density.unit.* |
| massLabel.* | density.tag.* |
| a11y.randomBlockRefresh / scale | density.a11y.* |
| questionMark | density.unknown |

禁止大面积硬编码英文。Reset All 用工程已有 Reset 文案即可。
