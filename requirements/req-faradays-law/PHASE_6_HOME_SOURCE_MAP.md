# PHASE 6 — HOME SOURCE MAP · Faraday's Law

## Existing Home Pattern → Faraday's Law

| Existing Home Pattern | Faraday's Law |
| --- | --- |
| Category | **物理 → 电磁学**（既有分组；与「磁铁与罗盘」并列） |
| Registration | `lib/screens/home_screen.dart` `_SimEntry` + `_buildFaradaysLaw` |
| Card | Material icon + title/subtitle/color（Home 统一策略） |
| Entry | **Direct** `FaradaysLawScreen`（同组 Magnet 模式；非 `*Home` 多屏壳） |
| Navigation | `_SimCard` → `Navigator.push(MaterialPageRoute)` |
| Back | Screen `AppBar` leading → `Navigator.pop` → Home |
| Dispose | PlayArea: `SimulationClock.dispose` + `removeListener`; Screen: dispose owned `FaradaysLawModel` |
| Re-entry | New `FaradaysLawScreen()` → new `FaradaysLawModel()` → source initial |

## Why 电磁学

- Home 已有「电磁学」；当前仅「磁铁与罗盘」。
- Faraday's Law = 磁铁相对线圈运动 → 感应 EMF；属电磁感应，不属「电学与电路」。
- **禁止**新建「法拉第」等 category。

## Ownership

| Concern | Owner |
| --- | --- |
| Model create | `FaradaysLawScreen` (`widget.model ?? FaradaysLawModel()`) |
| Model dispose | Screen when it **owns** the model (Home path); injected test models not disposed |
| Clock | `FaradaysLawPlayArea` → one `SimulationClock` → `model.step(dt)` |
| Listeners | PlayArea `addListener` / `removeListener` on dispose |

## Anti-patterns avoided

- No `FaradaysLawModel.instance` / global singleton
- No second Home-level ticker
- No extra Intro/Lab screens (source Screens = 1)
- No duplicated physics in Home wrapper
