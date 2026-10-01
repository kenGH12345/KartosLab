# GEOMETRY_CALIBRATION — Diffusion

| 量 | 值 | 标记 |
|---|---|---|
| Container W×H | 16000×8750 pm | [源码一致] |
| Divider thickness | 100 pm | [源码一致] |
| Wall thickness | 75 pm | [源码一致] |
| MVT scale | 0.040 px/pm（PhET）；Flutter aspect-fit | [行为一致] |
| Flow VECTOR_SCALE | 25 | [源码一致] |
| Control panel width | PhET fixedWidth≈300；Flutter 280 | [视觉近似] |
| Quantity row | label + cyan icon/spinner + red icon/spinner | [行为一致] |
| Spinner deltas | N:10 · mass:1 · radius:5 · T:50 | [源码一致] |
| Ranges | N 0–200 · mass 4–32 · radius 50–250 · T 50–500 | [源码一致] |
| Stopwatch precision | 1 decimal · unit ps · max 999.99 | [源码一致] |
| Data accordion | above container · default collapsed | [源码一致] |
| Divider button | inside control panel · disabled if N=0 | [源码一致] |

不得用截图像素坐标硬编码布局。
