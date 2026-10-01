import 'dart:ui';

import 'beaker.dart';
import 'concentration_constants.dart';
import 'dropper_model.dart';
import 'faucet_model.dart';

/// Jump target for concentration probe — `ConcentrationProbeJumpPositions.ts`.
class ProbeJumpPosition {
  const ProbeJumpPosition({
    required this.id,
    required this.position,
    this.requiresDropperVisible = false,
  });

  final String id;
  final Offset position;
  final bool requiresDropperVisible;

  bool isRelevant({required bool dropperVisible}) =>
      !requiresDropperVisible || dropperVisible;
}

/// Builds and cycles probe jump positions (keyboard `J`).
class ConcentrationProbeJumpController {
  ConcentrationProbeJumpController({
    required Beaker beaker,
    required FaucetModel solventFaucet,
    required DropperModel dropper,
    required FaucetModel drainFaucet,
    required Offset initialOutside,
  }) : positions = [
          // Inside beaker, bottom center
          ProbeJumpPosition(
            id: 'insideBeaker',
            position: Offset(beaker.position.dx, beaker.position.dy - 0.0001),
          ),
          // Below water faucet
          ProbeJumpPosition(
            id: 'belowWaterFaucet',
            position: solventFaucet.position + const Offset(0, 10),
          ),
          // Below dropper (only when visible)
          ProbeJumpPosition(
            id: 'belowDropper',
            position: dropper.position + const Offset(0, 10),
            requiresDropperVisible: true,
          ),
          // Below drain faucet
          ProbeJumpPosition(
            id: 'belowDrainFaucet',
            position: drainFaucet.position + const Offset(0, 10),
          ),
          // Initial outside position
          ProbeJumpPosition(
            id: 'outsideBeaker',
            position: initialOutside,
          ),
        ];

  final List<ProbeJumpPosition> positions;
  int index = 0;

  List<ProbeJumpPosition> relevantPositions({required bool dropperVisible}) {
    return positions
        .where((p) => !p.requiresDropperVisible || dropperVisible)
        .toList(growable: false);
  }

  /// Advance to next relevant jump position; returns target offset.
  ///
  /// Source `JumpToPositionListener`: jump to current index (skipping
  /// irrelevant), then advance index for the next press.
  Offset jumpToNext({required bool dropperVisible}) {
    final n = positions.length;
    if (n == 0) return ConcentrationConstants.probeInitialPosition;

    // Skip irrelevant starting at [index].
    var iterations = 0;
    final maxIterations = n - 1;
    while ((!positions[index].isRelevant(dropperVisible: dropperVisible)) &&
        iterations < maxIterations) {
      index = (index + 1) % n;
      iterations++;
    }

    final target = positions[index].position;

    // Advance for next J.
    index = (index + 1) % n;
    return target;
  }

  /// Source focuses probe → reset jump index.
  void resetIndex() {
    index = 0;
  }

  void reset() {
    index = 0;
  }
}
