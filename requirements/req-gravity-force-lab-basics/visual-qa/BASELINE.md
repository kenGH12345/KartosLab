# Visual Baseline — GFLB

**[待确认：缺少原版 runtime 截图]**

逻辑基线（源码默认，非像素）：

| 场景 | 源码行为 |
|---|---|
| Default | m1=2e9 蓝 / m2=4e9 红；距 4 km；F≈33.4 N；Distance on；Constant Size off |
| Closer / farther | snap 100 m |
| Mass change | NumberPicker ±1e9 |
| Constant Size | 半径固定 |
| Values / Distance toggle | checkbox |

视觉常量：bg `#ffffc2`；layout 768×464；MVT 0.05。
