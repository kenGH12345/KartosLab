# G · source of truth

> 更新：2026-09-01 Build 决策  
> 不得把 Kepler 参数伪装成 MSS 一手源码。

## 一手源码（My Solar System）

`NumericalEngine.ts` 使用：

```ts
import { G } from '../../../../solar-system-common/js/SolarSystemCommonConstants.js';
```

本机 **没有** `solar-system-common`，因此 **G 的字面量不是 MSS 一手确认值**。

已确认的相关算法（与 G 数值无关、必须原样移植）：

- PEFRL + XI / LAMBDA / CHI
- `engineTimeScale = 0.05`
- `iterationCount = 4000 / N`
- `F = G m1 m2 r / |r|³`
- 五步共用同一加速度
- 碰撞：小体消失、动量并入、质量不合并

## 不要用的文档

`doc/model.md` 写 `G = 4.4567 × 10⁻³`。  
与 `OrbitalSystem.SUN_PLANET` 速度（约 23.45 km/s @ 2 AU, M=250）不自洽。  
**禁止**把该式抄进引擎。

## 当前运行默认（二次证据，可替换）

```
G = 4.45669
```

来源：

1. Kepler `EllipticalOrbitEngine.INITIAL_G`（同 phetLibs `solar-system-common`）
2. 闭合：`√(4.45669 × 250 / 2) ≈ 23.60`，接近 preset vy=23.4457（太阳 vy=-2.3446 修正质心）

代码：`MySolarSystemConstants.G`，注释必须含 `[二次证据 Kepler INITIAL_G]`。

替换路径：补回 `solar-system-common/js/SolarSystemCommonConstants.ts` 后，把该常量改为文件字面量，并跑 `engine_test`。

## 推测

无。当前不发明第三套 G。
