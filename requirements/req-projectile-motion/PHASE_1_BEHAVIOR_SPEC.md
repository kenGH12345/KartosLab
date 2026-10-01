# PHASE 1 — Behavior Specification · Projectile Motion

> 依据：PHASE_0_SOURCE_RECON.md（全部行为可追溯到本地源码 1.1.0-dev.41 文件:行号）
> 范围：4 屏 Intro / Vectors / Drag / Lab（Stats 源码存在但未挂入原版入口，不迁移）

---

## 1. 交付定义

Flutter 原生 `lib/projectile_motion/`，经 `KratosTabbedScreen` 提供 4 个 Tab，行为与本地 PhET 版本逐条一致。layoutBounds 1024×618（joist 默认），FittedBox 适配（仿 pendulum_lab shell）。

## 2. 全局行为（4 屏公共）

### 2.1 时钟与步进
- `SimulationClock` 墙钟 dt → model.step(dt)（仅 isPlaying）
- 内部 accumulator：每累计 ≥12ms（慢放 ×0.33 后）调一次 `stepModelElements(0.012)`
- Step 按钮（暂停时可用）：单次 `stepModelElements(0.012)`
- 慢放：墙钟 dt × 0.33（`SLOW_MOTION_FACTOR`，Constants:82）

### 2.2 物理（AC-PHY）
- AC-PHY-1 发射：`(x0,y0)=(0,cannonHeight)`；`v = v0(cosθ, sinθ)`（Trajectory:163-168）
- AC-PHY-2 积分：`p' = p + v·t + ½a·t²`；`v' = v + a·t`；a 取上一点值，算完用新 v 重算 a（Trajectory:229-269）
- AC-PHY-3 阻力：`Fd = ½ρ(πD²/4)Cd|v|v`；`a = (−Fd.x/m, −g −Fd.y/m)`（Trajectory:209-221）
- AC-PHY-4 空气密度 NASA 公式（Model:406-437）；off → ρ=0
- AC-PHY-5 落地：y≤0 → y=0，本步时间按二次方程精确截断（Trajectory:441-455）；落地后不再 step
- AC-PHY-6 vx 反号保护：截断至 vx=0（Trajectory:242-248）
- AC-PHY-7 apex：vy 由正转负时插值插入 apex DataPoint（Trajectory:280-302）
- AC-PHY-8 目标命中：|x−targetX| ≤1.5/1.0/0.5 → 1/2/3 星（Target.ts:65-78）
- AC-PHY-9 数值锚点（无阻力真空，g=9.81，h=0，θ=80°，v=18）：解析射程 ≈ 10.79 m、飞行时间 ≈ 3.611 s、最高点 ≈ 16.04 m；积分结果应在 1% 容差内吻合（恒定 dt 有微小数值误差）

### 2.3 参数变化语义（AC-SEM）
- SEM-1 改 angle/speed/mass/diameter/Cd/height：仅影响**下一次**发射，空中抛体不变
- SEM-2 改 gravity / airResistanceOn / altitude：**立即**影响空中抛体（轨迹标 changedInMidAir）
- SEM-3 改 selectedObjectType：立即同步 mass/diameter/Cd 控件值

### 2.4 Fire / Erase / Reset（AC-FIRE）
- FIRE-1 Fire 按钮：enabled 条件 = 空中抛体数 < 10；按下 → 发射 1 发 + 炮口火焰动画 0.4s
- FIRE-2 最多保留 10 条轨迹；超出时优先 dispose 已落地的最老轨迹（Model:332-349）
- FIRE-3 Eraser：清空全部轨迹（eraseTrajectories）
- FIRE-4 ResetAll：§PHASE0-12 全部 Property 复位 + 视图状态复位（含 zoom、工具、播放状态恢复默认 playing=true）

### 2.5 轨迹渲染（AC-TRAJ）
- TRAJ-1 折线连接相邻 DataPoint，宽 2px；阻力开=洋红 rgb(252,40,252)，关=蓝
- TRAJ-2 时间采样点：每 1000ms 大点 r=3.3px、每 100ms 小点 r=1.65px；dots opacity = max(0.1, 0.1+0.4·strength)
- TRAJ-3 rank 衰减：strength=(10−rank)/10；path opacity = max(0.1, 0.1+0.9·strength)
- TRAJ-4 apex 绿点
- TRAJ-5 抛体当前位置 = 轨迹最新点（同一 DataPoint，禁止双轨）

### 2.6 大炮交互（AC-CANNON）
- CANNON-1 拖 barrel tip 改角：相对炮基向量的夹角；snap 5°（Lab 1°）；范围 [-90,90]；height<4 时下限 [5,-5,-20,-40] 分段（CannonNode:60,414-416）
- CANNON-2 拖 base/cylinder/高度标签 改高：snap 1m，[0,15]
- CANNON-3 角度读数 "{v}°"（2 位小数）显示于十字线旁；高度读数 "{v} m" 于 tip 上方
- CANNON-4 Intro（height 初值 10≠0）显示高度 cue 箭头

### 2.7 测量工具（AC-TOOL）
- TOOL-1 Toolbox 含 DataProbe + MeasuringTape 图标；拖出激活、拖回停用
- TOOL-2 MeasuringTape：base/tip 可拖，米单位，2 位有效数字；dragBounds = 可见区内缩 20px
- TOOL-3 DataProbe：十字吸附最近可读点（apex / 地面 / 整 100ms 点），半径 0.2m/zoom；显示 time/range/height 各 2 位小数，无数据 "—"

### 2.8 Zoom（AC-ZOOM）
- ×2 / ÷2，范围 [0.25, 2]，默认 1；MVT scale = 30·zoom px/m，view origin 恒 (70,510)

## 3. 各屏规格

### 3.1 Intro
- 默认：PUMPKIN，h=10，θ=0°，v=15，阻力 off
- topRight：物体 ComboBox（9 种）+ 只读 Mass/Diameter + AirResistance checkbox（Cd 只读，关时半透明）
- bottomRight：Velocity Vectors（Total/Components checkbox，默认全关）+ Acceleration Vectors（Total/Components，默认全关）；无 force
- 无向量显示枚举；向量开关独立

### 3.2 Vectors
- 默认：COMPANIONLESS（5kg/0.8m/0.47），h=0，θ=80°，v=18，阻力 **on**
- topRight：标题+Cd=0.47 形状预览 + Diameter [0.1,1] step 0.1 + Mass [1,10] step 1 + AirResistance（Cd 只读）
- bottomRight：Total/Components 单选（默认 TOTAL）+ Velocity / Acceleration / Force 三个 checkbox（默认全关）
- 抛体带 FreeBodyDiagram 能力（forceVectorsOn 时）

### 3.3 Drag
- 默认：COMPANIONLESS，h=0，θ=80°，v=18，阻力 **恒 on**（无开关）
- topRight：Drag Coefficient slider [0.04,1] step 0.01（带形状图标）+ Diameter [0.1,1] + Mass [1,10] + Altitude [0,5000] snap 100
- bottomRight：Total/Components + Velocity + Force（**无 Acceleration**）
- altitude 1500–1700 → Flatirons 显示

### 3.4 Lab
- 默认：CANNONBALL，h=0，θ=80°，v=18，阻力 off；角度 snap 1°
- topRight：InitialValuesPanel 只读（Height / Cannon Angle / Speed）
- bottomRight：物体 ComboBox（Custom + 9 预设）+ Mass / Diameter / Gravity [1,20] step 0.01 / Air Resistance / Altitude（阻力关时禁用半透明）/ Drag Coefficient
- 非 Custom：m/D/g/altitude 用 slider+箭头；Cd 只读文本
- Custom：全部可编辑，NumberDisplay + 铅笔按钮 → Keypad（Enter 提交 2 位小数、越界红字、点遮罩取消）

## 4. 视图核心数值

| 项 | 值 |
|---|---|
| layoutBounds | 1024×618，底部对齐 |
| MVT | origin (70,510)，30 px/m × zoom，y 翻转 |
| 天空渐变 | #02ace4 → #cfecfc（顶部到 2/3 高） |
| 草地 | rgb(0,173,78)，路面高 20px 中心在 y=510，黄虚线 dash[10,10] 宽 1.5 |
| David | 2m @ (7,0) |
| 炮 | 视觉长 4m；底座椭圆 420×40（未缩放）；圆柱距原点 1.3m；高度标尺 x=-1.5m |
| 靶 | 三同心椭圆（红/白/红），宽 3m 高 0.6m，默认 x=15；读数 1 位小数 |
| 速度/加速度箭头标量 | 15（无单位）；力箭头标量 3 |
| 面板底色 | 右侧 rgb(255,238,218)；初值 rgb(235,235,235) |

## 5. 测试验收（对应 §PHASE1 AC）

- Physics：PHY-1..9 数值容差 1%；阻力单调减程；落地精确截断；apex 插值；reset 全复位
- Interaction：拖炮改角/高 snap 正确；target 水平拖；工具拖出/放回；fire 禁用逻辑；pause/resume/step；reset
- Lifecycle：open/dispose/reopen；Tab 切换状态保持（KratosTabSwitcher）
- Widget：4 屏 smoke + 关键控件存在性
