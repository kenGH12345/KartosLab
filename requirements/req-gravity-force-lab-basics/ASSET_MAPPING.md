# ASSET_MAPPING — Gravity Force Lab: Basics

## 结论

**[已确认]** 本地 `figurePull_*.png` 共 **31** 张，资源完整。

| 检查项 | 结果 |
|---|---|
| 磁盘文件 `figurePull_1.png` … `figurePull_31.png` | **31/31** |
| `pubspec.yaml` 目录注册 | ✅ `assets/phet/gravity_force_lab_basics/pullers/` |
| 运行时路径映射 | ✅ `GflbConstants.pullerAssetDir` + `PullerImageWidget.assetPath` |
| 缺失 PNG | **无** |
| 运行时资源加载缺口 | **无** |
| 构建 / 测试影响 | **无** |

> 说明：下载过程曾在约 `figurePull_9` 处中断，但后续已补齐。该中断**不是**最终状态，不得记为 BLOCKED 或 [缺失资源]。

---

## pubspec 覆盖

```yaml
flutter:
  assets:
    - assets/phet/gravity_force_lab_basics/pullers/
```

Flutter **目录级** asset 声明会打包该目录下全部文件，因此 `figurePull_1.png` … `figurePull_31.png` 均已覆盖，无需逐文件列举。

---

## 源 → Flutter 映射

| # | PhET 源（ISLC） | Flutter asset |
|---|---|---|
| 1 | `inverse-square-law-common/images/figurePull_1.png` | `assets/phet/gravity_force_lab_basics/pullers/figurePull_1.png` |
| 2 | `…/figurePull_2.png` | `…/figurePull_2.png` |
| 3 | `…/figurePull_3.png` | `…/figurePull_3.png` |
| 4 | `…/figurePull_4.png` | `…/figurePull_4.png` |
| 5 | `…/figurePull_5.png` | `…/figurePull_5.png` |
| 6 | `…/figurePull_6.png` | `…/figurePull_6.png` |
| 7 | `…/figurePull_7.png` | `…/figurePull_7.png` |
| 8 | `…/figurePull_8.png` | `…/figurePull_8.png` |
| 9 | `…/figurePull_9.png` | `…/figurePull_9.png` |
| 10 | `…/figurePull_10.png` | `…/figurePull_10.png` |
| 11 | `…/figurePull_11.png` | `…/figurePull_11.png` |
| 12 | `…/figurePull_12.png` | `…/figurePull_12.png` |
| 13 | `…/figurePull_13.png` | `…/figurePull_13.png` |
| 14 | `…/figurePull_14.png` | `…/figurePull_14.png` |
| 15 | `…/figurePull_15.png` | `…/figurePull_15.png` |
| 16 | `…/figurePull_16.png` | `…/figurePull_16.png` |
| 17 | `…/figurePull_17.png` | `…/figurePull_17.png` |
| 18 | `…/figurePull_18.png` | `…/figurePull_18.png` |
| 19 | `…/figurePull_19.png` | `…/figurePull_19.png` |
| 20 | `…/figurePull_20.png` | `…/figurePull_20.png` |
| 21 | `…/figurePull_21.png` | `…/figurePull_21.png` |
| 22 | `…/figurePull_22.png` | `…/figurePull_22.png` |
| 23 | `…/figurePull_23.png` | `…/figurePull_23.png` |
| 24 | `…/figurePull_24.png` | `…/figurePull_24.png` |
| 25 | `…/figurePull_25.png` | `…/figurePull_25.png` |
| 26 | `…/figurePull_26.png` | `…/figurePull_26.png` |
| 27 | `…/figurePull_27.png` | `…/figurePull_27.png` |
| 28 | `…/figurePull_28.png` | `…/figurePull_28.png` |
| 29 | `…/figurePull_29.png` | `…/figurePull_29.png` |
| 30 | `…/figurePull_30.png` | `…/figurePull_30.png` |
| 31 | `…/figurePull_31.png` | `…/figurePull_31.png` |

---

## 代码引用

| 项 | 值 / 位置 |
|---|---|
| 目录常量 | `GflbConstants.pullerAssetDir` = `assets/phet/gravity_force_lab_basics/pullers` |
| 帧数 | `pullerFrameCount = 31` |
| 帧映射 | `frameIndex` 0..30 → `figurePull_(index+1).png` |
| Widget | `lib/gravity_force_lab_basics/widgets/puller_image_widget.dart` |
| 缩放 | `IMAGE_SCALE = 0.45`；`ropeLength = 40` |
| 右侧质量 | 水平翻转 |

---

## 状态标签

- Robots / pullers：**[源码一致]** · **[已确认：31/31]**
- **非** BLOCKED
- **非** [缺失资源]
