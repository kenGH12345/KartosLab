# ASSET_AUDIT — RPL

目标：**Substituted = 0**（有原 asset 必须用原 asset）

## 1. 位图 PNG（`images/`）

| Original | Used By | Flutter Path (planned) | Type |
|---|---|---|---|
| `bread.png` | SandwichNode, equation | `assets/reactants_products_and_leftovers/images/bread.png` | Original |
| `cheese.png` | SandwichNode, equation | `.../cheese.png` | Original |
| `meat.png` | SandwichNode, equation | `.../meat.png` | Original |
| `sandwichesHomeScreenIcon.png` | Joist home | `.../sandwiches_home_screen_icon.png` | Original |
| `sandwichesNavbarIcon.png` | Navbar | `.../sandwiches_navbar_icon.png` | Original |

License：`images/license.json` — contact phethelp@colorado.edu

## 2. 程序生成（Scenery / Canvas）

| Asset | Source | Flutter Strategy |
|---|---|---|
| Sandwich 产物 | `SandwichNode.ts` 堆叠 PNG | 同算法 + 原 PNG |
| 分子 H₂, O₂, H₂O, … | nitroglycerin `*Node` | CustomPainter 复刻几何（参考 nitroglycerin 或已有 chemistry sim） |
| RightArrowNode | scenery-phet | `arrow_painter` 或 RPL painter |
| HideBox | dashed rect + eye-slash | CustomPainter（禁 FontAwesome 终态若 source 用 FA，可等价绘制） |
| BracketNode | scenery-phet | CustomPainter |
| PlusNode | scenery-phet | CustomPainter |
| FaceWithPointsNode | scenery-phet + vegas | Phase 4 game |
| Level reward | RPALRewardNode | Phase 4 |

## 3. 无独立 PNG 的资源

- Molecules screen 分子：**全部** nitroglycerin Node，无 RPL 本地 PNG
- Game RandomBox 分子：同上
- `assets/` 目录仅 README，无额外文件

## 4. 字符串 / i18n

`reactants-products-and-leftovers-strings_en.json` — 28 keys，须完整映射到 `rpal_strings.dart`。

## 5. 音频（Phase 4+）

Vegas `GameAudioPlayer`：correct/wrong/gameOver — source `supportsSound: true`

## 6. Substituted 追踪表

| ID | Description | Status |
|---|---|---|
| — | （Phase 0 尚未复制 asset） | PENDING |

Phase 2 起每引入 visual 须更新 `ASSET_MAP.md`（待建）。

## 7. 严禁替代

- `Icons.lunch_dining` / `Icons.fastfood` 代替 bread/sandwich
- generic 彩色圆代替 H₂/O₂/H₂O
- `Icons.refresh` 代替 Reset All
- Material 默认 Radio/Checkbox 作为最终 UI

## 8. 复制动作（Phase 2 前）

```text
phet sourses/.../images/*.png
  → assets/reactants_products_and_leftovers/images/
```

并在 `pubspec.yaml` 注册。
