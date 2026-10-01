/// Photons experiment scene body (single or many emission mode).
/// Layout mirrors PhotonsExperimentSceneView.ts module tree.
library;

import 'package:flutter/material.dart';

import '../composer/photons_composer.dart';
import '../components/angle_visualization.dart';
import '../components/average_polarization_panel.dart';
import '../components/detector.dart';
import '../components/measurement_element.dart';
import '../components/photon_controls.dart';
import '../components/photon_renderer.dart';
import '../components/photon_result_display.dart';
import '../components/photon_source.dart';
import '../model/photon_simulation.dart';
import '../model/photons_model.dart';
import '../qm_photons_colors.dart';
import '../transform/photon_view_transform.dart';

class PhotonsScene extends StatelessWidget {
  const PhotonsScene({
    super.key,
    required this.geometry,
    required this.simulation,
    required this.onChanged,
  });

  final PhotonsLayoutGeometry geometry;
  final PhotonsSpatialSimulation simulation;
  final VoidCallback onChanged;

  void _onPolarizationChanged(VoidCallback apply) {
    apply();
    final scene = simulation.scene;
    if (scene.emissionMode == PhotonExperimentMode.singlePhoton) {
      scene.resetDetectionCounts();
      simulation.clearPhotons();
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final scene = simulation.scene;
    final isMany = scene.emissionMode == PhotonExperimentMode.manyPhotons;
    final center = geometry.experimentAreaOrigin;
    final t = PhotonViewTransform(origin: center);

    final laser = t.physicsToView(simulation.meters.laser);
    final pbs = t.physicsToView(simulation.meters.pbs);
    final mirror = t.physicsToView(simulation.meters.mirror);
    final vDet = t.physicsToView(simulation.meters.verticalDetector);
    final hDet = t.physicsToView(simulation.meters.horizontalDetector);

    const laserW = 95.0 + 15.0;
    final angle = scene.preset == PolarizationPreset.unpolarized
        ? null
        : polarizationAngleDegrees(
            preset: scene.preset,
            customAngleDegrees: scene.customPolarizationAngle,
          );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Left: Probability + Oblique indicator ──
        Positioned(
          left: 12,
          top: 12,
          child: Column(
            children: [
              PhotonResultDisplay(scene: scene, isManyMode: isMany),
              const SizedBox(height: 16),
              AngleVisualization(angleDegrees: angle, radius: 48),
            ],
          ),
        ),

        // ── Right: Average Polarization ──
        Positioned(
          right: 8,
          top: 8,
          child: AveragePolarizationPanel(scene: scene),
        ),

        // ── Behavior above laser ──
        Positioned(
          left: laser.dx - laserW,
          top: laser.dy - 110,
          child: PhotonBehaviorControls(
            mode: scene.photonBehaviorMode,
            onChanged: (m) {
              scene.photonBehaviorMode = m;
              simulation.clearPhotons();
              onChanged();
            },
          ),
        ),

        // ── Laser ──
        Positioned(
          left: laser.dx - laserW,
          top: laser.dy - PhotonSourceNode.bodySize.height / 2,
          child: PhotonSourceNode(
            emissionMode: scene.emissionMode,
            emissionRate: simulation.emissionRate,
            onEmitSingle: () {
              simulation.emitAPhoton();
              onChanged();
            },
            onEmissionRateChanged: (v) {
              simulation.emissionRate = v;
              onChanged();
            },
          ),
        ),

        // ── PBS ──
        Positioned(
          left: pbs.dx - geometry.pbsSizeView.width / 2,
          top: pbs.dy - geometry.pbsSizeView.height / 2,
          child: PolarizingBeamSplitterNode(size: geometry.pbsSizeView),
        ),

        // ── Mirror ──
        Positioned(
          left: mirror.dx - 30,
          top: mirror.dy - 30,
          child: const MirrorNode(length: 60),
        ),

        // ── Detectors ──
        Positioned(
          left: vDet.dx - 80,
          top: vDet.dy -
              PhotonDetectorDisplay.apertureCenterFromTop(lookingUp: true),
          child: PhotonDetectorDisplay(
            label: 'Vertical Polarization Detector',
            highlightWord: 'Vertical',
            value: scene.verticalDetectionCount,
            lookingUp: true,
            showRate: isMany,
            highlightColor: QmPhotonsColors.verticalPolarization,
          ),
        ),
        Positioned(
          left: hDet.dx - 80,
          top: hDet.dy -
              PhotonDetectorDisplay.apertureCenterFromTop(lookingUp: false),
          child: PhotonDetectorDisplay(
            label: 'Horizontal Polarization Detector',
            highlightWord: 'Horizontal',
            value: scene.horizontalDetectionCount,
            lookingUp: false,
            showRate: isMany,
            highlightColor: QmPhotonsColors.horizontalPolarization,
          ),
        ),

        // ── Photon sprites ──
        Positioned.fill(
          child: IgnorePointer(
            child: PhotonRenderer(
              photons: simulation.photons,
              transform: t,
            ),
          ),
        ),

        // ── Bottom-left: Photon Polarization Angle panel ──
        Positioned(
          left: 8,
          bottom: 8,
          child: PhotonPolarizationAnglePanel(
            preset: scene.preset,
            customAngle: scene.customPolarizationAngle,
            onPresetChanged: (p) => _onPolarizationChanged(() {
              scene.preset = p;
            }),
            onCustomAngleChanged: (a) => _onPolarizationChanged(() {
              scene.customPolarizationAngle = a;
            }),
          ),
        ),

        // ── Bottom-center: Time controls (aligned near experiment) ──
        Positioned(
          left: center.dx - 40,
          bottom: 16,
          child: PhotonTimeControls(
            isPlaying: scene.isPlaying,
            slowMotion: scene.slowMotion,
            onPlayPause: () {
              scene.isPlaying = !scene.isPlaying;
              onChanged();
            },
            onSlowMotionChanged: (v) {
              scene.slowMotion = v;
              onChanged();
            },
            onStep: () {
              simulation.stepForwardInTime(2 / 60);
              onChanged();
            },
          ),
        ),
      ],
    );
  }
}
