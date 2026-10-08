# GLOBAL_ZH_HOME_REMAINDER

> PHASE 7B · Home entries vs Phase 2–6 migration batches

Home catalog size: **64** `HomeSimEntry` IDs in `lib/screens/home_disciplines.dart`.

| Home Entry | Registry ID | Target | User Visible | Chinese Status | Domain | Action |
|---|---|---|---|---|---|---|
| 力与运动：基础 | forces-and-motion-basics | ForcesHome | Y | Home ZH; UI = forces (already LOCALIZED) | mechanics | **B. ALREADY LOCALIZED** (alias→`forces`) |
| 曲线拟合 | curve-fitting | CurveFittingHome | Y | Home ZH; bag was EN → remediated ZH | math/mechanics | **A. MIGRATE** (7B done) |
| 弹珠概率 | plinko-probability | PlinkoProbabilityHome | Y | Home ZH; bag was EN → remediated ZH | math/mechanics | **A. MIGRATE** (7B done) |
| 电路搭建 | circuit | CircuitScreen | Y | Home ZH; in-sim already ZH | electricity | **B. ALREADY LOCALIZED** (registered 7B) |
| 几何光学 | optics | OpticsScreen | Y | Home ZH; in-sim already ZH | optics | **B. ALREADY LOCALIZED** (registered 7B) |
| 波的干涉 | wave-interference | WaveInterferenceScreen | Y | Home ZH; in-sim already ZH | waves | **B. ALREADY LOCALIZED** (registered 7B) |
| 黑体辐射光谱 | blackbody-spectrum | BlackbodySpectrumHome | Y | Home ZH; bag was EN → remediated ZH | thermal/optics | **A. MIGRATE** (7B done) |
| 能量形式与转化 | energy-forms-and-changes | EfacHome | Y | Home ZH; bag was EN → remediated ZH | energy | **A. MIGRATE** (7B done) |
| 浓度 (via BLL) | concentration | ConcentrationScreen | Y (BLL tab) | Not a Home card; tab was EN → remediated ZH | chemistry | **A. MIGRATE** (7B done) |
| Phase 2–6 modules (57) | (see migration_status) | various | Y | LOCALIZED pre-7B | domains | **B. ALREADY LOCALIZED** |

## Evidence notes

- All remainder entries are reachable: Home → card → simulation (except `concentration`, reached via Beers Law Lab tab).
- No INTERNAL / HIDDEN / REMOVE STALE entries identified in the current Home catalog.
- χ² in Curve Fitting remains scientific symbol (approved).

## Post-7B status

After remediation + `migration_status` registration: **Home NOT STARTED for user-facing cards = 0**.
