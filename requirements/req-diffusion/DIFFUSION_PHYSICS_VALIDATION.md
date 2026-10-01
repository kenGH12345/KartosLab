# DIFFUSION_PHYSICS_VALIDATION

取证：gas-properties `7a52c48` · DiffusionModel / CollisionDetector / BaseModel

## 1. Default state
- Divider **in**；left/right N=**0**；m=28 AMU；r=125 pm；T₀=300 K；playing；Normal  
- [源码一致]

## 2. Particle initialization
- Position ~ Uniform(bounds inset radius) via random  
- \|v\| = √(3 k T / m)，k=8.316×10³；θ random  
- [源码一致] · 轨迹非确定性除非注入 seed

## 3. Particle–particle collision
- e=1；接触且上帧未接触；冲量 j；位置反射  
- [源码一致]

## 4. Wall collision
- Clamp + 反射对应速度分量  
- [源码一致]

## 5. Divider
- ON：两室独立壁；OFF：整室；Restore→restart 同 N  
- [源码一致]

## 6. Diffusion progression
- Divider 移除后跨中线混合；Data 左右 N 变化  
- [行为一致] 统计观测

## 7. Species 1 / 2（非教材 Heavy/Light 名）
- Particle1 cyan；Particle2 red；mass/radius/T 独立可调  
- [源码一致]（UI 可称 Left/Right species）

## 8–9. Mass / radius change
- 改 m/T→重算 \|v\|；改 r→更新半径（暂停时夹入 bounds）  
- [源码一致]

## 10–11. Normal / Slow
- 2.5 vs 0.3 ps per real second  
- [源码一致]

## 12. Step
- 固定模型 Δt = 0.2 ps（via inverse transform）  
- [源码一致]

## 13. Pause
- `isPlaying=false` → `step` no-op；手动 step 仍可  
- [源码一致]

## 14. Reset
- BaseModel + container + settings + COM + flow；粒子数组清空由 N→0 链路  
- [源码一致]

## 守恒
- 弹性 e=1 → 动能期望守恒（数值误差内）— 仅在源码假设下测试  
- **不**要求 PV=nRT
