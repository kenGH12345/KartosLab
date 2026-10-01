# PHASE 2 — VIEWPORT REPORT · Faraday's Law

## Source viewport

| Item | Value |
|------|-------|
| `LAYOUT_BOUNDS` | 0..834 × 0..504 |
| ScreenView layout | fixed custom bounds (not default 1024×618) |
| Background | `#97D0FF` |

## Flutter viewport

| Item | Value |
|------|-------|
| Logical play area | `SizedBox(834 × 504)` |
| Fit | `FittedBox(fit: BoxFit.contain)` inside `SafeArea` |
| Transform | Identity MVT in layout space (`FaradaysLawMvt`); scale only via FittedBox |

## Coordinate mapping

```text
Pointer (global)
  → layoutKey.globalToLocal
  → model.moveMagnetToPosition(layoutPoint - grabOffset)
  → magnet.position (layout coords)
  → Positioned widgets / CustomPainters
```

All of magnet / coil / bulb / voltmeter / field lines / wires share **one** 834×504 coordinate system. No per-component scale hacks.

## Clock

`SimulationClock(fps: 60)` → `model.step(dt)` → `notifyListeners` → rebuild.  
`autoStartClock: false` for widget tests.
