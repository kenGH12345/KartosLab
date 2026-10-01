# PHASE 9 REPORT — Final QA / Final Regression

**FINAL STATUS: READY**  
**Date:** 2026-09-29  
**Scope:** 封板验收 only（无新功能 / 无架构重构）

---

## Source Final Audit

| Item | Result |
|------|--------|
| FeatureSet enum ↔ PhET `MembraneTransportFeatureSet.ts` | **Aligned**（simple / facilitated / active / playground） |
| `hasProteins` / `hasVoltages` / `hasLigands` / solute ATP gating | **Aligned**（Flutter `membrane_transport_feature_set.dart`） |
| Phase 7/8 drift | **None**（未改 Model / Transport / Drag / LayoutComposer / assets） |
| Home entry | 物理 → 热学与气体 → Membrane Transport；唯一正式 route |

---

## Gates executed

| Gate | Evidence | Result |
|------|----------|--------|
| Full Tests | `flutter test test/membrane_transport` → **73 PASS** | PASS |
| Analyze | 既有 2 条（info + warning）；无新增 | CLEAN |
| Golden MT5 | 10 PNG 文件 + suite PASS | **10 / 10** |
| Home Golden | MT8-H-01/02 + suite PASS | **2 / 2** |
| Golden Determinism | `visual_golden_test` same seed ×3；behavioral same seed positions | PASS |
| Behavioral (drag/swap/reset/featureSet/voltage/ligands) | `behavioral_acceptance_test.dart` | PASS |
| Home path / re-entry×10 / peer Diffusion | home integration tests | PASS |
| Release APK | `flutter build apk --release` → 89.9MB；35 SVGs；home icon；`Membrane Transport` in libapp | PASS |
| Android Final | `android-qa/final/mt9_*`；tabs；re-entry×10；peer Diffusion；release open | PASS |
| Memory | dumpsys：PSS 323MB → 403MB after stress（debug）；无 ANR；ScreenBody dispose ticker+model | PASS |
| Performance | 无 ANR；触控/切 tab 可用；黑剪影为 P2 非卡顿 | PASS |
| Debug UI | `debug_membrane_transport_main` 不在 Home | PASS |

### Release note

首次与 `flutter run --debug` 并行时，`GeneratedPluginRegistrant` 误含 `integration_test` → release javac 失败。停止并行 run、删除 registrant 后重编 → **PASS**；再生 registrant **不含** integration_test。

---

## P2（保留，非阻断）

1. SVG `<style/>` / 黑剪影（含 Home icon / tab / particles）  
2. Material Eraser / Play  
3. 非 PhetFont  
4. 大平板 letterbox（`fitScale ≤ 1`）

Provenance 明确；正式用户路径（进入 / 四屏 / Back / Reset / 重入）可用。

---

## P0 / P1

| Level | Count |
|-------|-------|
| P0 | **0** |
| P1 | **0** |

---

## Artifacts

- `requirements/req-membrane-transport/android-qa/final/`（mt9_*.png、mem_*.txt）  
- Goldens：`test/membrane_transport/goldens/`（10）+ `home/goldens/`（2）  
- Release：`build/app/outputs/flutter-apk/app-release.apk`

---

## Stop condition

满足全部硬门禁 → **不再主动修改 Membrane Transport**，除非未来发现实际 P0/P1。
