# GOLDEN_MATRIX — Deterministic Visual / Data Goldens

规则：Golden **必须** deterministic — fixed seed、fixed dt、fixed clock、禁用 unguarded Random / wall timer。

---

## Experiment

| ID | Setup |
|---|---|
| E-def | default photons |
| E-ph / E-el / E-n / E-he | each particle default |
| E-ss-L / E-ss-R | single slit covered |
| E-ds | bothOpen |
| E-det-L / E-det-R / E-det-both | which-path |
| E-int | intensity mode |
| E-hits | hits mode（seeded N hits） |
| E-graph-int / E-graph-hits | graph open |
| E-snap | 1–4 snapshots dialog |
| E-ruler | ruler visible + zoom levels |
| E-λ-short/mid/long | wavelength sweep |
| E-d-min/max | slit sep sweep |
| E-L-min/max | screen distance sweep |

---

## High Intensity

| ID | Setup |
|---|---|
| H-def | default |
| H-wave-amp / H-wave-E / H-wave-real | display modes |
| H-ss / H-ds / H-none | slit / no barrier |
| H-det | which-path layers |
| H-int / H-hits | detection modes |
| H-graph | side graph |
| H-pause / H-step | time |
| H-zoom | graph zoom |
| H-snap | snapshots |
| H-λ / H-sep | sensitivity |

---

## Single Particles

| ID | Setup |
|---|---|
| S-def | default |
| S-auto | auto-fire accumulation seeded |
| S-one | single packet mid-flight |
| S-ss / S-ds / S-none | slits |
| S-probe-ready | probe overlay + % |
| S-probe-yes / S-probe-no | detect outcomes（forced RNG） |
| S-hits / S-hist / S-graph | detector + graph |
| S-snap | snapshots |
| S-pause / S-step / S-fast | time |

---

## Determinism harness requirements

```text
Random seed fixed
SimulationClock fixed dt
initial state factory
disable flash animations OR freeze time for golden
compare PDF arrays / hit hashes / PNG with tolerance
```