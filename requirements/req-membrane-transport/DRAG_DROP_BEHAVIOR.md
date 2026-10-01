# Membrane Transport · DRAG_DROP_BEHAVIOR

> PHASE 6 · Source audit  
> Evidence: `TransportProteinDragNode.ts`, `TransportProteinToolNode.ts`,  
> `ObservationWindow.ts`, `SlotDragIndicatorNode.ts`, `ObservationWindowTransportProteinLayer.ts`,  
> `MembraneTransportScreenView.ts`, `animateProteinReturn.ts`

---

## 1. Summary

| Item | Source behavior |
|------|-----------------|
| Drag source | Toolbox tool icon **or** placed protein in membrane |
| Drag ghost | Transient `TransportProteinDragNode` (copy); toolbox icon **stays** |
| Valid targets | 7 `SlotDragIndicatorNode` rects (65×105 view, center at slot model `(x,0)`) |
| Valid drop rule | Drag node `globalBounds` **intersects** indicator; pick **closest center** |
| Empty slot drop | `slot.transportProteinType = type` |
| Filled + from toolbox | **Replace**; old protein animates back to toolbox (0.4s) |
| Filled + from slot | **Swap** contents with origin slot |
| Invalid drop | Animate back to toolbox; if from slot, slot already cleared on pickup → protein removed |
| Pickup from membrane | `slot.clear()` **immediately**, then start drag with `origin = slot` |
| Keyboard / click toolbox | Leftmost empty slot, else **middle** slot (may replace) |
| Snap | Drop assigns exact slot.position via model; visual centers on slot |
| Slot count | **7** (`SLOT_COUNT`) — multiples of same type **allowed** |

---

## 2. Lifecycle

```
Idle
 → Press on toolbox icon / membrane protein
 → DragStart (create transient DragNode at pointer model pos)
 → Dragging (positionProperty ← pointer; slot indicators visible)
 → Hover slot (indicator highlight white / dark fill)
 → Drop:
      intersecting slot? → place / swap / replace
      else → animateReturnToToolbox (0.4s CUBIC_IN_OUT) → dispose
 → Placed | Returned
```

Escape / cancel: return to origin (toolbox or slot) — Flutter: pointer cancel / reset clears session.

---

## 3. Coordinate systems

| Space | Use |
|-------|-----|
| ScreenView MVT | DragNode position: model ↔ design (center (384,208), scale 2.67) |
| Observation MVT | Slot indicators & membrane proteins |
| Pointer | `globalToLocal` → MVT.viewToModel |

Flutter: design space inside FittedBox; drag uses design-local offsets → ScreenView MVT.

---

## 4. Slot indicator geometry `[已确认]`

```
size: 65 × 105 (observation view px)
corner radius: 15, 10
center: MVT.modelToView(slot.position, 0)
default visible: false (only while dragging)
highlight closest: stroke white, fill rgba(0,0,0,0.5)
others: stroke black, fill rgba(255,255,255,0.7)
```

---

## 5. Reset during drag

Source: `ScreenView.reset` → observation resetEmitter.  
Flutter: `model.reset()` + clear active `ProteinDragSession` (dispose ghost, hide indicators).

---

## 6. Flutter mapping

| Source | Flutter |
|--------|---------|
| TransportProteinDragNode | `ProteinDragSession` + overlay ghost |
| SlotDragIndicatorNode | painted in observation / overlay |
| createFromMouseDrag | `onProteinDragStart` from toolbox / membrane |
| animateProteinReturn | short AnimationController or Instant+fade (MVP: snap return OK if duration matched later) |
| Tool click → keyboard path | keep tap → leftmost empty / middle |

---

## STATUS: PASS (audit complete · implementation follows)
