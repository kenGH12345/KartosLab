# Balancing Act — ASSET_MAP

> Phase 0 · 2026-09-23  
> 优先级：原 PhET asset → 原 geometry → Flutter 仅在 PROCEDURAL 时重建  
> Flutter Target：规划路径，**Phase 0 未创建** `lib/balancing_act/`

---

## Status legend

| Status | Meaning |
|--------|---------|
| FOUND | 本地文件存在，运行时使用 |
| DESIGN_ONLY | 在 assets/ 但运行时未 import |
| PROCEDURAL | 源码 Path/Shape 绘制，无位图 |
| EXTERNAL | 依赖包内（vegas/tambo/scenery-phet） |
| MISSING | 应有但缺失 |

---

## 1. Runtime images — screen / game chrome

| Asset | Source Path | Used By | Purpose | Flutter Target | Status |
|-------|-------------|---------|---------|----------------|--------|
| introIcon.svg | `images/introIcon.svg` | BAIntroScreen | Screen icon | `assets/balancing_act/images/introIcon.svg` | FOUND |
| introIconSmall.png | `images/introIconSmall.png` | home/nav small | Small icon | same | FOUND |
| gameIcon.svg | `images/gameIcon.svg` | BalanceGameScreen | Screen icon | … | FOUND |
| gameIconSmall.png | `images/gameIconSmall.png` | small icon | … | FOUND |
| gameLevel1Icon.svg | `images/gameLevel1Icon.svg` | StartGameLevelNode | Level 1 thumb | … | FOUND |
| gameLevel2Icon.svg | `images/gameLevel2Icon.svg` | Level 2 | … | FOUND |
| gameLevel3Icon.svg | `images/gameLevel3Icon.svg` | Level 3 | … | FOUND |
| gameLevel4Icon.svg | `images/gameLevel4Icon.svg` | Level 4 | … | FOUND |
| plankBalanced.svg | `images/plankBalanced.svg` | Game tilt UI / icons | Plank balanced icon | … | FOUND |
| plankTippedLeft.svg | `images/plankTippedLeft.svg` | Tilt prediction | … | FOUND |
| plankTippedRight.svg | `images/plankTippedRight.svg` | Tilt prediction | … | FOUND |
| labScreenIcon (regional) | `images/{region}/*LabScreenIcon.svg` | BalanceLabScreen | Lab icon by culture | … | FOUND |

---

## 2. Runtime images — objects

| Asset | Source Path | Used By (model class) | Mass kg | Status |
|-------|-------------|----------------------|--------:|--------|
| fireExtinguisher.svg | `images/objects/` | FireExtinguisher | 5 | FOUND |
| trashCan.svg | `images/objects/` | SmallTrashCan / LargeTrashCan | 10 / 40 | FOUND |
| barrel.svg | Barrel | 90 | FOUND |
| blueBucket.svg | buckets | — | FOUND |
| yellowBucket.svg | SmallBucket etc. | — | FOUND |
| metalBucket.svg | LargeBucket | 15 | FOUND |
| cinderBlock.svg | CinderBlock | 12 | FOUND |
| fireHydrant.svg | FireHydrant | 60 | FOUND |
| flowerPot.svg | FlowerPot | 5 | FOUND |
| oldTelevision.svg | Television | 10 | FOUND |
| pottedPlant.svg | PottedPlant | 10 | FOUND |
| puppy.svg | Puppy | 6 | FOUND |
| sodaBottle.svg | SodaBottle | 2 | FOUND |
| tinyRock.svg | TinyRock | 4 | FOUND |
| tire.svg | Tire | 15 | FOUND |
| woodCrateTall.svg | Crate | 45 | FOUND |
| rock1/4/6.svg | Small/Medium/BigRock | 30/40/45 | FOUND |
| mysteryObject01–08.svg | MysteryMass A–H | varies | FOUND |
| defaultImage.png | fallback | — | FOUND |

---

## 3. Runtime images — regional people

Each of `africa/`, `asia/`, `latinAmerica/`, `oceania/`, `usa/` provides:

| Pattern | Used By | Status |
|---------|---------|--------|
| `*BoySitting.svg` / `*BoyStanding.svg` | Boy (HumanMass) | FOUND |
| `*GirlSitting.svg` / `*GirlStanding.svg` | Girl | FOUND* |
| `*ManSitting.svg` / `*ManStanding.svg` | Man | FOUND |
| `*WomanSitting.svg` / `*WomanStanding.svg` | Woman | FOUND* |
| `*LabScreenIcon.svg` | Lab screen icon | FOUND* |

\* `africaModest/`：**仅** Boy/Man Sitting+Standing（无 Girl/Woman/Lab icon）— 源码区域策略需在实现阶段对齐 `supportedRegionsAndCultures`。

---

## 4. Design-only / unused at runtime

| Asset | Path | Notes | Status |
|-------|------|-------|--------|
| balance-with-supports-icon.svg | `assets/` | 设计稿；运行时用 `ColumnControlIcon` 程序绘制 | DESIGN_ONLY |
| balance-without-supports-icon.svg | `assets/` | 同上 | DESIGN_ONLY |
| BA-*.ai / people-all-regions.ai | `assets/` | Illustrator 源 | DESIGN_ONLY |
| balancing-act-screenshot*.png | `assets/` | 官方截图参考 | DESIGN_ONLY |

---

## 5. Procedural (no PNG to copy)

| Element | Source | Flutter approach | Status |
|---------|--------|------------------|--------|
| Fulcrum A-frame | `Fulcrum` Shape + `FulcrumNode` Path | CustomPainter from same Shape | PROCEDURAL |
| Plank + ticks | `Plank` / `PlankNode` | CustomPainter | PROCEDURAL |
| Attachment bar | `AttachmentBarNode` | CustomPainter | PROCEDURAL |
| Brick stack | `BrickStack` Shape + `BrickStackNode` | CustomPainter | PROCEDURAL |
| Support columns | `LevelSupportColumnNode` | Align scenery-phet geometry | PROCEDURAL |
| Column toggle icons | `ColumnControlIcon` | CustomPainter | PROCEDURAL |
| Level indicator | `LevelIndicatorNode` | CustomPainter | PROCEDURAL |
| Force vectors | `PositionedVectorNode` / ArrowNode | CustomPainter / L0 arrow | PROCEDURAL |

---

## 6. Mipmaps / sounds

| Path | Status |
|------|--------|
| `mipmaps/` | 仅 `license.json` — **无图像** |
| Local audio | **NONE** — see AUDIO_AUDIT.md |

---

## 7. Substituted Assets policy

Phase 0–3 基线：**Substituted = 0**。  
Phase 3 Lab 已复用：
- `assets/simulations/balancing_act/images/objects/` — fireExtinguisher, trashCan, mysteryObject01–08
- `assets/simulations/balancing_act/images/usa/` — standing people for Lab creators
- Brick stacks / plank / fulcrum / rulers / marks — PROCEDURAL per source

Final QA 必须保持 Substituted Assets = 0；禁止 Material Icons / 网上相似图 / AI 图冒充 PhET。

---

## 8. Summary counts

| Category | Count (approx) |
|----------|----------------|
| Object SVGs | ~25 unique |
| Mystery objects | 8 |
| Regional people SVGs | ~5 regions × ~8–9 + africaModest subset |
| Screen/game icons | 8+ |
| Procedural core scene | 6+ elements |
| Local audio | 0 |
| Missing critical runtime assets | **0** |
