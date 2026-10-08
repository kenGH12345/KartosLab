# ANDROID_ZH_SCREEN_MATRIX

> PHASE 8 · Device: Pixel Tablet `emulator-5554` · Android 15 / API 35 · 2560×1600 · density 320 · landscape

Evidence root: `requirements/localization/android_evidence/`  
Runtime harness: `integration_test/phase8_android_zh_runtime_test.dart` (PASS 5/5)

| Domain | Simulation | Screen | Entry | Touch | Layout | CJK | A11y | Reset | Lifecycle | Result |
|---|---|---|---|---|---|---|---|---|---|---|
| — | home | catalog | PASS | PASS | PASS | PASS | PASS* | N/A | PASS (bg/resume) | PASS |
| Mechanics | collision-lab | intro | PASS | PASS (drag) | PASS | PASS | PASS* | PASS | PASS | PASS |
| Mechanics | forces | home entry | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Mechanics | vector-addition | home entry | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Fluids | buoyancy | Compare/Explore/Lab/Shapes/Applications | PASS | PASS (tabs+drag) | PASS | PASS | PASS* | PASS | PASS | PASS |
| Fluids | density | home entry | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Gases | gas-properties | home entry | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Electricity | circuit | builder | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Electricity | cck-ac-virtual-lab | AC lab | PASS | PASS | PASS† | PASS | PASS* | PASS | PASS | PASS |
| Optics | optics | home entry | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Waves | wave-interference | home entry | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Waves | fourier-making-waves | Discrete | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Quantum | quantum-measurement | home→tabs | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Quantum | quantum-wave-interference | home entry | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Chemistry | molarity | screen | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Chemistry | ph-scale | screen | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Chemistry | acid-base-solutions | Intro | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Chemistry | balancing-chemical-equations | home entry | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Chemistry | states-of-matter | States | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Chemistry | build-an-atom | home entry | PASS | PASS | PASS | PASS | PASS* | PASS | PASS | PASS |
| Chemistry | molecule-shapes / molecules-and-light | catalog visible | PASS | — | PASS | PASS | PASS* | — | — | PASS‡ |

\* Material `BackButton` system tooltip remains English `"Back"` (P2 chrome).  
† Prior CJK toolbox ellipsis remediation retained.  
‡ Catalog Chinese confirmed in Android screenshots (`10_molarity_enter` / chemistry scroll evidence).

## Cold-start note

Impeller/Vulkan on this emulator previously hung Splash (`firstWindowDrawn=false`).  
Remediation: `EnableImpeller=false` in `AndroidManifest.xml` → cold start Status=ok (~2.5–5s).
