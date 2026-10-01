# PHYSICS_VALIDATION — Gravity Force Lab: Basics

## Formula [已确认]

```
G = 6.67430e-11
F = G * m1 * m2 / r^2
r = |x2 - x1|   // meters, center-to-center
```

## Radius [已确认]

```
radius(m) = (3*m / (4*pi*density))^(1/3)
density = 1.5
CONSTANT_RADIUS = radius(1e9)  // ≈ 541.9261846 m
```

## Test cases

### A. Default
- m1=2e9, m2=4e9, r=4000
- F = 6.67430e-11 * 8e18 / 1.6e7 = **33.3715** N
- Display `toFixed(1)` → **33.4** N
- Distance label → **4 km**

### B. r × 2 → F / 4
- r=8000 → F = 8.342875 N

### C. m1 × 2 → F × 2
- m1=4e9 → F = 66.743 N

### D. m2 × 2 → F × 2
- m2=8e9 → F = 66.743 N

### E. m1 = m2 = 2e9, r=4000
- F = 16.68575 N；箭头等长反向

### F. Directions
- mass1 受力向右（朝 mass2）；mass2 向左

### G. Near-zero
- assert r > 0；min centers = r1+r2+200

### H. Constant Size
- ON：两球 radius == CONSTANT_RADIUS（任意 mass）
- OFF：radius 随 mass 变化

Tolerance：相对误差 ≤ 1e-9（双精度）；显示比较用 1 位小数。
