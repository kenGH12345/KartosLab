/// SphereBucket open-slot finder — phetcommon `SphereBucket.ts` (verbatim geometry).
///
/// Occupied slots are destination centers (`IaamVec2`), shared by Make nucleons
/// and Mix isotope atoms.
library;

import 'iaam_vec2.dart';

class SphereBucketLayout {
  const SphereBucketLayout._();

  static double defaultVerticalOffset(double sphereRadius) =>
      -sphereRadius * 0.4;

  static double yForLayer({
    required double bucketY,
    required double verticalParticleOffset,
    required double sphereRadius,
    required int layer,
  }) {
    return bucketY +
        verticalParticleOffset +
        layer * sphereRadius * 2 * 0.866;
  }

  /// First open slot in triangular stack (`getFirstOpenPosition`).
  static IaamVec2 firstOpenPosition({
    required IaamVec2 bucketPosition,
    required double bucketWidth,
    required double sphereRadius,
    required List<IaamVec2> occupiedDestinations,
    double usableWidthProportion = 1.0,
    double? verticalParticleOffset,
  }) {
    final vOffset =
        verticalParticleOffset ?? defaultVerticalOffset(sphereRadius);
    final usableWidth =
        bucketWidth * usableWidthProportion - 2 * sphereRadius;
    var offsetFromBucketEdge =
        (bucketWidth - usableWidth) / 2 + sphereRadius;
    var numParticlesInLayer =
        (usableWidth / (sphereRadius * 2)).floor();
    var row = 0;
    var positionInLayer = 0;

    while (true) {
      final test = IaamVec2(
        bucketPosition.x -
            bucketWidth / 2 +
            offsetFromBucketEdge +
            positionInLayer * 2 * sphereRadius,
        yForLayer(
          bucketY: bucketPosition.y,
          verticalParticleOffset: vOffset,
          sphereRadius: sphereRadius,
          layer: row,
        ),
      );
      if (_isPositionOpen(test, occupiedDestinations)) {
        return test;
      }
      positionInLayer++;
      if (positionInLayer >= numParticlesInLayer) {
        row++;
        positionInLayer = 0;
        numParticlesInLayer--;
        offsetFromBucketEdge += sphereRadius;
        if (numParticlesInLayer == 0) {
          numParticlesInLayer = 1;
          offsetFromBucketEdge -= sphereRadius;
        }
      }
    }
  }

  /// Nearest supported open slot (`getNearestOpenPosition`).
  static IaamVec2 nearestOpenPosition({
    required IaamVec2 preferred,
    required IaamVec2 bucketPosition,
    required double bucketWidth,
    required double sphereRadius,
    required List<IaamVec2> occupiedDestinations,
    double usableWidthProportion = 1.0,
    double? verticalParticleOffset,
  }) {
    final vOffset =
        verticalParticleOffset ?? defaultVerticalOffset(sphereRadius);

    var highestOccupiedLayer = 0;
    for (final p in occupiedDestinations) {
      final layer = _layerForY(
        p.y,
        bucketPosition.y,
        vOffset,
        sphereRadius,
      );
      if (layer > highestOccupiedLayer) highestOccupiedLayer = layer;
    }

    final openPositions = <IaamVec2>[];
    final usableWidth =
        bucketWidth * usableWidthProportion - 2 * sphereRadius;
    var offsetFromBucketEdge =
        (bucketWidth - usableWidth) / 2 + sphereRadius;
    var numParticlesInLayer =
        (usableWidth / (sphereRadius * 2)).floor();

    for (var layer = 0; layer <= highestOccupiedLayer + 1; layer++) {
      for (var positionInLayer = 0;
          positionInLayer < numParticlesInLayer;
          positionInLayer++) {
        final test = IaamVec2(
          bucketPosition.x -
              bucketWidth / 2 +
              offsetFromBucketEdge +
              positionInLayer * 2 * sphereRadius,
          yForLayer(
            bucketY: bucketPosition.y,
            verticalParticleOffset: vOffset,
            sphereRadius: sphereRadius,
            layer: layer,
          ),
        );
        if (_isPositionOpen(test, occupiedDestinations)) {
          if (layer == 0 ||
              _countSupporting(test, occupiedDestinations, sphereRadius) ==
                  2) {
            openPositions.add(test);
          }
        }
      }
      numParticlesInLayer--;
      offsetFromBucketEdge += sphereRadius;
      if (numParticlesInLayer == 0) {
        numParticlesInLayer = 1;
        offsetFromBucketEdge -= sphereRadius;
      }
    }

    if (openPositions.isEmpty) {
      return firstOpenPosition(
        bucketPosition: bucketPosition,
        bucketWidth: bucketWidth,
        sphereRadius: sphereRadius,
        occupiedDestinations: occupiedDestinations,
        usableWidthProportion: usableWidthProportion,
        verticalParticleOffset: vOffset,
      );
    }

    var closest = openPositions.first;
    for (final open in openPositions) {
      if (open.distanceTo(preferred) < closest.distanceTo(preferred)) {
        closest = open;
      }
    }
    return closest;
  }

  static int _layerForY(
    double y,
    double bucketY,
    double vOffset,
    double sphereRadius,
  ) {
    final raw = (y - (bucketY + vOffset)) / (sphereRadius * 2 * 0.866);
    final rounded = (raw + (raw < 0 ? -0.5 : 0.5)).truncateToDouble();
    return rounded.abs().toInt();
  }

  static bool _isPositionOpen(
    IaamVec2 position,
    List<IaamVec2> occupied,
  ) {
    for (final p in occupied) {
      if (p.x == position.x && p.y == position.y) return false;
    }
    return true;
  }

  static int _countSupporting(
    IaamVec2 position,
    List<IaamVec2> occupied,
    double sphereRadius,
  ) {
    var count = 0;
    for (final p in occupied) {
      if (p.y < position.y && p.distanceTo(position) < sphereRadius * 3) {
        count++;
      }
    }
    return count;
  }
}
