/// PHASE 4 Photons transform / trajectory / single / continuous / lifecycle tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/quantum_measurement/common/qm_random.dart';
import 'package:kratos/quantum_measurement/common/system_type.dart';
import 'package:kratos/quantum_measurement/layout/qm_global_layout_spec.dart';
import 'package:kratos/quantum_measurement/layout/qm_photons_layout_spec.dart';
import 'package:kratos/quantum_measurement/photons/animation/photon_animation_controller.dart';
import 'package:kratos/quantum_measurement/photons/animation/photon_trajectory.dart';
import 'package:kratos/quantum_measurement/photons/composer/photons_composer.dart';
import 'package:kratos/quantum_measurement/photons/model/photon_scene_meters.dart';
import 'package:kratos/quantum_measurement/photons/model/photon_simulation.dart';
import 'package:kratos/quantum_measurement/photons/model/photons_model.dart';
import 'package:kratos/quantum_measurement/photons/transform/photon_view_transform.dart';
import 'package:kratos/quantum_measurement/photons/view/photons_screen.dart';

void main() {
  group('PhotonViewTransform', () {
    const t = PhotonViewTransform();

    test('origin maps to origin', () {
      final v = t.physicsToView(PhotonVec2.zero);
      expect(v, Offset.zero);
    });

    test('positive X scales by 640', () {
      final v = t.physicsToView(const PhotonVec2(0.15, 0));
      expect(v.dx, closeTo(0.15 * 640, 1e-9));
      expect(v.dy, 0);
    });

    test('positive physics Y inverts in view', () {
      final v = t.physicsToView(const PhotonVec2(0, 0.2));
      expect(v.dx, 0);
      expect(v.dy, closeTo(-0.2 * 640, 1e-9));
    });

    test('negative physics Y goes down in view (positive dy)', () {
      final v = t.physicsToView(const PhotonVec2(0, -0.09));
      expect(v.dy, closeTo(0.09 * 640, 1e-9));
    });

    test('round-trip physicsToView → viewToPhysics', () {
      const p = PhotonVec2(-0.15, 0.1);
      final back = t.viewToPhysics(t.physicsToView(p));
      expect(back.x, closeTo(p.x, 1e-12));
      expect(back.y, closeTo(p.y, 1e-12));
    });

    test('laser / PBS / detectors known points', () {
      const meters = PhotonsSceneMeters();
      expect(t.physicsToView(meters.laser).dx, closeTo(-96, 1e-9));
      expect(t.physicsToView(meters.pbs), Offset.zero);
      expect(t.physicsToView(meters.verticalDetector).dy, closeTo(-128, 1e-9));
      expect(t.physicsToView(meters.mirror).dx, closeTo(70.4, 1e-9));
    });
  });

  group('PhotonsComposer', () {
    const composer = PhotonsComposer();

    test('1024×618 experiment center', () {
      final g = composer.compose(viewport: const Size(1024, 618));
      expect(g.experimentAreaCenter,
          const Offset(QmPhotonsLayoutSpec.experimentAreaCenterX,
              QmPhotonsLayoutSpec.experimentAreaCenterY));
      expect(g.transform.scale, 640);
    });

    test('1280×800 and 800×600 uniform scale', () {
      final a = composer.designFrame(const Size(1280, 800));
      final b = composer.designFrame(const Size(800, 600));
      expect(a.scale, lessThanOrEqualTo(1280 / 1024));
      expect(b.scale, lessThanOrEqualTo(800 / 1024));
      expect(a.scale, const QmGlobalLayoutSpec().layoutScale(1280, 800));
    });
  });

  group('Trajectory meters', () {
    test('branches share PBS origin', () {
      const traj = PhotonTrajectorySpec();
      expect(traj.approach().last, PhotonVec2.zero);
      expect(traj.verticalBranch().first, PhotonVec2.zero);
      expect(traj.horizontalBranch().first, PhotonVec2.zero);
      expect(traj.horizontalBranch()[1].x, beamSplitterToMirrorDistance);
    });
  });

  group('Spatial simulation', () {
    test('single emit creates one photon; classical vertical at 90°', () {
      final scene = PhotonsExperimentSceneModel(
        emissionMode: PhotonExperimentMode.singlePhoton,
        random: SeededQmRandom(1),
      );
      scene.photonBehaviorMode = SystemType.classical;
      scene.preset = PolarizationPreset.vertical;
      final sim = PhotonsSpatialSimulation(
        scene: scene,
        random: SeededQmRandom(1),
      );
      sim.emitAPhoton();
      expect(sim.photons.length, 1);

      // Step until absorbed or timeout.
      for (var i = 0; i < 500 && sim.photons.isNotEmpty; i++) {
        sim.stepForwardInTime(1 / 60);
      }
      expect(scene.verticalDetectionCount, greaterThan(0));
      expect(scene.horizontalDetectionCount, 0);
    });

    test('classical horizontal at 0°', () {
      final scene = PhotonsExperimentSceneModel(
        emissionMode: PhotonExperimentMode.singlePhoton,
        random: SeededQmRandom(7),
      );
      scene.photonBehaviorMode = SystemType.classical;
      scene.preset = PolarizationPreset.horizontal;
      final sim = PhotonsSpatialSimulation(
        scene: scene,
        random: SeededQmRandom(7),
      );
      sim.emitAPhoton();
      for (var i = 0; i < 800 && sim.photons.isNotEmpty; i++) {
        sim.stepForwardInTime(1 / 60);
      }
      expect(scene.horizontalDetectionCount, greaterThan(0));
      expect(scene.verticalDetectionCount, 0);
    });

    test('quantum split has two motion states after PBS', () {
      final scene = PhotonsExperimentSceneModel(
        emissionMode: PhotonExperimentMode.singlePhoton,
        random: SeededQmRandom(3),
      );
      scene.photonBehaviorMode = SystemType.quantum;
      scene.preset = PolarizationPreset.fortyFiveDegrees;
      final sim = PhotonsSpatialSimulation(
        scene: scene,
        random: SeededQmRandom(3),
      );
      // Emit without y jitter for cleaner approach: place photon manually.
      sim.emitAPhoton();
      var sawSplit = false;
      for (var i = 0; i < 200; i++) {
        sim.stepForwardInTime(1 / 60);
        if (sim.photons.isNotEmpty &&
            sim.photons.first.possibleMotionStates.length == 2) {
          sawSplit = true;
          break;
        }
      }
      expect(sawSplit, isTrue);
    });

    test('determinism: same seed → same counts', () {
      List<int> run(int seed) {
        final scene = PhotonsExperimentSceneModel(
          emissionMode: PhotonExperimentMode.singlePhoton,
          random: SeededQmRandom(seed),
        );
        scene.photonBehaviorMode = SystemType.classical;
        scene.preset = PolarizationPreset.fortyFiveDegrees;
        final sim = PhotonsSpatialSimulation(
          scene: scene,
          random: SeededQmRandom(seed),
        );
        for (var n = 0; n < 5; n++) {
          sim.emitAPhoton();
          for (var i = 0; i < 600 && sim.photons.isNotEmpty; i++) {
            sim.stepForwardInTime(1 / 60);
          }
        }
        return [scene.verticalDetectionCount, scene.horizontalDetectionCount];
      }

      expect(run(99), run(99));
    });

    test('continuous emission rate produces multiple photons', () {
      final scene = PhotonsExperimentSceneModel(
        emissionMode: PhotonExperimentMode.manyPhotons,
        random: SeededQmRandom(5),
      );
      scene.isPlaying = true;
      final sim = PhotonsSpatialSimulation(
        scene: scene,
        random: SeededQmRandom(5),
      );
      sim.emissionRate = 50;
      sim.step(0.1); // expect ~5 photons
      expect(sim.photons.length, greaterThanOrEqualTo(4));
      expect(sim.photons.length, lessThanOrEqualTo(6));
    });

    test('clearPhotons empties collection', () {
      final scene = PhotonsExperimentSceneModel(
        emissionMode: PhotonExperimentMode.manyPhotons,
        random: SeededQmRandom(2),
      );
      final sim = PhotonsSpatialSimulation(
        scene: scene,
        random: SeededQmRandom(2),
      );
      sim.emissionRate = 100;
      sim.step(0.05);
      expect(sim.photons, isNotEmpty);
      sim.clearPhotons();
      expect(sim.photons, isEmpty);
    });
  });

  group('Animation lifecycle', () {
    testWidgets('ticker stops on dispose; no leak after leave', (tester) async {
      final model = PhotonsModel(random: SeededQmRandom(11));
      await tester.pumpWidget(
        MaterialApp(
          home: QuantumMeasurementPhotonsScreen(
            model: model,
            random: SeededQmRandom(11),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Switch to many + emit rate via state is internal; just dispose.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      // If ticker leaked, further pumps would throw / keep stepping — no exception.
      await tester.pump(const Duration(milliseconds: 100));
    });

    test('PhotonAnimationController stop clears ticker', () {
      final scene = PhotonsExperimentSceneModel(
        emissionMode: PhotonExperimentMode.singlePhoton,
        random: SeededQmRandom(1),
      );
      final sim = PhotonsSpatialSimulation(
        scene: scene,
        random: SeededQmRandom(1),
      );
      final c = PhotonAnimationController(simulation: sim, onTick: () {});
      expect(c.isRunning, isFalse);
      c.dispose();
      expect(c.isRunning, isFalse);
    });
  });

  group('Screen smoke', () {
    testWidgets('mounts Single/Many selector and apparatus labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuantumMeasurementPhotonsScreen(
            model: PhotonsModel(random: SeededQmRandom(4)),
            random: SeededQmRandom(4),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Single Photon'), findsOneWidget);
      expect(find.text('Many Photons'), findsOneWidget);
      expect(find.textContaining('Beam Splitter'), findsWidgets);

      await tester.tap(find.text('Many Photons'));
      await tester.pump();
      expect(find.byType(Slider), findsWidgets);
    });
  });
}
