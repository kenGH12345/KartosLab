import '../membrane_transport_model.dart';
import '../mt_vec2.dart';
import '../particle.dart';
import '../particle_mode.dart';
import '../slot.dart';
import '../solute_type.dart';
import '../transport_protein_type.dart';
import 'transport_protein.dart';

enum SodiumPotassiumState {
  openToInsideEmpty,
  openToInsideSodiumBound,
  openToInsideSodiumAndATPBound,
  openToInsideSodiumAndPhosphateBound,
  openToOutsideAwaitingPotassium,
  openToOutsidePotassiumBound,
}

extension SodiumPotassiumStateX on SodiumPotassiumState {
  String get id => name;
}

SodiumPotassiumState sodiumPotassiumStateFrom(String id) =>
    SodiumPotassiumState.values.firstWhere((e) => e.name == id);

/// Na+/K+ pump — PhET `SodiumPotassiumPump.ts`.
class SodiumPotassiumPump extends TransportProtein {
  SodiumPotassiumPump({
    required super.model,
    required super.position,
  }) : super(
          type: TransportProteinType.sodiumPotassiumPump,
          initialState: SodiumPotassiumState.openToInsideEmpty.name,
          openStates: const [],
        );

  static const double stateTransitionInterval = 0.5;

  SodiumPotassiumState get pumpState => sodiumPotassiumStateFrom(state);

  set pumpState(SodiumPotassiumState s) => setState(s.name);

  // Alias used by particle_mode
  // ignore: unnecessary_getters_setters
  SodiumPotassiumState get stateEnum => pumpState;

  bool _isSiteOpen(String site) {
    return model.solutes.every((p) {
      final m = p.mode;
      if (m is WaitingInPumpMode && m.slot == slotOrNull && m.site == site) {
        return false;
      }
      return true;
    });
  }

  List<String> openSodiumSites(MembraneTransportModel model) {
    const sites = ['sodium1', 'sodium2', 'sodium3'];
    return sites.where(_isSiteOpen).toList();
  }

  List<String> openPotassiumSites(MembraneTransportModel model) {
    const sites = ['potassium1', 'potassium2'];
    return sites.where(_isSiteOpen).toList();
  }

  MtParticle? _waiting(String site) {
    for (final p in model.solutes) {
      final m = p.mode;
      if (m is WaitingInPumpMode && m.slot == slotOrNull && m.site == site) {
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

    final sodium1 = _waiting('sodium1');
    final sodium2 = _waiting('sodium2');
    final sodium3 = _waiting('sodium3');
    final potassium1 = _waiting('potassium1');
    final potassium2 = _waiting('potassium2');
    final atp = _waiting('atp');

    if (pumpState == SodiumPotassiumState.openToInsideSodiumBound &&
        (sodium1 == null || sodium2 == null || sodium3 == null)) {
      pumpState = SodiumPotassiumState.openToInsideEmpty;
    }
    if (pumpState == SodiumPotassiumState.openToInsideSodiumAndATPBound &&
        atp == null) {
      pumpState = SodiumPotassiumState.openToInsideSodiumBound;
    }
    if (pumpState == SodiumPotassiumState.openToOutsidePotassiumBound &&
        (potassium1 == null || potassium2 == null)) {
      pumpState = SodiumPotassiumState.openToOutsideAwaitingPotassium;
    }

    if (pumpState == SodiumPotassiumState.openToInsideEmpty) {
      if (sodium1 != null && sodium2 != null && sodium3 != null) {
        pumpState = SodiumPotassiumState.openToInsideSodiumBound;
      }
    } else if (timeSinceStateTransition >= stateTransitionInterval) {
      if (pumpState == SodiumPotassiumState.openToInsideSodiumAndATPBound) {
        _splitATP(atp!);
      } else if (pumpState ==
          SodiumPotassiumState.openToInsideSodiumAndPhosphateBound) {
        _openUpward(sodium1!, sodium2!, sodium3!);
      } else if (pumpState == SodiumPotassiumState.openToOutsidePotassiumBound) {
        _openDownward(potassium1!, potassium2!);
      }
    }
  }

  void _splitATP(MtParticle atp) {
    final pos = atp.position.copy();
    model.removeSolute(atp);
    final phosphate = model.addSoluteAt(SoluteType.phosphate, pos);
    phosphate.mode = WaitingInPumpMode(slot: slot, site: 'phosphate');
    // ADP appears nearby
    model.addSoluteAt(SoluteType.adp, pos + MtVec2(2, -2));
    pumpState = SodiumPotassiumState.openToInsideSodiumAndPhosphateBound;
  }

  void _openUpward(MtParticle s1, MtParticle s2, MtParticle s3) {
    pumpState = SodiumPotassiumState.openToOutsideAwaitingPotassium;
    s1.mode = MovingThroughProteinMode(
      slot: slot,
      direction: CrossingDirection.outward,
      targetXOffset: -5,
    );
    s2.mode = MovingThroughProteinMode(
      slot: slot,
      direction: CrossingDirection.outward,
    );
    s3.mode = MovingThroughProteinMode(
      slot: slot,
      direction: CrossingDirection.outward,
      targetXOffset: 5,
    );
  }

  void _openDownward(MtParticle k1, MtParticle k2) {
    pumpState = SodiumPotassiumState.openToInsideEmpty;
    k1.mode = MovingThroughProteinMode(
      slot: slot,
      direction: CrossingDirection.inward,
      targetXOffset: -2,
    );
    k2.mode = MovingThroughProteinMode(
      slot: slot,
      direction: CrossingDirection.inward,
      targetXOffset: 2,
    );
    final phosphate = _waiting('phosphate');
    phosphate?.moveInDirection(MtVec2(0, -1), 0.5);
  }

  @override
  void clearSolutes(Slot slot) {
    super.clearSolutes(slot);
    for (final p in List<MtParticle>.from(model.solutes)) {
      if (p.mode.slot == slot) {
        p.releaseFromInteraction(
          p.type == ParticleType.potassiumIon ? 20 : -20,
        );
      }
    }
    setState(SodiumPotassiumState.openToInsideEmpty.name);
  }
}
