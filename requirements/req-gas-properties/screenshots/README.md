# Screenshots — Gas Properties Phase 4.1

成对对照：`{screen}/{phet|flutter}/{state}.png`

## 库存（8 对）

| Screen | States |
|--------|--------|
| ideal | `initial`, `hold_temperature` |
| explore | `initial`, `moving_wall` |
| energy | `initial`, `histogram_populated` |
| diffusion | `initial`, `partition_removed` |

## 采集

- **PhET**：Playwright → 官方 HTML `?screens=1..4`；活性态用 `phet.joist.sim` 改 model  
  脚本：`tool/capture_phet_secondary.js`
- **Flutter**：`flutter run -d windows -t lib/gas_properties/screens/gas_properties_capture_main.dart`

## 说明

本地 `gas-properties_en.html` 无 chipper 依赖，不能独立跑；截图使用官方 build，功能仍以本地源码为 Ground Truth。
