# ARCHITECTURE_PLAN · Build a Molecule

## 1. 目录

```
lib/chemistry/build_a_molecule/
  build_a_molecule_home.dart          # KratosTabbedScreen
  bam_constants.dart
  data/
    bam_element.dart                  # nitroglycerin Element 子集
    bam_serial_parser.dart
    bam_molecule_catalog.dart         # MoleculeList
    bam_strings.dart
  model/
    bam_atom.dart
    bam_bond.dart
    bam_molecule_structure.dart
    bam_stripped_molecule.dart
    bam_element_histogram.dart
    bam_complete_molecule.dart
    bam_molecule.dart                 # play-area molecule
    bam_direction.dart
    bam_lewis_dot.dart
    bam_bucket.dart
    bam_kit.dart
    bam_collection_box.dart
    bam_kit_collection.dart
    bam_collection_layout.dart
    bam_screen_model.dart             # BAMModel
    single_configuration.dart
    multiple_configuration.dart
    playground_configuration.dart
  controller/
    bam_controller.dart               # ChangeNotifier 门面
  render/
    bam_projection.dart               # model↔view
    bam_atom_render.dart
    bam_molecule_3d_render.dart
  painters/
    bam_play_area_painter.dart
    bam_molecule_3d_painter.dart
  widgets/
    … kit / collection / 3d dialog …
  screens/
    single_screen.dart
    multiple_screen.dart
    playground_screen.dart
```

`assets/data/build_a_molecule/`：已迁移 JSON（collection / other / structures / strings_en）。

---

## 2. 数据流

```
Input (drag)
  → BamController
  → BamKit (Lewis + attemptToBond + isAllowedStructure)
  → BamMolecule / BamMoleculeStructure
  → BamMoleculeCatalog.findMatch / isAllowed
  → Derived: name, formula, cues
  → RenderData
  → Painter / Widgets
```

Collection：

```
Matched molecule drop
  → CollectionBox.willAllow (isEquivalent)
  → quantity++
  → if all full → AllFilled → generateKitCollection
```

---

## 3. 3D 决策（不暂停）

| 选项 | 决定 |
|---|---|
| A 真 WebGL / 新 engine | **否**（暂停条件） |
| B Canvas 2.5D 投影 | **是** — 移植 `Molecule3DNode` |
| C 仅 2D 无旋转 | 不足 |

标记：`[有意差异：无 THREE/WebGL Dialog]`；交互旋转/SpaceFill/BallStick 在 Canvas 实现。

---

## 4. 与 common

| 复用 | 不抽到 common |
|---|---|
| NineGridLayout、KratosTabbedScreen | Molecule/Kit/Catalog（首个用户） |
| celebration_dialog（收集完成可选用） | Lewis / Structure matching |

不修改 common API。

---

## 5. Home

化学 → 新 `_SubjectGroup`「分子搭建」→「搭建分子」→ `BuildAMoleculeHome`。  
不改 Navigation 架构。

---

## 6. 测试金字塔

1. Serial parser + catalog load counts  
2. isEquivalent（water ↔ 同构置换）  
3. isAllowedStructure 正/负例  
4. CollectionBox capacity / reject  
5. Kit bond gate（非法结构不成键）  
6. generateKitCollection 确定性 seed  
7. reset / home_nav  

---

## 7. 实现顺序

Phase 4 Catalog+Structure → 5 静态 UI → 6 Kit 交互 → 7 Collection → 8 3D Canvas → 9 Home → 10–13 QA/cleanup
