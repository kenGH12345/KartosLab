# GAS_PHYSICS_VALIDATION — Gases Intro

**权威**：gas-properties @ `10c7c08`

## 常量

| 符号 | 值 | Flutter |
|---|---|---|
| k (BOLTZMANN) | 8.316e3 (pm²·AMU)/(ps²·K) | `GasesIntroConstants.boltzmann` |
| PRESSURE_SCALE | 1.66e6 | `pressureConversionScale` |
| ATM_PER_KPA | 0.00986923 | `atmPerKpa` |
| Heavy mass/radius | 28 / 125 | constants |
| Light mass/radius | 4 / 87.5 | constants |
| height×depth | 8750×4000 pm | container |
| width range | 5000–15000，默认 10000 | container |
| heatCool divisor | 800 | constants |
| maxPressure | 20000 kPa | constants |
| maxTemperature | 1e5 K | constants |
| NORMAL / STEP | 2.5 ps/s / 0.2 ps | clock |

## 公式

| 量 | 公式 | Tolerance（测试） |
|---|---|---|
| KE | ½ m \|v\|² | 1e-9 相对 |
| T | (2/3)⟨KE⟩/k | 1e-6 相对（解析构造） |
| P_kPa | (N k T / V) * 1.66e6 | 1e-6 相对 |
| V | w·h·d | exact |
| inject \|v\| | √(3 k T / m) | 1e-9 |
| heat | v' = v (1+f/800) | 1e-12 |

## 数值案例（解析）

1. N=0 → T=null，P=0  
2. 单粒子 m=28，\|v\| 使得 KE=(3/2)k·300 → T≈300 K  
3. V=10000·8750·4000，N=100，T=300 → P 按公式  
4. heat f=1 → 每步 scale=1+1/800  

## 宏观关系

源码定义 **PV=NkT**（代码单位）。Hold Constant 按 `SOURCE_ANALYSIS` §9。  
Flutter 必须同源码关系；不得用教材 R 常数替换 k。

## MODEL vs DISPLAY Pressure

- MODEL：`pressureProperty`（无噪声）— **公式即 Ideal Gas Law 派生** `P=(NkT/V)*1.66e6`（PressureModel.ts），**不是**冲量采样替代品。
- DISPLAY：`PressureGauge` 采样；本 sim 噪声默认关 → 显示≈model（采样延迟除外）

## Macro / Micro 耦合测试（interaction_fix）

| 操作 | 期望链 | 测试 |
|---|---|---|
| Heat f=1 | v↑ → KE↑ → T↑ → P↑ | test 10 |
| Cool f=-1 | v↓ → KE↓ → T↓ → P↓ | test 11 |
| 左墙改宽 | V 变 + redistribute | test 12 |
| 暂停 | heatCool 拒绝非零 | test 13 |
