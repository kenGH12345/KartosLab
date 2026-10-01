# BEHAVIORAL_EVIDENCE_PHASE8

> Evidence log for PHASE 8 behavioral acceptance.
> Suite: `test/quantum_measurement/phase8_behavior_test.dart` — **33 PASS**
> Full QM regression: **200 PASS** · Golden PNGs: **30** retained

| Case ID | Screen | User Action | Expected | Actual | Model State | View State | Pass/Fail | Evidence |
|---|---|---|---|---|---|---|---|---|
| C1 | Coins | Enter Classical default | preparing; no Flip | preparing; Flip absent | preparing=true | StartMeasurementButton | PASS | phase8 C1 |
| C2 | Coins | Start → Flip | measuredAndHidden | measuredAndHidden | classical.singleCoin | Flip control | PASS | phase8 C2–C4 |
| C3 | Coins | Reveal → Hide | revealed → hidden | same | measurementState | face/mask | PASS | phase8 C2–C4 |
| C4 | Coins | Flip and Reveal | revealed in one act | revealed | measurementState | face shown | PASS | phase8 C2–C4 |
| Q1 | Coins | Quantum Reprepare | readyToBeMeasured; no sample reveal until Observe | readyToBeMeasured | quantum.singleCoin | Reprepare | PASS | phase8 Quantum |
| Q2 | Coins | Observe | revealed after sample | revealed | measurementState | face | PASS | phase8 Quantum |
| Q3 | Coins | Reprepare and Observe | prepare→observe | revealed | measurementState | face | PASS | phase8 Quantum |
| CNT | Coins | 10/100/10000 | counts + 10k pixel canvas | same | numberOfCoins | CoinRenderMode | PASS | phase8 Count |
| PER | Coins | Classical↔Quantum | classical state retained | retained | classical.singleCoin | IndexedStack | PASS | phase8 persistence |
| RST-C | Coins | Reset All | Classical preparing default | same | experimentMode classical | preparing UI | PASS | phase8 Reset |
| P1 | Photons | Single via source | one resolution path | count+1 via emitAndResolve | detectors | PhotonSourceNode | PASS | phase8 P1 |
| P-CQ | Photons | Classical↔Quantum radios | mode sync | mode sync | photonBehaviorMode | Behavior radios | PASS | phase8 mode |
| P-CONT | Photons | rate>0 → rate=0 | no new photons after stop | length never increases | emissionRate=0 | spatial sim | PASS | phase8 Continuous |
| P-LIFE | Photons | Cont → leave screen | dispose; no screen | disposed | — | findsNothing | PASS | phase8 leave |
| P-CS | Photons | Cont → Single | singlePhoton mode | singlePhoton | experimentMode | radios | PASS | phase8 Cont→Single |
| S-EXP | Spin | Exp 1→2→Custom | experiment updates | same | model.experiment | ExperimentSelector | PASS | phase8 selector |
| S-1 | Spin | Single fire | exactly 1 particle + count | 1 particle | sternGerlachs counts | sim | PASS | phase8 Single |
| S-BLK | Spin | Cont multi → Block ↓/↑ | blockingMode changes | blockDown then blockUp | sternGerlachs[0] | Block chips | PASS | phase8 Block + Wrap fix |
| S-SW | Spin | Cont particles → applyExp | particles cleared | empty | experiment4 | clear() | PASS | phase8 switch |
| S-LIFE | Spin | leave screen | disposed | disposed | — | findsNothing | PASS | phase8 dispose |
| B-PRE | Bloch | dropdown +X…−Z | spinState + polar | all six | spinState | DropdownButton | PASS | phase8 Presets |
| B-OBS | Bloch | Observe then Erase | counts 0; polar kept; ≠ Reset | same | observed + erase | Erase vs Reset All | PASS | phase8 Erase |
| B-MF | Bloch | B-field TIMING → step | observed via elapsed | observed | timing→observed | anim.stepFixed | PASS | phase8 Magnetic |
| B-FPS | Bloch | 60fps vs 120fps dt | same φ | φ equal 1e-9 | ComplexBlochSphere | — | PASS | phase8 FPS |
| B-REP | Bloch | Observe→Reprepare→Observe | count=2 | count=2 | measurementState | buttons | PASS | phase8 Repeated |
| X-ISO | Cross | mutate 4 models; reset Coins | others unchanged | unchanged | isolated | — | PASS | phase8 isolation |
| X-RAP | Cross | switch widgets ×10 | no crash | no crash | dispose each | — | PASS | phase8 rapid |
| R-P | Reset | Photons reset mid-stream | photons empty rate0 | same | sim.reset | — | PASS | phase8 reset Cont |
| R-S | Reset | Spin clear+reset | empty + Exp1 | same | model.reset | — | PASS | phase8 |
| R-B | Reset | Bloch TIMING → Reset | prepared; B-field off | same | model.reset | — | PASS | phase8 |
| SPAM | Edge | Flip×5 / Observe spam | no crash; Reprepare shown | same | states valid | controls | PASS | phase8 spam |
| SEED | Seed | Bloch Observe ×3 seed77 | identical outcomes | identical | polar/counts | — | PASS | phase8 seeded |
| JOURNEY | Full | Coins→Photons→Spin→Bloch→Reset | long path OK | OK | all screens | leave OK | PASS | phase8 journey |
| LIFE-U | Ctrl | Photon/Spin/Bloch anim dispose | isRunning=false | false | controllers | — | PASS | phase8 unit |

## Fix applied during PHASE 8 (interaction geometry only)

| Issue | Severity | Fix |
|---|---|---|
| SG0 Block chips `RenderFlex` overflow (~82px); `Block ↓` untappable | P1 hit-target | `stern_gerlach_apparatus.dart`: widen box + `Wrap` for blocker chips |

No Model math changes. No LayoutSpec / Golden redesign.
