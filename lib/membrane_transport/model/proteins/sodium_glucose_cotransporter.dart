import '../membrane_transport_model.dart';
import '../particle.dart';
import '../particle_mode.dart';
import '../slot.dart';
import '../solute_type.dart';
import '../transport_protein_type.dart';
import 'transport_protein.dart';

enum SodiumGlucoseState {
  openToOutsideAwaitingParticles,
  openToOutsideAllParticlesBound,
  openToInside,
}

SodiumGlucoseState sodiumGlucoseStateFrom(String id) =>
    SodiumGlucoseState.values.firstWhere((e) => e.name == id);

/// Na+/Glucose cotransporter — PhET `SodiumGlucoseCotransporter.ts`.
class SodiumGlucoseCotransporter extends TransportProtein {
  SodiumGlucoseCotransporter({
    required super.model,
    required super.position,
  }) : super(
          type: TransportProteinType.sodiumGlucoseCotransporter,
          initialState: SodiumGlucoseState.openToOutsideAwaitingParticles.name,
          openStates: const [],
        );

  static const double stateTransitionInterval = 0.5;

  SodiumGlucoseState get coState => sodiumGlucoseStateFrom(state);
  set coState(SodiumGlucoseState s) => setState(s.name);

  bool _siteBusy(String site) {
    return model.solutes.any((p) {
      final m = p.mode;
      return m is WaitingInCotransporterMode &&
          m.slot == slotOrNull &&
          m.site == site;
    });
  }

  List<String> availableSodiumSites(MembraneTransportModel model) {
    final out = <String>[];
    if (!_siteBusy('left')) out.add('left');
    if (!_siteBusy('right')) out.add('right');
    return out;
  }

  bool isGlucoseSiteOpen(MembraneTransportModel model) => !_siteBusy('center');

  MtParticle? _waiting(String site) {
    for (final p in model.solutes) {
      final m = p.mode;
      if (m is WaitingInCotransporterMode &&
          m.slot == slotOrNull &&
          m.site == site) {
        return p;
      }
    }
    return null;
  }

  @override
  bool isAvailableForPassiveTransport(
    SoluteType soluteType,
    MembraneSide location,
  ) =>
      false;

  @override
  void step(double dt) {
    super.step(dt);

    // Sodium gradient collapsed → abort
    if (model.lessSodiumOutsideThanInside) {
      for (final p in List<MtParticle>.from(model.solutes)) {
        if (p.mode.slot == slotOrNull) {
          p.startRandomWalk();
        }
      }
      coState = SodiumGlucoseState.openToOutsideAwaitingParticles;
      return;
    }

    final left = _waiting('left');
    final glucose = _waiting('center');
    final right = _waiting('right');

    if (coState == SodiumGlucoseState.openToOutsideAllParticlesBound &&
        (left == null || glucose == null || right == null)) {
      coState = SodiumGlucoseState.openToOutsideAwaitingParticles;
    }

    if (left != null && glucose != null && right != null) {
      if (coState == SodiumGlucoseState.openToOutsideAwaitingParticles) {
        coState = SodiumGlucoseState.openToOutsideAllParticlesBound;
      } else if (timeSinceStateTransition > stateTransitionInterval) {
        coState = SodiumGlucoseState.openToInside;
        left.mode = MovingThroughProteinMode(
          slot: slot,
          direction: CrossingDirection.inward,
          targetXOffset: -5,
        );
        glucose.mode = MovingThroughProteinMode(
          slot: slot,
          direction: CrossingDirection.inward,
        );
        right.mode = MovingThroughProteinMode(
          slot: slot,
          direction: CrossingDirection.inward,
          targetXOffset: 5,
        );
      }
    }

    if (coState == SodiumGlucoseState.openToInside) {
      final passing = model.solutes
          .where(
            (p) =>
                p.mode is MovingThroughProteinMode &&
                p.mode.slot == slotOrNull,
          )
          .length;
      if (passing == 0) {
        coState = SodiumGlucoseState.openToOutsideAwaitingParticles;
      }
    }
  }

  @override
  void clearSolutes(Slot slot) {
    super.clearSolutes(slot);
    for (final p in List<MtParticle>.from(model.solutes)) {
      if (p.mode.slot == slot) {
        p.releaseFromInteraction(20);
      }
    }
    setState(SodiumGlucoseState.openToOutsideAwaitingParticles.name);
  }
}
