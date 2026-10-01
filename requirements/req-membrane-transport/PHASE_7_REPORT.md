# PHASE 7 REPORT — Final Technical / Android Verification

> req-membrane-transport · 2026-09-29  
> Device: **Pixel Tablet emulator-5554** · Android 15 (API 35)  
> Entry: `lib/membrane_transport/debug_membrane_transport_main.dart`（**非** KartosLab Home）  
> Artifacts: `requirements/req-membrane-transport/android-qa/mt7_*.png`

---

## Verdict Summary

| Gate | Result |
|------|--------|
| Full Tests | **PASS** · 62/62 |
| Analyze | **CLEAN**（仅既有 info×1 + warning×1；无 Phase 7 新增） |
| Debug Build | **PASS** · `app-debug.apk` |
| Release Build | **PASS** · `app-release.apk` 89.5MB |
| Android Launch | **PASS** |
| Facilitated Android | **PASS** |
| Active Android | **PASS** |
| Playground Android | **PASS** |
| Simple Diffusion Android | **PASS** |
| Android Touch / Tabs | **PASS** |
| Android Drag | **PASS**（adb swipe + model 单元已覆盖；见注） |
| Android Valid / Invalid Drop | **PASS** |
| Android Snap / Swap / Replace | **PASS**（model + UI session） |
| Android Remove | **PASS** |
| Android Reset During Drag / Transport | **PASS** |
| Android Rapid Interaction / Re-entry | **PASS** |
| Android Back | **PASS***（*debug 入口无 Home 栈 → Back 回 Launcher，符合预期至 Phase 8） |
| Android Lifecycle | **PASS**（无 ANR；切 tab / Back 正常） |
| Android Performance | **PASS**（冷启 skipped frames；稳态无卡死） |
| Android Memory | **PASS**（smoke 无崩溃；listener 随 dispose） |
| Asset Runtime | **PASS**（膜/控件可见）· SVG fill 见 P2 |
| Asset Packaging | **PASS** · release APK 内 **35** membrane SVG |
| Science / Layout Regression | **PASS** |
| Golden | **10 / 10** |
| Golden Determinism | **PASS** |
| Tests | Previous 62 · Added 0 · Final **62 PASS** |
| P0 | **0** |
| P1 | **0** |
| P2 | **4**（见下） |
| Android Runtime | **VERIFIED** |
| Home | **NOT STARTED** |
| **Status** | **READY CANDIDATE** |

---

## Builds

```
flutter build apk --debug   → Built …/app-debug.apk
flutter build apk --release → Built …/app-release.apk (89.5MB)
APK membrane SVG entries    → 35
```

Debug entry（不接 Home）:

```
flutter run -t lib/membrane_transport/debug_membrane_transport_main.dart -d emulator-5554
```

---

## Android smoke evidence

| File | Purpose |
|------|---------|
| `android-qa/mt7_01_launch.png` | Launch · Simple Diffusion |
| `mt7_02_facilitated.png` | Facilitated tab |
| `mt7_03_active.png` | Active tab |
| `mt7_04_playground.png` | Playground tab |
| `mt7_06..13` | drag / reset sequence |
| `mt7_14_after_back.png` | Back → launcher |

---

## Analyze note

```
info     particle.dart prefer_initializing_formals   (pre-existing)
warning  particle_mode.dart unnecessary_cast         (pre-existing)
```

Phase 6 `notifyListeners` 外泄已改为 `notifyAfterSlotMutation()`。

---

## P2 remaining

1. SVG `<style/>` → flutter_svg 警告；Android 上部分图标/细胞图呈黑色剪影（非崩溃）  
2. Material Eraser / Play icons  
3. 非 PhetFont  
4. `fitScale` max **1.0** → 大平板 letterbox 较大（触控仍可用；非本阶段改布局）

---

## Next

**PHASE 8 — Home Integration**（生物 · 细胞膜运输 · card）  
然后 PHASE 9 Final QA。  
**不在本阶段宣布最终 READY。**
