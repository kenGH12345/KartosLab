# BEHAVIOR_MATRIX_PHASE8

| Screen | Action | Model Effect | Visual Effect | Lifecycle | Result |
|---|---|---|---|---|---|
| Coins | Classical default | preparing=true | bias UI; no Flip | idle | PASS |
| Coins | Start Measurement | preparing=false | Flip/Reveal appear | — | PASS |
| Coins | Flip | prepare → hidden | masked coin | — | PASS |
| Coins | Reveal | revealed | face shown | — | PASS |
| Coins | Hide | measuredAndHidden | masked | — | PASS |
| Coins | Flip and Reveal | prepare+reveal | face shown | — | PASS |
| Coins | Quantum Reprepare | readyToBeMeasured | no sample | — | PASS |
| Coins | Quantum Observe | sample+reveal | face shown | — | PASS |
| Coins | Count 10/100/10000 | numberOfCoins | grid / 10k canvas | — | PASS |
| Coins | Classical↔Quantum | scenes independent | IndexedStack | persistence | PASS |
| Coins | Reset All | both scenes reset | default Classical | — | PASS |
| Photons | Single | emitAndResolveOne | count++ | one event | PASS |
| Photons | Classical | one path | detectors | — | PASS |
| Photons | Quantum | SPLIT return | counts | — | PASS |
| Photons | Continuous | emissionRate>0 | many photons | ticker | PASS |
| Photons | Stop | isPlaying=false / rate0 | no new | — | PASS |
| Photons | Cont→Single | mode switch | single scene | no leak | PASS |
| Photons | Leave Continuous | dispose ticker | — | cleanup | PASS |
| Spin | Exp 1–6+Custom | applyExperiment | apparatus | clear particles | PASS |
| Spin | Single fire | fireSingleParticle | 1 particle | — | PASS |
| Spin | Block ↑/↓ | blockingMode | branch hide | continuous multi | PASS |
| Spin | Continuous | Cont. + amount | stream | ticker | PASS |
| Spin | Exp switch @ Cont | clear+apply | new config | — | PASS |
| Bloch | +X…−Z | setSpinState | vector tip | — | PASS |
| Bloch | Observe | collapse | tip sync | — | PASS |
| Bloch | Observe×2 path | reprepare then observe | counts | — | PASS |
| Bloch | Magnetic Field | TIMING+step | precession | ticker | PASS |
| Bloch | Erase | resetCounts | hist empty | — | PASS |
| Bloch | Reset All | model.reset | +X | — | PASS |
| Cross | mutate all then tour | isolated models | — | isolation | PASS |
| Cross | rapid switch widgets | dispose each | — | no leak | PASS |
| Edge | Reset during Cont/B-field | reset APIs | cleared | — | PASS |
| Edge | spam Flip/Observe | source allows | no crash | — | PASS |
