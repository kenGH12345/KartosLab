import '../mt_vec2.dart';
import '../particle.dart';
import '../particle_mode.dart';
import '../slot.dart';
import '../solute_type.dart';
import '../transport_protein_type.dart';
import 'transport_protein.dart';

/// Ligand-gated channel — PhET `LigandGatedChannel.ts`.
class LigandGatedChannel extends TransportProtein {
  LigandGatedChannel({
    required super.model,
    required super.type,
    required super.position,
  }) : super(
          initialState: 'closed',
          openStates: const ['ligandBoundOpen', 'ligandUnboundOpen'],
        ) {
    timeSinceStateTransition = rebindingDelay;
  }

  static const double rebindingDelay = 5;
  static const double bindingDuration = 15;
  static const double stateTransitionInterval = 0.5;

  MtParticle? get boundLigand {
    for (final lig in model.ligands) {
      if (lig.mode is LigandBoundMode &&
          (lig.mode as LigandBoundMode).channel == this) {
        return lig;
      }
    }
    return null;
  }

  MtVec2 get bindingPosition {
    // Approximate site near channel top-center (IMAGE_METRICS offsets).
    final isSodium =
        type == TransportProteinType.sodiumIonLigandGatedChannel;
    final closed = state == 'ligandBoundClosed';
    // Sodium closed site (185,149) / open (128,149) on 650×900
    // Potassium (77,127) both
    if (isSodium) {
      return MtVec2(position, 0) +
          bindingOffsetFromImage(
            imageW: 650,
            imageH: 900,
            siteX: closed ? 185 : 128,
            siteY: 149,
          );
    }
    return MtVec2(position, 0) +
        bindingOffsetFromImage(
          imageW: 650,
          imageH: 900,
          siteX: 77,
          siteY: 127,
        );
  }

  bool isAvailableForBinding() =>
      state == 'closed' && timeSinceStateTransition >= rebindingDelay;

  void bindLigand(MtParticle ligand, bool isPlaying) {
    if (!isAvailableForBinding()) return;
    setState(isPlaying ? 'ligandBoundClosed' : 'ligandBoundOpen');
    ligand.mode = LigandBoundMode(channel: this);
    ligand.position.set(bindingPosition);
  }

  void unbindLigand({required bool naturally, required bool isPlaying}) {
    final ligand = boundLigand;
    if (ligand == null) return;
    ligand.mode = RandomWalkMode.create(model.random, allowImmediateInteraction: false);
    setState(isPlaying ? 'ligandUnboundOpen' : 'closed');
    ligand.manuallyBound = false;
    if (naturally) {
      model.onLigandUnboundNaturally(ligand);
    }
  }

  @override
  void step(double dt) {
    super.step(dt);

    if (state == 'ligandUnboundOpen' &&
        timeSinceStateTransition >= stateTransitionInterval) {
      setState('closed');
    }
    if (state == 'ligandBoundClosed' &&
        timeSinceStateTransition >= stateTransitionInterval) {
      setState('ligandBoundOpen');
    }
    if (state == 'ligandBoundOpen' &&
        timeSinceStateTransition >= bindingDuration &&
        boundLigand != null &&
        !hasSolutesMovingTowardOrThrough()) {
      unbindLigand(naturally: true, isPlaying: model.isPlaying);
    }
  }

  @override
  bool isAvailableForPassiveTransport(
    SoluteType soluteType,
    MembraneSide location,
  ) {
    return state == 'ligandBoundOpen' &&
        timeSinceStateTransition < bindingDuration &&
        !hasSolutesMovingTowardOrThrough() &&
        model.checkGradientForCrossing(soluteType, location);
  }

  @override
  void clear(Slot slot) {
    if (boundLigand != null) {
      unbindLigand(naturally: false, isPlaying: model.isPlaying);
    }
    for (final lig in List<MtParticle>.from(model.ligands)) {
      if (lig.mode.slot == slot) {
        lig.releaseFromInteraction(20);
      }
    }
    clearSolutes(slot);
    setState('closed');
    timeSinceStateTransition = rebindingDelay;
  }
}
