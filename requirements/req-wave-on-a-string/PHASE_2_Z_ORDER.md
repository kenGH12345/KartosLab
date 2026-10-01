# PHASE 2 — Z-ORDER

Back → front (`WoasPlayArea` Stack):

```text
1  ColoredBox background #FFFFB7
2  WoasCenterLine          (equilibrium dash)
3  WoasEndNode             (clamp / ring+post / windowBack)
4  ReferenceLine           (if visible)
5  String + 61 beads       (RepaintBoundary + CustomPainter)
6  WoasStartNode           (wrench / wheel / pulse)
7  WoasWindowFront         (No End only — above string)
8  Rulers overlay          (if visible)
9  Stopwatch overlay       (if visible)
```

Source notes preserved:

- Window back behind string; window front above string.
- Center dash ≠ Reference Line tool.
- StartNode above string (wrench grips bead 0).
