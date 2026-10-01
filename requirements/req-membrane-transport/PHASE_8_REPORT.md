# PHASE 8 REPORT — Home Integration

**Status:** READY CANDIDATE  
**Date:** 2026-09-29  
**Scope:** Formal KartosLab Home entry only（不改 sim 核心）

---

## Architecture audit

见 `HOME_INTEGRATION_MAP.md`。

| Decision | Choice |
|----------|--------|
| Discipline | **物理**（Home 无「生物」一级学科） |
| Group | **热学与气体**（紧随 Diffusion） |
| Title | `Membrane Transport` |
| Icon | 原版 `simple_diffusion_home_icon.svg` |
| Route | `Navigator.push` → `MembraneTransportHome` |
| Debug entry | 保留 `debug_membrane_transport_main.dart`，**不**出现在 Home |

---

## Code changes

| File | Change |
|------|--------|
| `lib/screens/home_screen.dart` | 新增 `_SimEntry` + `_buildMembraneTransport` |
| `lib/membrane_transport/screens/membrane_transport_home.dart` | `subtitle` / `homeIconAsset`；`tabBarIsScrollable: true` |
| `lib/common/widgets/kratos_tab_bar.dart` | 可选 `tabBarIsScrollable`（默认 false） |
| `lib/membrane_transport/layout/membrane_transport_layout.dart` | 补齐其余 `*_home_icon` 常量 |
| `requirements/.../HOME_INTEGRATION_MAP.md` | 新建 |
| `requirements/.../VISUAL_ASSET_AUDIT.md` | Home Icon = Original |

**未改：** MembraneModel / Particle / Transport / Drag / LayoutComposer / MT5 Goldens。

---

## Tests

| Suite | Result |
|-------|--------|
| `test/membrane_transport`（含 home） | **73 PASS**（Previous 62 + 11） |
| Home Golden | **MT8-H-01 / MT8-H-02** = 2 / 2 |
| MT5 Golden regression | **10 / 10** |

新增：

- `test/membrane_transport/home/membrane_transport_home_integration_test.dart`（9）
- `test/membrane_transport/home/membrane_transport_home_golden_test.dart`（2）

---

## Analyze

相对 Phase 7：仅既有 `prefer_initializing_formals` info + `unnecessary_cast` warning。无新增 issue。**CLEAN**。

---

## Release Build

`flutter build apk --release` → **PASS**（40.9MB）。APK 含 `Membrane Transport` 字符串 + 35 membrane SVGs。

---

## Android Home Smoke

Device: Pixel Tablet `emulator-5554`（debug `lib/main.dart`）。

证据：`requirements/req-membrane-transport/android-qa/home/mt8_C*.png`

| Step | Result |
|------|--------|
| Home → 热学与气体 → Membrane Transport card | PASS（C02） |
| Tap card → Membrane Transport (4 tabs) | PASS（C03） |
| Facilitated / Active / Playground / Simple Diffusion tabs | PASS（C04） |
| AppBar Back → Home | PASS（C05） |
| Re-entry ×5 (MT → Active → Back) | PASS |
| Peer QWI visible on same Home view as MT | PASS（C02 同屏） |
| Existing Diffusion unit peer regression | PASS（desktop test） |

Home icon 黑剪影 = 既有 P2（SVG `<style/>`），非阻断。

---

## P0 / P1 / P2

| Level | Count |
|-------|-------|
| P0 | 0 |
| P1 | 0 |
| P2 | 4（SVG style/黑剪影；Material Eraser/Play；非 PhetFont；letterbox） |

---

## Gates

| Gate | Status |
|------|--------|
| Home Architecture | PASS |
| Category / Card / Icon / Route / Entry | PASS |
| Back / Re-entry / Lifecycle | PASS |
| Home Golden | 2 / 2 |
| Membrane Regression | PASS |
| Android Home / Back / Re-entry | PASS |
| Release Build | PASS |
| Home | **INTEGRATED** |
| Final READY | **NOT**（留给 PHASE 9） |

---

## Next

**PHASE 9 — FINAL QA / FINAL REGRESSION**
