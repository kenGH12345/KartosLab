# VALIDATION — Gas Properties

> 用于 Phase 4 对照 PhET HTML 与 Flutter Native。  
> **不要求** JS 与 Dart 浮点 bit-for-bit 相同；要求物理行为与显示语义一致。

---

## 1. UI 几何容差

| 项目 | 容差 | 说明 |
|------|------|------|
| UI position / size | **±2 px** | 在逻辑 layoutBounds 缩放后的屏幕像素 |
| 控件相对布局 | 比例一致 | 不因设备改排版结构 |
| 粒子半径视觉 | ±2 px | MVT 0.040 px/pm 换算后 |
| 容器宽高比 | 严格 | width:height:depth 模型比不变 |

---

## 2. 数值容差

| 量 | 容差 | 依据 |
|----|------|------|
| Temperature（K） | **≤ 1 K** | 用户可见精度；Hold Constant 内部 assert 用 1E-3 |
| Pressure（kPa） | 按显示精度 | 表盘噪声存在时对比 **去噪模型值** 或长时间均值 |
| Pressure（atm） | 换算一致 | `× 0.00986923` |
| Volume | 相对误差 ≤ 0.1% | V = w·h·d |
| Particle speed / KE | 行为一致 | histogram bin 归属允许边界浮点差 1 bin |
| Average Speed | 相对 ≤ 2%（稳态同初态） | 1 ps 采样窗口随机性 |
| Center of Mass x | ≤ 半径量级 | Diffusion |
| Flow rate | 趋势一致 | 300 样本平均，不比瞬时值 |

### Hold Constant 内部（单元测试更严）

| 检查 | 源码参考 |
|------|----------|
| pressureT 后 T | `abs(desired - actual) < 1E-3` |
| pressureV 宽度 | `Utils.toFixedNumber(width, 5)` 后再约束 range |

---

## 3. 粒子位置

| 项目 | 容差 |
|------|------|
| 单步积分 | 允许浮点误差 |
| 碰撞后分离 | 无持续重叠（assert 级：容器不漏粒子） |
| 注入角 | 统计落在 π/2 色散锥内（非逐粒子相等） |

---

## 4. 时间

| 项目 | 期望 |
|------|------|
| NORMAL | 2.5 ps / real s |
| SLOW | 0.3 ps / real s |
| Step 按钮 | 每次 +0.2 ps model |
| Pressure gauge 刷新 | 每 0.75 ps 更新噪声显示 |
| Energy 采样 | 每 1 ps 刷新平均/直方 |
| Collision sample | 5 / 10 / 20 ps |

---

## 5. 功能对照表（Phase 4 填写）

| Feature | PhET | Flutter | Status |
| ------- | ---- | ------- | ------ |
| Ideal | ✓ | | |
| Explore | ✓ | | |
| Energy | ✓ | | |
| Diffusion | ✓ | | |
| Particle–wall collision | ✓ | | |
| Particle–particle collision | ✓ | | |
| Pressure (model) | ✓ | | |
| Pressure gauge noise | ✓ | | |
| Temperature from KE | ✓ | | |
| Heat / Cool | ✓ | | |
| Pump inject | ✓ | | |
| Hold Constant ×5 | ✓ | | |
| Oops dialogs | ✓ | | |
| Speed histogram 19 bins | ✓ | | |
| KE histogram 19 bins | ✓ | | |
| Average Speed | ✓ | | |
| Diffusion divider | ✓ | | |
| Center of Mass | ✓ | | |
| Particle Flow Rate | ✓ | | |
| Normal / Slow | ✓ | | |
| Pause / Step / Reset | ✓ | | |
| Preferences pressureNoise | ✓ | | |

---

## 6. 物理验证场景（最低集）

1. **PV=NkT**：固定 T、V，增 N → P 升  
2. **压缩 Ideal**：暂停拖墙 → 松开重分布；P 随 V 变；粒子动能不变（壁不做功）  
3. **压缩 Explore**：播放中缩容器 → 壁做功 → T 升  
4. **Heat**：火焰 → |v| 与 T 升  
5. **Cool**：冰块 → |v| 与 T 降  
6. **同 T 不同质量**：Light 平均速率 > Heavy  
7. **超压**：P>20000 → 盖飞  
8. **Hold pressureV**：增 N → 宽度自动变；越界 → Oops + Nothing  
9. **Energy histogram**：稳态 Maxwell 样分布；关碰撞后注入呈更“波前”  
10. **Diffusion**：移隔板后 COM 趋中、flow rate > 0  

---

## 7. 验证方法

- 并排：PhET HTML + Flutter Emulator  
- 截图：375×667 / 1024×768 / 1920×1080（若项目规范要求）  
- 单元测试：solver 纯函数（碰撞冲量、P/T、binning、TimeTransform）  
- 禁止：用随机数伪造“看起来像”的压力/直方数据冒充 PASS  
