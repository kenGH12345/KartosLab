// ignore_for_file: use_super_parameters
// bins must stay in scope for stacking math after super().

import 'dart:math' as math;

import '../plinko_constants.dart';
import 'ball.dart';
import 'histogram.dart';
import 'plinko_random.dart';

/// Intro ball with cylinder stacking — `IntroBall.js`.
class IntroBall extends Ball {
  IntroBall({
    required double probability,
    required int numberOfRows,
    required List<BinInfo> bins,
    required PlinkoRandom random,
    required CylinderInfo cylinderInfo,
  }) : super(
          probability: probability,
          numberOfRows: numberOfRows,
          bins: bins,
          random: random,
        ) {
    final lastBallBinOrientation = bins[binIndex].orientation;

    switch (binCount % 3) {
      case 0:
        binOrientation = 0;
      case 1:
        binOrientation = random.nextBoolean() ? 1 : -1;
      case 2:
        binOrientation = -lastBallBinOrientation;
      default:
        throw StateError('invalid binOrientation for binCount=$binCount');
    }

    final binStackLevel =
        2 * (binCount ~/ 3) + ((binCount % 3 == 0) ? 0 : 1);

    final yMinimum = cylinderInfo.top -
        cylinderInfo.verticalOffset -
        cylinderInfo.ellipseHeight -
        cylinderInfo.cylinderHeight;

    final deltaY = ballRadius +
        math.sqrt(
          math.pow(2 * ballRadius, 2) -
              math.pow(
                (cylinderInfo.cylinderWidth / 2) - ballRadius,
                2,
              ),
        );

    finalBinVerticalOffset =
        yMinimum + ((binStackLevel - 1) * deltaY) - ballRadius;
    finalBinHorizontalOffset =
        binOrientation * ((cylinderInfo.cylinderWidth / 2) - ballRadius);
  }
}

/// Cylinder geometry for Intro stacking.
class CylinderInfo {
  const CylinderInfo({
    required this.cylinderWidth,
    required this.cylinderHeight,
    required this.ellipseHeight,
    required this.verticalOffset,
    required this.top,
  });

  final double cylinderWidth;
  final double cylinderHeight;
  final double ellipseHeight;
  final double verticalOffset;
  final double top;

  /// Build from current numberOfRows (IntroModel constructor logic).
  factory CylinderInfo.forRows(int numberOfRows) {
    const boundsWidth =
        PlinkoConstants.histogramMaxX - PlinkoConstants.histogramMinX;
    final binWidth = boundsWidth / (numberOfRows + 1);
    final cylinderWidth = 0.95 * binWidth;
    final ellipseHeight =
        cylinderWidth * math.sin(PlinkoConstants.perspectiveTilt);
    const boundsHeight =
        PlinkoConstants.histogramMaxY - PlinkoConstants.histogramMinY;
    return CylinderInfo(
      cylinderWidth: cylinderWidth,
      cylinderHeight: boundsHeight * 0.87,
      ellipseHeight: ellipseHeight,
      verticalOffset: 0.035,
      top: PlinkoConstants.histogramMaxY,
    );
  }
}
