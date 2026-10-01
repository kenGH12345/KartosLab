/// Photons layout — PhotonsScreenView / PhotonsExperimentSceneView / PhotonTestingArea.
library;

import 'qm_global_layout_spec.dart';

class QmPhotonsLayoutSpec {
  const QmPhotonsLayoutSpec();

  /// Scene Y offset = experimentModeRadioButtonGroup.bottom + 10
  /// Group top = SCREEN_VIEW_Y_MARGIN; height is content-driven → DYNAMIC.
  static const sceneTranslationExtraY = 10.0;

  /// PhotonTestingArea.center = (420, 225) in scene-local coords (empirically matched to design).
  static const experimentAreaCenterX = 420.0;
  static const experimentAreaCenterY = 225.0;

  /// ModelViewTransform2.createSinglePointScaleInvertedYMapping(ZERO, ZERO, 640)
  static const modelViewScale = 640.0;

  /// Model meters (PhotonsExperimentSceneModel)
  static const laserToBeamSplitterDistance = 0.15;
  static const beamSplitterToMirrorDistance = 0.11;
  static const totalPhotonPathLength = 0.15 + 0.11 + 0.09; // 0.35

  /// PBS size Dimension2(0.07, 0.07) meters
  static const pbsSizeMeters = 0.07;

  /// Laser.PHOTON_BEAM_WIDTH
  static const photonBeamWidthMeters = 0.04;

  static const probabilityPanelTop = 20.0;
  static const polarizationIndicatorScale = 1.5;
  static const averagePolarizationTitleMinWidth = 325.0;

  double probabilityPanelCenterX(double experimentAreaLeft) =>
      (qmScreenViewXMargin + experimentAreaLeft) / 2;

  /// View position of model point (mx, my) relative to experiment area origin.
  ({double x, double y}) modelToView(double mx, double my) => (
        x: mx * modelViewScale,
        y: -my * modelViewScale, // inverted Y
      );
}
