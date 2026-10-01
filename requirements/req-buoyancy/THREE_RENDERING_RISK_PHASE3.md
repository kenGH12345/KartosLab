# THREE_RENDERING_RISK_PHASE3

Renderer Capability: **ADAPTABLE**

KartosLab has no THREE / flutter_gl. PHASE 3 uses a **minimal source-faithful perspective adapter** plus a triangle painter. This is **not** a fake 2D Positioned scene.

| ID | Risk | Status | Notes |
| -- | ---- | ------ | ----- |
| R1 | Camera projection mismatch | OPEN P1 | FOV 50 assumed (THREE default); mobius internals not in repo |
| R2 | World/view transform mismatch | MITIGATED | lookAt / up (0,0,-1) / zoom / viewOffset implemented |
| R3 | Depth/occlusion mismatch | OPEN P1 | painter’s algorithm, no GL depth buffer |
| R4 | Mesh geometry loss | MITIGATED | duck/boat from source; bottle lathe not full saddle mesh |
| R5 | Texture mapping mismatch | OPEN P2 | albedo files extracted; painter uses vertex color fallback |
| R6 | Pointer ray conversion | MITIGATED | ray ∩ z=0 (source uses hit-z plane after mesh t) |
| R7 | Dynamic waterline projection | MITIGATED | model fluidY quad |
| R8 | Boat/Bottle geometry fidelity | PARTIAL | boat ONE_LITER bounds match; bottle simplified vs full Bottle.ts |
| R9 | Performance | OPEN P2 | duck 958 tris redraw each tick; static meshes cached |
| R10 | Renderer capability mismatch | DOCUMENTED | MISSING real THREE; ADAPTABLE adapter in production path |
