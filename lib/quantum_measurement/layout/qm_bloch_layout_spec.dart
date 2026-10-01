/// Bloch Sphere layout — BlochSphereScreenView / BlochSphereNode / PreparationArea.
library;

import 'qm_global_layout_spec.dart';

class QmBlochLayoutSpec {
  const QmBlochLayoutSpec();

  /// BlochSphereScreenView dividingLineX
  static const dividingLineX = 350.0;
  static const dividingLineTop = 70.0;

  /// measurementArea.left = dividingLineX + 40
  double get measurementAreaLeft => dividingLineX + 40;

  /// Prep area: centerX = mid of [layoutLeft, dividingLine.left]; top = layoutTop + Y_MARGIN
  double preparationCenterX(double layoutLeft, double dividingLineLeft) =>
      layoutLeft + (dividingLineLeft - layoutLeft) / 2;

  double preparationTop(double layoutTop) => layoutTop + qmScreenViewYMargin;

  /// BlochSphereNode sphereRadius = 100; ShadedSphereNode diameter = 200
  static const sphereRadius = 100.0;

  /// Preparation / Spin often use scale 0.9
  static const preparationSphereScale = 0.9;

  static const labelsOffset = 5.0;
  static const axesLineWidth = 0.4;

  /// Full projection: `bloch_sphere/projection/bloch_projection.dart`
  /// (ports BlochSphereNode pointOnTheSphere / pointOnTheEquator).

  double effectiveRadius({double scale = 1.0}) => sphereRadius * scale;
}
