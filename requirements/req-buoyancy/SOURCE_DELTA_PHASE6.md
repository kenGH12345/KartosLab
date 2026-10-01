# SOURCE_DELTA_PHASE6.md

## Reference policy

| Source | Used? |
|--------|-------|
| User-provided PhET screenshots | **Not attached this turn** |
| `phet.colorado.edu/.../latest` | **NOT used** as pixel truth (version may ≠ 1.3.0-dev.2) |
| Local package 1.3.0-dev.2 + common `0c835c64` | **Primary** |
| Flutter goldens 1024×618 | Regression lock |

**REFERENCE VERSION = LOCAL 1.3.0-dev.2** (not latest CDN).

## Per-screen structural Δ

| Screen | Camera / framing | Objects / scale | Waterline | Controls / Reset | Result |
|--------|------------------|-----------------|-----------|------------------|--------|
| Compare | lookAt (0,-0.1,0) + offset (−25,0) | two blocks L/R | pool fluidY | mode radios + ResetAll L0 | STRUCTURAL PASS |
| Explore | lookAt (0,-0.18,0) | wood/alum blocks | pool fluidY | one/two + material | STRUCTURAL PASS |
| Lab | same default cam | lab block + force UI | pool fluidY | gravity radios | STRUCTURAL PASS |
| Shapes | same | 7 shapes; duck mesh | pool fluidY | shape selector | STRUCTURAL PASS |
| Applications | same | bottle/boat source meshes; cabin fluidY | pool + cabin | mode icons + interior slider | STRUCTURAL PASS |

## Pixel vs live PhET

**Not claimed.** Without version-matched captures, pixel Δ remains unmeasured. Structural/source-fact gate is the PHASE 6 closure criterion.

## Source Δ status

**PASS (structural / source-fact)** — no longer P1.  
Pixel-vs-CDN remains out of scope until version-matched screenshots exist.
