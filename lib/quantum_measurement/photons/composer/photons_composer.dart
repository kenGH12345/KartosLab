/// PhotonsComposer — applies QmPhotonsLayoutSpec; no probability / RNG.
library;

import 'dart:ui';

import '../../layout/qm_global_layout_spec.dart';
import '../../layout/qm_photons_layout_spec.dart';
import '../model/photon_scene_meters.dart';
import '../transform/photon_view_transform.dart';

class PhotonsLayoutGeometry {
  const PhotonsLayoutGeometry({
    required this.designSize,
    required this.sceneSelector,
    required this.sceneOriginY,
    required this.experimentAreaCenter,
    required this.experimentAreaOrigin,
    required this.transform,
    required this.laserView,
    required this.pbsView,
    required this.mirrorView,
    required this.verticalDetectorView,
    required this.horizontalDetectorView,
    required this.pbsSizeView,
    required this.probabilityPanelCenter,
    required this.angleControlBottomLeft,
    required this.averagePolarizationTopRight,
    required this.resetAll,
  });

  final Size designSize;
  final Rect sceneSelector;
  final double sceneOriginY;
  final Offset experimentAreaCenter;
  final Offset experimentAreaOrigin;
  final PhotonViewTransform transform;
  final Offset laserView;
  final Offset pbsView;
  final Offset mirrorView;
  final Offset verticalDetectorView;
  final Offset horizontalDetectorView;
  final Size pbsSizeView;
  final Offset probabilityPanelCenter;
  final Offset angleControlBottomLeft;
  final Offset averagePolarizationTopRight;
  final Offset resetAll;
}

class PhotonsComposer {
  const PhotonsComposer({
    this.global = const QmGlobalLayoutSpec(),
    this.photons = const QmPhotonsLayoutSpec(),
    this.meters = const PhotonsSceneMeters(),
  });

  final QmGlobalLayoutSpec global;
  final QmPhotonsLayoutSpec photons;
  final PhotonsSceneMeters meters;

  ({double scale, Offset origin}) designFrame(Size viewport) {
    final f = global.designFrame(viewport);
    return (scale: f.scale, origin: f.origin);
  }

  PhotonsLayoutGeometry compose({required Size viewport}) {
    // Scene selector roughly 48px tall under Y margin → scene Y ≈ 10+48+10.
    const sceneOriginY = qmScreenViewYMargin + 48 + QmPhotonsLayoutSpec.sceneTranslationExtraY;

    final expCenter = const Offset(
      QmPhotonsLayoutSpec.experimentAreaCenterX,
      QmPhotonsLayoutSpec.experimentAreaCenterY,
    );

    // Experiment area local origin = center in scene coords; transform origin at center.
    final transform = PhotonViewTransform(origin: Offset.zero);

    final laser = transform.physicsToView(meters.laser);
    final pbs = transform.physicsToView(meters.pbs);
    final mirror = transform.physicsToView(meters.mirror);
    final vDet = transform.physicsToView(meters.verticalDetector);
    final hDet = transform.physicsToView(meters.horizontalDetector);

    final pbsW = transform.modelToViewDeltaX(pbsSizeMeters).abs();
    final pbsH = transform.modelToViewDeltaX(pbsSizeMeters).abs();

    // Approximate experiment area left for probability panel.
    final expLeftApprox = expCenter.dx - 220;
    final probCx = photons.probabilityPanelCenterX(expLeftApprox);

    return PhotonsLayoutGeometry(
      designSize: Size(global.designWidth, global.designHeight),
      sceneSelector: Rect.fromLTWH(
        qmScreenViewXMargin,
        qmScreenViewYMargin,
        global.designWidth - 2 * qmScreenViewXMargin,
        48,
      ),
      sceneOriginY: sceneOriginY,
      experimentAreaCenter: expCenter,
      experimentAreaOrigin: expCenter,
      transform: transform,
      laserView: laser,
      pbsView: pbs,
      mirrorView: mirror,
      verticalDetectorView: vDet,
      horizontalDetectorView: hDet,
      pbsSizeView: Size(pbsW, pbsH),
      probabilityPanelCenter: Offset(probCx, QmPhotonsLayoutSpec.probabilityPanelTop + 60),
      angleControlBottomLeft: Offset(
        qmScreenViewXMargin,
        global.designHeight - sceneOriginY - qmScreenViewYMargin,
      ),
      averagePolarizationTopRight: Offset(
        global.designWidth - qmScreenViewXMargin,
        0,
      ),
      resetAll: Offset(
        global.designWidth - qmScreenViewXMargin,
        global.designHeight - qmScreenViewYMargin,
      ),
    );
  }
}
