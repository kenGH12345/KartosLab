# Asset Map · Density

## 1. density 薄壳

| 文件 | 用途 | 迁移 |
|---|---|---|
| `mipmaps/intro_screen_icon_png.ts` | Home/屏图标 | 可选；KartosLab Home 现用 IconData |
| `mipmaps/compare_screen_icon_png.ts` | 同 | 可选 |
| `mipmaps/mystery_screen_icon_png.ts` | 同 | 可选 |
| `mipmaps/license.json` | 图标版权 | 保留摘录到本需求 |
| `density-strings_en.json` | 4 个字符串 | 迁入 Flutter l10n |
| `LICENSE` | GPL-3.0 | 不得删；About 署名 |

无 `assets/` 运行时图、无 audio、无 fonts。README 截图 URL 仅文档用。

## 2. density-buoyancy-common（运行时）

### 2.1 材质贴图（**runtime used** · Intro 具名材料）

均在 `images/*_jpg.ts`（data:image/jpeg;base64）。`images/license.json`：**CC0** cc0textures.com。

| 文件前缀 | 材料 |
|---|---|
| Wood26_col/nrm/rgh | Wood |
| Styrofoam_001_col/nrm/rgh/AO | Styrofoam |
| Ice01_col/nrm/alpha | Ice |
| Plastic018B_col/nrm/rgh | PVC |
| Bricks25_col/nrm/AO | Brick |
| Metal10_col/col_brightened/met/nrm/rgh | Aluminum |

### 2.2 其它金属贴图（Mystery 密度对应材料若用 PBR；Compare 纯色可不迁）

Metal002, Metal007, Metal08, DiamondPlate01。Buoyancy 专用 PNG 图标（boat/bottle/fluid_displaced/buoyancy_explore）**Density 不用**。

### 2.3 控件图标

`mipmaps/singleCuboidIcon_png.ts` / `doubleCuboidIcon_png.ts`：One/Two Blocks。**runtime used**。

屏图标 compare_screen_icon 在 common 也有一份，与薄壳重复，迁一份即可。

### 2.4 音频

common 仓库 **无 mp3**。抓放音来自 joist `sharedSoundPlayers`。一期可静默，记录缺口，不自制音效。

## 3. 分类

| 类别 | 处理 |
|---|---|
| runtime used | 抽出 Intro 六套材质 jpg + One/Two 图标 |
| buoyancy-only | 不迁 boat/bottle/duck/流体图标 |
| unused / historical | 无独立目录 |
| test used | 无 |

## 4. Flutter 目标路径

本工程惯例是 `assets/` 下按模块分（molarity 用 `assets/scenarios/molarity/`）。用户 prompt 要求 `assets/simlab/density/`。**推荐折中**：

```
assets/density/images/
assets/density/NOTICE.md    # Adapted from PhET + CC0 + GPL
```

在根 `pubspec.yaml` 声明该目录。不散落到 `assets/images/`。若用户坚持 simlab 命名空间，再用 `assets/simlab/density/`。

提取方式：从 `*_jpg.ts` 的 `image.src = 'data:image/jpeg;base64,...'` 写出 `.jpg`。不要用网页截图代替块。
