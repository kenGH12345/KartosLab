import 'package:flutter/foundation.dart';

import '../membrane_transport_constants.dart';
import '../membrane_transport_feature_set.dart';
import 'mt_random.dart';
import 'mt_vec2.dart';
import 'particle.dart';
import 'particle_mode.dart';
import 'slot.dart';
import 'solute_type.dart';
import 'transport_protein_type.dart';

enum MtTimeSpeed { normal, slow }

class FluxEntry {
  FluxEntry({
    required this.soluteType,
    required this.time,
    required this.direction,
  });

  final ParticleType soluteType;
  final double time;
  final CrossingDirection direction;
}

class SoluteCrossedEvent {
  SoluteCrossedEvent({
    required this.particle,
    required this.direction,
    this.slot,
  });

  final MtParticle particle;
  final CrossingDirection direction;
  final Slot? slot;
}

/// Central model — PhET `MembraneTransportModel.ts`.
///
/// One instance per screen. Inject [MtRandom] for deterministic tests.
class MembraneTransportModel extends ChangeNotifier {
  MembraneTransportModel({
    required this.featureSet,
    MtRandom? random,
  }) : random = random ?? SystemMtRandom() {
    membraneSlots = MembraneTransportConstants.slotPositions
        .map((x) => Slot(model: this, position: x))
        .toList();

    for (final t in featureSetSoluteTypes(featureSet)) {
      outsideCounts[t] = 0;
      insideCounts[t] = 0;
    }

    if (featureSetHasLigands(featureSet)) {
      addParticles(
        ParticleType.triangleLigand,
        MembraneSide.outside,
        MembraneTransportConstants.ligandCount,
        into: ligands,
      );
      addParticles(
        ParticleType.starLigand,
        MembraneSide.outside,
        MembraneTransportConstants.ligandCount,
        into: ligands,
      );
    }

    chargesVisible =
        featureSet == MembraneTransportFeatureSet.facilitatedDiffusion;
  }

  final MembraneTransportFeatureSet featureSet;
  final MtRandom random;

  late final List<Slot> membraneSlots;

  final List<MtParticle> solutes = [];
  final List<MtParticle> ligands = [];

  final Map<SoluteType, int> outsideCounts = {};
  final Map<SoluteType, int> insideCounts = {};

  final List<FluxEntry> fluxEntries = [];
  final List<SoluteCrossedEvent> descriptionEventQueue = [];

  SoluteType selectedSolute = SoluteType.oxygen;
  bool isPlaying = true;
  MtTimeSpeed timeSpeed = MtTimeSpeed.normal;
  bool chargesVisible = false;
  int membranePotential = -70; // -70 | -50 | 30
  bool areLigandsAdded = false;
  bool ligandInteractionCueVisible = true;
  bool crossingHighlightsEnabled = true;
  bool crossingSoundsEnabled = true;
  bool glucoseMetabolism = false;

  double time = 0;

  int get transportProteinCount =>
      membraneSlots.where((s) => s.isFilled).length;

  bool get hasAnySolutes => solutes.isNotEmpty;

  bool get lessSodiumOutsideThanInside {
    final o = outsideCounts[SoluteType.sodiumIon] ?? 0;
    final i = insideCounts[SoluteType.sodiumIon] ?? 0;
    return o <= i;
  }

  double getTimeSpeedFactor() =>
      timeSpeed == MtTimeSpeed.normal ? 1.0 : 0.5;

  static bool canMoveThroughPassiveTransport(ParticleType type) =>
      type == ParticleType.oxygen ||
      type == ParticleType.carbonDioxide ||
      type == ParticleType.sodiumIon ||
      type == ParticleType.potassiumIon;

  // --- Solute add / remove -------------------------------------------------

  void addSolutes(SoluteType type, MembraneSide side, int count) {
    addParticles(
      ParticleTypeX.fromSolute(type),
      side,
      count,
      into: solutes,
    );
  }

  MtParticle addSoluteAt(SoluteType type, MtVec2 position) {
    final p = MtParticle(
      type: ParticleTypeX.fromSolute(type),
      position: position.copy(),
      model: this,
    );
    p.attachModel(this);
    solutes.add(p);
    updateSoluteCounts();
    notifyListeners();
    return p;
  }

  void addParticles(
    ParticleType type,
    MembraneSide location,
    int count, {
    required List<MtParticle> into,
  }) {
    for (var i = 0; i < count; i++) {
      final x = random.nextDoubleBetween(
        MembraneTransportConstants.membraneMinX,
        MembraneTransportConstants.membraneMaxX,
      );
      final yOffset = random.nextDoubleBetween(1, 10);
      final y = location == MembraneSide.inside
          ? MembraneTransportConstants.insideMinY + yOffset
          : MembraneTransportConstants.outsideMaxY - yOffset;
      final p = MtParticle(
        type: type,
        position: MtVec2(x, y),
        model: this,
      );
      p.attachModel(this);
      into.add(p);
    }
    updateSoluteCounts();
    notifyListeners();
  }

  void removeSolute(MtParticle solute) {
    solute.releaseFromInteraction(0);
    solutes.remove(solute);
    updateSoluteCounts();
    notifyListeners();
  }

  void removeSolutes(SoluteType type, MembraneSide location, int count) {
    final removable = solutes.where((s) {
      if (s.type.asSolute != type) return false;
      return location == MembraneSide.inside
          ? s.position.y < 0
          : s.position.y >= 0;
    }).toList();
    final shuffled = random.shuffle(removable);
    final n = count.clamp(0, shuffled.length);
    for (var i = 0; i < n; i++) {
      solutes.remove(shuffled[i]);
    }
    updateSoluteCounts();
    notifyListeners();
  }

  void clearSolutes() {
    for (final slot in membraneSlots.where((s) => s.isFilled)) {
      slot.transportProtein!.clearSolutes(slot);
    }
    solutes.clear();
    updateSoluteCounts();
    descriptionEventQueue.clear();
    notifyListeners();
  }

  void reset() {
    selectedSolute = SoluteType.oxygen;
    timeSpeed = MtTimeSpeed.normal;
    isPlaying = true;
    chargesVisible =
        featureSet == MembraneTransportFeatureSet.facilitatedDiffusion;
    membranePotential = -70;
    areLigandsAdded = false;
    ligandInteractionCueVisible = true;
    crossingHighlightsEnabled = true;
    crossingSoundsEnabled = true;
    // time is NOT reset (source confirmed)
    solutes.clear();
    for (final slot in membraneSlots) {
      slot.reset();
    }
    descriptionEventQueue.clear();
    fluxEntries.clear();
    updateSoluteCounts();
    notifyListeners();
  }

  // --- Counts / gradient ---------------------------------------------------

  int countSolutes(SoluteType type, MembraneSide location) {
    return solutes.where((s) {
      if (s.type.asSolute != type) return false;
      return location == MembraneSide.inside
          ? s.position.y < 0
          : s.position.y >= 0;
    }).length;
  }

  void updateSoluteCounts() {
    for (final t in featureSetSoluteTypes(featureSet)) {
      outsideCounts[t] = countSolutes(t, MembraneSide.outside);
      insideCounts[t] = countSolutes(t, MembraneSide.inside);
    }
  }

  /// Positive ⇒ higher concentration inside.
  double getSignedGradient(SoluteType type) {
    final inside = countSolutes(type, MembraneSide.inside);
    final outside = countSolutes(type, MembraneSide.outside);
    final total = inside + outside;
    if (total == 0) return 0;
    return (inside - outside) / total;
  }

  bool checkGradientForCrossing(SoluteType type, MembraneSide location) {
    final gradient = getSignedGradient(type);
    final movingAgainst = (location == MembraneSide.outside && gradient > 0) ||
        (location == MembraneSide.inside && gradient < 0);
    if (movingAgainst &&
        gradient.abs() > MembraneTransportConstants.biasThreshold) {
      return random.nextDouble() >
          MembraneTransportConstants.gradientBiasStrength;
    }
    return true;
  }

  bool shouldApplyBiasForGasses(SoluteType type) =>
      getSignedGradient(type).abs() > MembraneTransportConstants.biasThreshold;

  // --- Step ----------------------------------------------------------------

  void step(double dt) {
    if (isPlaying) {
      time += dt;
      final scaled = dt * getTimeSpeedFactor();

      final initialY = <MtParticle, double>{
        for (final s in solutes) s: s.position.y,
      };

      for (final s in List<MtParticle>.from(solutes)) {
        s.step(scaled, this);
      }
      if (areLigandsAdded) {
        for (final lig in ligands) {
          lig.step(scaled, this);
        }
      }
      for (final slot in membraneSlots) {
        slot.transportProtein?.step(scaled);
      }

      _stepFlux(initialY);
    }
    updateSoluteCounts();
    notifyListeners();
  }

  void _stepFlux(Map<MtParticle, double> initialY) {
    fluxEntries.removeWhere((e) => time - e.time > 1);
    for (final s in solutes) {
      final y0 = initialY[s];
      if (y0 == null) continue;
      if (y0 * s.position.y < 0) {
        fluxEntries.add(
          FluxEntry(
            soluteType: s.type,
            time: time,
            direction: s.position.y < 0
                ? CrossingDirection.inward
                : CrossingDirection.outward,
          ),
        );
      }
    }
  }

  void recordCrossing(
    MtParticle particle,
    CrossingDirection direction, {
    Slot? slot,
  }) {
    descriptionEventQueue.add(
      SoluteCrossedEvent(
        particle: particle,
        direction: direction,
        slot: slot,
      ),
    );
  }

  void onLigandUnboundNaturally(MtParticle ligand) {
    // Hook for sounds / a11y — Phase 3+
  }

  // --- Slots ---------------------------------------------------------------

  Slot? getLeftmostEmptySlot() {
    for (final s in membraneSlots) {
      if (!s.isFilled) return s;
    }
    return null;
  }

  Slot getMiddleSlot() =>
      membraneSlots[membraneSlots.length ~/ 2];

  void placeProtein(TransportProteinType type, {Slot? slot}) {
    // Mouse drag uses explicit slot; tap/keyboard: leftmost empty else middle
    // (PhET forwardFromKeyboard — may replace middle when full).
    final target = slot ?? getLeftmostEmptySlot() ?? getMiddleSlot();
    target.setTransportProteinType(type);
    notifyListeners();
  }

  /// Drop from drag session — PhET TransportProteinDragNode end().
  /// [originSlot] non-null ⇒ came from membrane (already cleared on pickup).
  void dropProteinFromDrag(
    TransportProteinType type,
    Slot target, {
    Slot? originSlot,
  }) {
    final other = target.transportProteinType;
    target.setTransportProteinType(type);
    if (other != null && originSlot != null) {
      // Swap
      originSlot.setTransportProteinType(other);
    }
    // else if other != null && originSlot == null: replace (old discarded)
    notifyListeners();
  }

  void removeProtein(Slot slot) {
    slot.setTransportProteinType(null);
    notifyListeners();
  }

  /// View-layer pickup: slot already cleared; refresh listeners.
  void notifyAfterSlotMutation() => notifyListeners();

  void setChargesVisible(bool value) {
    chargesVisible = value;
    notifyListeners();
  }

  List<SoluteType> get selectableSolutes =>
      featureSetSelectableSoluteTypes(featureSet);

  void setSelectedSolute(SoluteType type) {
    selectedSolute = type;
    notifyListeners();
  }

  void setPlaying(bool value) {
    isPlaying = value;
    notifyListeners();
  }

  void setTimeSpeed(MtTimeSpeed speed) {
    timeSpeed = speed;
    notifyListeners();
  }

  void setCrossingHighlights(bool value) {
    crossingHighlightsEnabled = value;
    notifyListeners();
  }

  void setCrossingSounds(bool value) {
    crossingSoundsEnabled = value;
    notifyListeners();
  }

  void setMembranePotential(int mv) {
    membranePotential = mv;
    notifyListeners();
  }

  void setAreLigandsAdded(bool value) {
    areLigandsAdded = value;
    notifyListeners();
  }
}
