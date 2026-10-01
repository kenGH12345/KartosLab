# GLOBAL_Z_ORDER_AUDIT_PHASE7

| Screen | Back → Front (source-aligned) | Flutter | Status |
| --- | --- | --- | --- |
| Coins | scene fill → coins/test boxes → divider → controls → ResetAll | Stack: selector, IndexedStack scenes (divider in scene), ResetAll last | PASS |
| Photons | white → apparatus → photon sprites → panels/controls → ResetAll | scene Stack; PhotonRenderer over experiment region | PASS |
| Spin | white → SG bodies → particles → prep/controls → divider → ResetAll | particles after apparatus; divider overlay | PASS |
| Bloch | white → dashed divider → spheres (body→axes→vector) → controls → ResetAll | Painter: sphere, equator, axes, indicators, **vector last**; opacity depth only | PASS |

No overlay debug in production (`qmVisualDebugEnabled = false`).
