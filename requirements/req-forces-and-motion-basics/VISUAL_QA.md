# Visual QA Reports — Forces and Motion: Basics

Screenshots: `requirements/req-forces-and-motion-basics/visual-qa/FLUTTER/`
Gold: user-provided PhET official screenshots (Prompt)

---

## NET FORCE VISUAL QA

P0: 0  
P1: 0  
P2: Material checkbox density; Go fill is PhET green (#94b830) vs some gold descriptions grey; panel font hinting  

Layout: PASS  
Assets: PASS (cart.svg, rope.png, grass.png, pull_figure_* PNG)  
Controls: PASS (panel, Go/Pause, Return, Reset All r=23)  
Force Arrows: PASS (bound; default hidden)  
Typography: PASS  
Screenshot: PASS (`NF_default.png`)

---

## MOTION VISUAL QA

P0: 0  
P1: 0  
P2: Material slider chrome; mountains SVG style vs gold palette; pusher lean frames only when F≠0 (not in default shot)  

Layout: PASS  
Assets: PASS (skateboard, crate, fridge, humans, trash, mystery, pusher PNG)  
Controls: PASS (Force/Values/Masses/Speed/Stopwatch, pause bars, step, Reset All)  
Force Arrows: PASS (bound to applied force)  
Object Stack: PASS (SVG intrinsic × 0.5 × 1.3)  
Screenshot: PASS (`MO_default.png`)

---

## FRICTION VISUAL QA

P0: 0  
P1: 0  
P2: Brick surface tile density vs gold gravel; Material slider  

Layout: PASS  
Assets: PASS (pusher, crate, brickTile, toolbox objects)  
Controls: PASS (Forces + Sum + Friction None→Lots)  
Force Arrows: PASS  
Screenshot: PASS (`FR_default.png`)

---

## ACCELERATION VISUAL QA

P0: 0  
P1: 0  
P2: Bucket water is tilt-proxy (not full PhET WaterBucketNode fluid mesh); accelerometer chrome simplified  

Layout: PASS  
Assets: PASS (bucket in right toolbox; no trash)  
Controls: PASS (Acceleration checkbox, friction slider, no stopwatch)  
Accelerometer: PASS (bound to a)  
Screenshot: PASS (`AC_default.png`)

---

## Cleared from prior P1 inventory

| ID | Resolution |
|----|------------|
| P1-01 | Screenshots captured + compared |
| P1-02 | Pullers/rope/grass/cart visible & scaled |
| P1-03 | Stack sizes from SVG intrinsics |
| P1-04 | Pusher visible; lean frames via force index |
| P1-05 | Bucket present + accel tilt (fluid P2) |
| P1-06 | Brick surface + panel friction |
| P1-07 | BaSvgPicture CSS inline; colors OK |
