# Phase 4 Report — Model / State

> 2026-09-10

## PHASE: 4 — Model / State
## STATUS: PARTIAL → CONTINUING（核心 SSOT 已落地；Beaker/EC balance/完整元件仍迭代）

### 1. Completed

- `EfacConstants` 对齐 `EFACConstants.ts`（含 ENERGY_PER_CHUNK 公式，数值 ≈ 5019.02 J）
- `EnergyType` / `EnergyContainerCategory` / `HeatTransferConstants`
- `Burner` / `ThermalBlock` / `Air`（Intro 热核）
- `EfacIntroModel`：stepModel（burner→block、block↔block、block↔air）、linked heaters、reset、FF×4
- `SystemsModel` + `EnergyCarousel`：默认 Biker/Generator/BeakerHeater；Source→Converter→User 能量量；类型不匹配归零；pause 时 carousel 仍 step
- Controllers + `SimulationClock`
- Unit tests：constants / intro / systems

### 2. Files changed（主要）

- `lib/energy_forms_and_changes/**`（新建）
- `assets/energy_forms_and_changes/*.png`（105，从 `*_png.ts` 解码）
- `pubspec.yaml`（注册 assets）
- `test/energy_forms_and_changes/*`

### 3. Evidence

- `[已确认]` ENERGY_PER_CHUNK 公式与单测锁定数值
- `[已确认]` Systems pipeline 类型 gating（sun+generator=0；sun+solar=0.68）
- `[已确认]` Air SH=1012、density=10（Air.ts）
- `[待确认]` Intro 接触长度用 AABB overlap proxy（完整 thermalContactLength 待对齐 RTMME）
- `[待确认]` Beaker / thermometer / EC wander 未入本轮 stepModel

### 4. Tests

`flutter test test/energy_forms_and_changes` → **16 passed**

### 5. Analyze

`flutter analyze lib/energy_forms_and_changes` → **0 error / 0 warning / 3 info**

### 6. Visual status

骨架屏已挂（Phase 5 并行）；非视觉完成

### 7. Blocked

无

### 8. Known limitations

- Intro 缺 beakers、EC balance 转移、fall/snap、温度计
- Systems 能量量为简化版（非完整 chunk path / 元件内部状态机）
- scenery-phet `flame_png` / HeaterCooler / FaucetNode 缺失（D 类）

### 9. Next phase

Phase 5 静态渲染加深（MVT 定位、原版 asset 摆位）+ Phase 4 补 Beaker
