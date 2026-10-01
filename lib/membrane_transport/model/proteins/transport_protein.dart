import '../../membrane_transport_constants.dart';
import '../membrane_transport_model.dart';
import '../mt_vec2.dart';
import '../particle.dart';
import '../particle_mode.dart';
import '../slot.dart';
import '../solute_type.dart';
import '../transport_protein_type.dart';

/// Base transport protein — PhET `TransportProtein.ts`.
abstract class TransportProtein {
  TransportProtein({
    required this.model,
    required this.type,
    required this.position,
    required String initialState,
    required List<String> openStates,
  })  : state = initialState,
        _openStates = openStates;

  final MembraneTransportModel model;
  final TransportProteinType type;
  final double position;

  String state;
  final List<String> _openStates;
  double timeSinceStateTransition = 0;

  bool get isOpen => _openStates.contains(state);

  Slot? get slotOrNull {
    for (final s in model.membraneSlots) {
      if (s.transportProtein == this) return s;
    }
    return null;
  }

  Slot get slot {
    final s = slotOrNull;
    if (s == null) {
      throw StateError('Transport protein not in a slot');
    }
    return s;
  }

  void setState(String newState) {
    if (state != newState) {
      state = newState;
      timeSinceStateTransition = 0;
    }
  }

  void step(double dt) {
    timeSinceStateTransition += dt;
  }

  bool hasSolutesMovingTowardOrThrough({
    bool Function(MtParticle)? predicate,
  }) {
    final pred = predicate ?? (_) => true;
    return model.solutes.any((p) {
      final m = p.mode;
      return m.slot == slotOrNull && pred(p);
    });
  }

  bool isAvailableForPassiveTransport(
    SoluteType soluteType,
    MembraneSide location,
  );

  void clearSolutes(Slot slot) {
    for (final p in List<MtParticle>.from(model.solutes)) {
      if (p.mode.slot == slot) {
        p.releaseFromInteraction(p.position.y > 0 ? 20 : -20);
      }
    }
  }

  void clear(Slot slot) {
    clearSolutes(slot);
    // Subclasses may reset state
  }

  void dispose() {}
}

/// Convenience: binding site offset from image metrics (Phase 2 approximate).
MtVec2 bindingOffsetFromImage({
  required double imageW,
  required double imageH,
  required double siteX,
  required double siteY,
}) {
  final viewDx =
      -(imageW / 2 - siteX) * MembraneTransportConstants.overallArtworkScale;
  final viewDy =
      -(imageH / 2 - siteY) * MembraneTransportConstants.overallArtworkScale;
  return MtVec2(
    viewDx / MembraneTransportConstants.mvtScale,
    -viewDy / MembraneTransportConstants.mvtScale, // inverted Y
  );
}
