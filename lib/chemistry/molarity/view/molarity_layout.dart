import 'package:flutter/material.dart';

import '../model/molarity_constants.dart';

/// Source geometry from `BeakerImageNode.js` + `MolarityScreenView.js`.
///
/// Image intrinsic: 560×681 · displayed with `scale: 0.75`.
/// Cluster is laid out in local coordinates then centered on [canvas].
class MolarityLayout {
  MolarityLayout._();

  static const Size canvas = Size(
    MolarityConstants.layoutWidth,
    MolarityConstants.layoutHeight,
  );

  /// Official PhET play-area canvas fill (screenshot Gold Standard: white).
  static const Color background = Color(0xFFFFFFFF);

  static const String beakerAsset = 'assets/chemistry/molarity/beaker.png';

  static const Size beakerIntrinsic = Size(560, 681);
  static const double beakerScale = 0.75;

  static Size get beakerDisplaySize => Size(
        beakerIntrinsic.width * beakerScale,
        beakerIntrinsic.height * beakerScale,
      );

  // Image-local points of interest (pre-scale).
  static const Offset cylinderUpperLeftLocal = Offset(98, 192);
  static const Offset cylinderLowerRightLocal = Offset(526, 644);
  static const Offset cylinderEndBackgroundLocal = Offset(210, 166);
  static const Offset cylinderEndForegroundLocal = Offset(210, 218);

  static Offset get cylinderUpperLeft =>
      cylinderUpperLeftLocal * beakerScale;
  static Offset get cylinderLowerRight =>
      cylinderLowerRightLocal * beakerScale;

  static Size get cylinderSize => Size(
        cylinderLowerRight.dx - cylinderUpperLeft.dx,
        cylinderLowerRight.dy - cylinderUpperLeft.dy,
      );

  static double get cylinderEndHeight =>
      (cylinderEndForegroundLocal.dy - cylinderEndBackgroundLocal.dy) *
      beakerScale;

  /// Solute-amount slider track height = full cylinder height.
  static double get soluteSliderTrackHeight => cylinderSize.height;

  /// Volume slider track height ∝ (1−0.2)/1 · cylinderHeight.
  static double get volumeSliderTrackHeight =>
      (MolarityConstants.volumeMax - MolarityConstants.volumeMin) /
      MolarityConstants.volumeMax *
      cylinderSize.height;

  static const double sliderTrackWidth = 12;
  static const Size sliderThumbSize = Size(68, 30);
  static const Color sliderThumb = Color(0xFF599CD4);

  /// Column width of track + title (excludes quantitative value readout).
  static const double sliderColumnWidth = 130;

  /// PhET `VerticalSlider` valueText `maxWidth` (empirical).
  static const double valuesReadoutMaxWidth = 90;

  /// PhET: `valueText.left = sliderNode.right + 5`.
  static const double valuesReadoutGap = 5;

  /// Source: `solutionVolumeSlider.left = soluteAmountSlider.right + 5`.
  /// When values are visible, PhET includes valueText in node bounds, so the
  /// next slider shifts right — mirror that here.
  static const double sliderGap = 5;

  /// Track-column width, plus reserved readout when [valuesVisible].
  static double sliderColumnWidthFor(bool valuesVisible) =>
      sliderColumnWidth +
      (valuesVisible ? valuesReadoutGap + valuesReadoutMaxWidth : 0);

  /// Source: `beakerNode.left = solutionVolumeSlider.right - 15`.
  static const double beakerOverlapIntoVolume = 15;

  /// Source: `beakerNode.top = soluteAmountSlider.top - 11`.
  static const double beakerTopOffset = -11;

  /// Source: `concentrationDisplay.left = beakerNode.right + 40`.
  static const double concentrationGap = 40;

  /// Source: `soluteComboBox.top = beakerNode.bottom + 50`.
  static const double controlsBelowBeaker = 50;

  /// Source: `solutionValuesCheckbox.right = soluteComboBox.left - 50`.
  static const double checkboxComboGap = 50;

  static double get soluteSliderLeft => 0;

  /// Qualitative (values off) — kept for golden / geometry asserts.
  static double get volumeSliderLeft => volumeSliderLeftFor(false);

  static double volumeSliderLeftFor(bool valuesVisible) =>
      soluteSliderLeft + sliderColumnWidthFor(valuesVisible) + sliderGap;

  static double get beakerLeft => beakerLeftFor(false);

  static double beakerLeftFor(bool valuesVisible) =>
      volumeSliderLeftFor(valuesVisible) +
      sliderColumnWidthFor(valuesVisible) -
      beakerOverlapIntoVolume;

  static double get beakerTop => beakerTopOffset;

  static double get concentrationLeft => concentrationLeftFor(false);

  static double concentrationLeftFor(bool valuesVisible) =>
      beakerLeftFor(valuesVisible) + beakerDisplaySize.width + concentrationGap;

  /// ConcentrationDisplay is bottom-aligned to beaker (source).
  static double concentrationTop(double displayHeight) =>
      beakerTop + beakerDisplaySize.height - displayHeight;

  static double get controlsTop =>
      beakerTop + beakerDisplaySize.height + controlsBelowBeaker;

  static double beakerCenterXFor(bool valuesVisible) =>
      beakerLeftFor(valuesVisible) + beakerDisplaySize.width / 2;

  static double get beakerCenterX => beakerCenterXFor(false);

  /// Approximate content cluster size for centering on canvas.
  static Size get contentClusterSize => contentClusterSizeFor(false);

  static Size contentClusterSizeFor(bool valuesVisible) => Size(
        concentrationLeftFor(valuesVisible) + 200,
        controlsTop + 80,
      );

  /// Concentration bar: `Dimension2(40, cylinderSize.height + 50)`.
  static Size get concentrationBarSize =>
      Size(40, cylinderSize.height + 50);

  /// Reset All: scenery-phet default radius × source `scale: 1.32`.
  static const double resetRadius = 20.5 * 1.32;
}
