import 'dart:ui' show Offset, Rect, Size;

import '../layout/membrane_transport_layout.dart';
import '../membrane_transport_constants.dart';
import '../model/slot.dart';
import '../model/transport_protein_type.dart';

/// Transient drag state — PhET `TransportProteinDragNode`.
class ProteinDragSession {
  ProteinDragSession({
    required this.type,
    required this.originSlot,
    required Offset initialModelPosition,
  }) : modelPosition = initialModelPosition;

  final TransportProteinType type;

  /// Null ⇒ originated from toolbox; non-null ⇒ dragged from this slot
  /// (slot already cleared on pickup).
  final Slot? originSlot;

  Offset modelPosition;

  /// ScreenView MVT: model (0,0) ↔ design (512, 208), scale mvtScale.
  static Offset modelToDesign(Offset model) {
    const cx = MembraneTransportLayoutPrimitives.designWidth / 2;
    final cy = MembraneTransportLayoutPrimitives.marginY +
        MembraneTransportLayoutPrimitives.obsHeight / 2;
    return Offset(
      cx + model.dx * MembraneTransportLayoutPrimitives.mvtScale,
      cy - model.dy * MembraneTransportLayoutPrimitives.mvtScale,
    );
  }

  static Offset designToModel(Offset design) {
    const cx = MembraneTransportLayoutPrimitives.designWidth / 2;
    final cy = MembraneTransportLayoutPrimitives.marginY +
        MembraneTransportLayoutPrimitives.obsHeight / 2;
    return Offset(
      (design.dx - cx) / MembraneTransportLayoutPrimitives.mvtScale,
      -(design.dy - cy) / MembraneTransportLayoutPrimitives.mvtScale,
    );
  }

  Offset get designCenter => modelToDesign(modelPosition);

  /// Protein artwork view size (TRANSPORT_PROTEIN_WIDTH × aspect).
  static Size get proteinViewSize {
    final w = MembraneTransportConstants.transportProteinWidth *
        MembraneTransportLayoutPrimitives.mvtScale;
    return Size(w, w * (900 / 650));
  }

  Rect get designBounds {
    final c = designCenter;
    final s = proteinViewSize;
    return Rect.fromCenter(center: c, width: s.width, height: s.height);
  }

  /// Slot indicator in design space — PhET `SlotDragIndicatorNode` 65×105.
  static Rect slotIndicatorDesign(Slot slot) {
    final obs = MembraneTransportLayoutSpec.observation;
    final local = MembraneTransportLayoutSpec.modelToObservationView(
      slot.position,
      0,
    );
    return Rect.fromCenter(
      center: Offset(obs.left + local.dx, obs.top + local.dy),
      width: 65,
      height: 105,
    );
  }

  /// Closest intersecting slot indicator, or null — PhET getClosestSlotDragIndicatorNode.
  static Slot? closestOverlappingSlot({
    required Rect dragBounds,
    required List<Slot> slots,
  }) {
    Slot? best;
    var bestDist = double.infinity;
    final dragCenter = dragBounds.center;
    for (final slot in slots) {
      final ind = slotIndicatorDesign(slot);
      if (!ind.overlaps(dragBounds)) continue;
      final d = (ind.center - dragCenter).distance;
      if (d < bestDist) {
        bestDist = d;
        best = slot;
      }
    }
    return best;
  }
}
