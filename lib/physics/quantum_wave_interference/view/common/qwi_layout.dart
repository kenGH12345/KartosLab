import 'dart:ui';

import '../layout/experiment_layout_spec.dart';
import '../layout/high_intensity_layout_spec.dart';
import '../layout/qwi_layout_primitives.dart';
import '../layout/single_particles_layout_spec.dart';

/// Shared design canvas + screen Spec accessors.
///
/// Experiment / HI / SP geometry is resolved by their LayoutSpecs.
class QwiLayout {
  QwiLayout._();

  static const double designWidth = ExperimentLayoutConstants.designWidth;
  static const double designHeight = ExperimentLayoutConstants.designHeight;
  static const Size designSize = Size(designWidth, designHeight);

  static const double screenViewXMargin = QwiSpacing.margin;
  static const double screenViewYMargin = QwiSpacing.margin;

  static const double frontFacingSlitViewWidth = ExperimentLayoutConstants.frontFacingSlitViewWidth;
  static const double frontFacingRowHeight = ExperimentLayoutConstants.frontFacingRowHeight;
  static const double frontFacingRowTop = ExperimentLayoutConstants.frontFacingRowTop;
  static const double detectorScaleBarBand = ExperimentLayoutConstants.detectorScaleBarBand;
  static const double detectorScreenWidth = ExperimentLayoutConstants.detectorScreenWidth;
  static const double snapshotColumnWidth = ExperimentLayoutConstants.snapshotColumnWidth;
  static const double snapshotColumnGap = QwiSpacing.snapshotGap;
  static const double columnGap = QwiSpacing.stack;
  static const double slitControlPanelWidth = ExperimentLayoutConstants.slitControlPanelWidth;
  static const double overheadElementScale = ExperimentLayoutConstants.overheadElementScale;
  static const double overheadSkewScale = ExperimentLayoutConstants.overheadSkewScale;
  static const double overheadBeamYFraction = ExperimentLayoutConstants.overheadBeamYFraction;
  static const double rightPanelWidth = HighIntensityLayoutConstants.rightPanelWidth;
  static const double rightPanelXMargin = 8;
  static const double experimentLeftColumnWidth = ExperimentLayoutConstants.sourcePanelMinWidth;
  static const double middleColumnLeftShift = ExperimentLayoutConstants.middleColumnLeftShift;
  static const double sourceControlPanelTop = ExperimentLayoutConstants.sourceControlPanelTop;
  static const double sceneButtonGroupCenterY = ExperimentLayoutConstants.sceneButtonGroupCenterY;
  static const double frontFacingControlsGap = ExperimentLayoutConstants.frontFacingControlsGap;

  static const double detectorScreenWidthHiSp = HighIntensityLayoutConstants.detectorScreenWidth;
  static const double waveRegionWidth = HighIntensityLayoutConstants.waveRegionWidth;
  static const double waveRegionHeight = HighIntensityLayoutConstants.waveRegionHeight;

  /// HI/SP shared wave display left/top (PhET wave-region formula).
  static double get hiWaveRegionLeft => highIntensity.waveRegion.left;
  static double get hiWaveRegionTop => highIntensity.waveRegion.top;

  static ExperimentLayoutSpec get experiment => ExperimentLayoutSpec.resolve();
  static HighIntensityLayoutSpec get highIntensity => HighIntensityLayoutSpec.resolve();
  static SingleParticlesLayoutSpec get singleParticles => SingleParticlesLayoutSpec.resolve();

  static Rect get hiWaveRegionRect => highIntensity.waveRegion.asRect;

  static Rect get hiDetectorRect => highIntensity.detector.asRect;

  static Rect get frontFacingDetectorRect => experiment.detector.asRect;

  static double get frontFacingControlsTop =>
      frontFacingRowTop + frontFacingRowHeight + frontFacingControlsGap;

  static Rect get frontFacingSlitRect => experiment.slitView.asRect;
}
