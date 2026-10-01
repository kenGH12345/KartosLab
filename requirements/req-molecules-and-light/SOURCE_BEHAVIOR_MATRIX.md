# SOURCE_BEHAVIOR_MATRIX · Molecules and Light

Source: `js/micro/model/molecules/*.js` `setPhotonAbsorptionStrategy` calls. Missing strategy means the photon is not absorbed (transmission). When a strategy exists, absorption is probabilistic (default 0.5) and only if the molecule is not already holding a photon.

Hold strategies re-emit **the absorbed photon's wavelength** after 1.1–1.3 s. Changing the selected light source clears flying photons but does not rewrite `absorbedWavelength`.

| Molecule | Microwave | Infrared | Visible | Ultraviolet |
|---|---|---|---|---|
| CO | Rotation, re-emit microwave | Vibration, re-emit IR | transmit | transmit |
| N₂ | transmit | transmit | transmit | transmit |
| O₂ | transmit | transmit | transmit | transmit |
| CO₂ | transmit | Vibration, re-emit IR | transmit | transmit |
| CH₄ | transmit | Vibration, re-emit IR | transmit | transmit |
| H₂O | Rotation, re-emit microwave | Vibration, re-emit IR | transmit | transmit |
| NO₂ | Rotation, re-emit microwave | Vibration, re-emit IR | Excitation (glow), re-emit visible | Break apart (no re-emit) |
| O₃ | Rotation, re-emit microwave | Vibration, re-emit IR | transmit | Break apart (no re-emit) |

N₂ and O₂ constructors never call `setPhotonAbsorptionStrategy`.
