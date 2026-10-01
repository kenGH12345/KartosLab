# RNG_SPEC — Quantum Measurement

> PHASE 1 · Source-aligned randomness

## Sources of randomness (from PhET TS)

| Event | Source API | Rule |
|---|---|---|
| Coin measurement sample | `dot.Random({ seed })` after `seedProperty` set | `nextDouble() < bias` → validValues[0] else [1] |
| Coin new seed | `dotRandom.nextDouble()` reject `0` | seed ∈ (0,1); `0`/`1` reserved |
| Photon PBS classical path | `dotRandom.nextDouble() <= P_reflect` | reflect → V, else H |
| Photon unpolarized angle | `dotRandom.nextDouble() * 360` | degrees |
| Photon emission spatial jitter | `dotRandom` | **visual only** (not in core QM Dart model) |
| Spin SG measure | `dotRandom.nextDouble() < upProbability` | |
| Bloch measure | `(dotRandom.nextDouble()*2-1) < n̂·r̂` | equivalent to P(up)=(1+dot)/2 |
| Coin flip animation axes | `dotRandom` | **visual only** |

## Flutter adapter

```dart
abstract class QmRandom {
  double nextDouble();
  double nextNonZeroDouble();
}
SeededQmRandom(int seed)           // tests
SeededQmRandom.fromUnitInterval(s) // CoinSet seedProperty path
SystemQmRandom()                   // production
```

**Policy:** Core measurement code never constructs bare `Random()` except inside `SystemQmRandom`.

**Bit-identity:** Flutter `math.Random` ≠ PhET `dot.Random` algorithm. Determinism tests require **same Flutter seed ⇒ same Flutter sequence**, not bit-match vs browser PhET.

## Determinism contract

```
same SeededQmRandom(seed)
+ same initial model state
+ same action sequence
= same measurement outcomes
```

Covered tests: Coins, Photons, Spin, Bloch.
