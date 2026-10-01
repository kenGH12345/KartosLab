# STATE_MACHINE_AUDIT_PHASE8

## Coins (`ExperimentMeasurementState`)

```
preparingExperiment=true (prep UI)
        │ Start Measurement / New Coin reverse
        ▼
preparing=false
        │
        ├─ Classical Flip → preparingToBeMeasured → measuredAndHidden
        │                      Reveal → revealed ↔ Hide
        ├─ Classical Flip and Reveal → … → revealed
        ├─ Quantum Reprepare → readyToBeMeasured
        │                      Observe → revealed
        └─ Quantum Reprepare and Observe → ready… → revealed
```

**Illegal prevented**: Quantum Observe without prepare still works if already ready; Flip does not sample reveal on classical until Reveal.

## Photons

```
Idle (isPlaying)
  Single: emit one spatial photon → detectors
  Many: emissionRate drives continuous
  Classical/Quantum: photonBehaviorMode
Dispose: ticker stop, clear photons
```

## Spin

```
Idle (SourceMode.single|continuous)
  Single fire → particles → counts
  Continuous → stream while amount>0
  applyExperiment → clear particles + config
  Block modes only meaningful in continuous multi-SG
Dispose: ticker + clear
```

## Bloch

```
PREPARED ──Observe(B off)──► OBSERVED
   │ Start(B on)
   ▼
TIMING_OBSERVATION ──delay──► OBSERVED
OBSERVED ──Reprepare──► PREPARED
Erase: counts only (state unchanged)
Reset: full → +X PREPARED
```

## Divergence checks

| Risk | Mitigation |
|---|---|
| View shows result while Model not revealed | ClassicalCoinDisplay uses measurementState |
| Continuous off but ticker emits | emissionRate/isPlaying gated in step |
| Reset but particles remain | clear() on reset/dispose |
| Bloch tip stale after collapse | Multilink-style rebuild from model angles |
