import 'dart:math' as math;

import '../waves_intro_constants.dart';

/// Port of PhET `TemporalMask.ts`.
///
/// Records on/off times of a point source so lattice cells that could not have
/// been reached by the wave front are masked out (suppresses artifacts / restores
/// black for light). [已确认] TemporalMask.ts
class TemporalMask {
  final List<_Delta> _deltas = [];

  void set({
    required bool isSourceOn,
    required int numberOfSteps,
    required int verticalLatticeCoordinate,
  }) {
    final last = _deltas.isEmpty ? null : _deltas.last;
    if (_deltas.isEmpty ||
        last!.isSourceOn != isSourceOn ||
        last.verticalLatticeCoordinate != verticalLatticeCoordinate) {
      _deltas.add(
        _Delta(
          isSourceOn: isSourceOn,
          numberOfSteps: numberOfSteps,
          verticalLatticeCoordinate: verticalLatticeCoordinate,
        ),
      );
    }
  }

  bool matches({
    required int horizontalLatticeCoordinate,
    required int verticalLatticeCoordinate,
    required int numberOfSteps,
  }) {
    for (var k = 0; k < _deltas.length; k++) {
      final delta = _deltas[k];
      if (!delta.isSourceOn) continue;

      final horizontalDelta = WavesIntroConstants.pointSourceHorizontal -
          horizontalLatticeCoordinate;
      final verticalDelta =
          delta.verticalLatticeCoordinate - verticalLatticeCoordinate;
      final distance = math.sqrt(
        horizontalDelta * horizontalDelta + verticalDelta * verticalDelta,
      );

      final startTime = delta.numberOfSteps;
      final endTime =
          k + 1 < _deltas.length ? _deltas[k + 1].numberOfSteps : numberOfSteps;

      final theoreticalTime =
          numberOfSteps - distance / WavesIntroConstants.waveSpeed;

      const headTolerance = 2;
      const tailTolerance = 4;
      if (theoreticalTime >= startTime - headTolerance &&
          theoreticalTime <= endTime + tailTolerance) {
        return true;
      }
    }
    return false;
  }

  void prune(double maxDistance, int numberOfSteps) {
    while (_deltas.length > 10) {
      _deltas.removeAt(0);
    }
  }

  void clear() => _deltas.clear();
}

class _Delta {
  _Delta({
    required this.isSourceOn,
    required this.numberOfSteps,
    required this.verticalLatticeCoordinate,
  });

  final bool isSourceOn;
  final int numberOfSteps;
  final int verticalLatticeCoordinate;
}
