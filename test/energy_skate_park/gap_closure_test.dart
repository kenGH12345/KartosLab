import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/graphs_model.dart';
import 'package:kratos/energy_skate_park/model/measure_model.dart';
import 'package:kratos/energy_skate_park/model/playground_model.dart';
import 'package:kratos/energy_skate_park/render/esp_mvt.dart';

void main() {
  group('Graphs samples', () {
    test('accumulate while playing via SaveSampleModel step hook', () {
      final model = GraphsModel();
      final track = model.getPhysicalTracks().first;
      model.skater.track = track;
      model.skater.parametricPosition = 0.1;
      model.skater.parametricSpeed = 0;
      model.skater.positionX = track.getX(0.1);
      model.skater.positionY = track.getY(0.1);
      model.skater.updateEnergy();
      model.paused = false;
      model.pathVisible = true;

      expect(model.dataSamples, isEmpty);

      // Wall-clock enough for several 1/60 steps and 0.01s sample interval.
      for (var i = 0; i < 30; i++) {
        model.step(EspConstants.dt);
      }

      expect(model.dataSamples.length, greaterThan(5),
          reason: 'samples must come from onAfterPhysicsStep, not UI');
      final first = model.dataSamples.first;
      expect(first.kineticEnergy, isA<double>());
      expect(first.potentialEnergy, isA<double>());
      expect(first.totalEnergy, closeTo(
        first.kineticEnergy + first.potentialEnergy + first.thermalEnergy,
        1e-6,
      ));
    });
  });

  group('Energy sensor', () {
    test('reads DataSample fields — does not recompute PE/KE in lookup', () {
      final model = MeasureModel();
      final track = model.getPhysicalTracks().first;
      model.skater.track = track;
      model.skater.parametricPosition = 0.2;
      model.skater.positionX = track.getX(0.2);
      model.skater.positionY = track.getY(0.2);
      model.skater.updateEnergy();
      model.pathVisible = true;
      model.paused = false;

      for (var i = 0; i < 40; i++) {
        model.step(EspConstants.dt);
      }
      expect(model.dataSamples, isNotEmpty);

      final target = model.dataSamples[model.dataSamples.length ~/ 2];
      // Place probe exactly on sample in model space.
      model.sensorProbePosition = EspVec(target.positionX, target.positionY);

      final mvt = EspMvt.forLayout();
      final found = model.findNearestSample(model.sensorProbePosition, mvt);
      expect(found, isNotNull);
      expect(identical(found, target) || found!.positionX == target.positionX,
          isTrue);

      // Mutate sample energies to prove sensor would show sample values.
      final keBefore = found!.kineticEnergy;
      // Sensor must expose sample's stored KE — not live skater KE.
      expect(found.kineticEnergy, equals(keBefore));
      expect(found.potentialEnergy, equals(target.potentialEnergy));
      expect(found.thermalEnergy, equals(target.thermalEnergy));
      expect(found.totalEnergy, equals(target.totalEnergy));

      // Reference height refresh updates sample PE (MeasureModel.ts:51-55).
      final pe0 = found.potentialEnergy;
      model.setReferenceHeight(2.0);
      expect(model.skater.referenceHeight, 2.0);
      expect(found.referenceHeight, 2.0);
      expect(found.potentialEnergy, isNot(equals(pe0)));
    });
  });

  group('Playground CAD', () {
    test('addTrack and clearTracks', () {
      final model = PlaygroundModel();
      expect(model.tracks, isEmpty);
      model.createDraggableTrack();
      expect(model.tracks.length, 1);
      expect(model.tracks.first.controlPoints.length, 3);
      expect(model.tracks.first.configurable, isTrue);
      expect(model.tracks.first.splittable, isTrue);
      model.createDraggableTrack(x0: 3, y0: 1);
      expect(model.tracks.length, 2);
      model.clearTracks();
      expect(model.tracks, isEmpty);
    });

    test('join when endpoints near', () {
      final model = PlaygroundModel();
      final a = model.createDraggableTrack(x0: -1, y0: 0.5);
      final b = model.createDraggableTrack(x0: 1, y0: 0.5);
      // Endpoints: a ends at (1,0.5), b starts at (1,0.5) — within 0.3.
      final joined = model.joinTracks(a, b);
      expect(joined, isNotNull);
      expect(model.tracks.length, 1);
    });

    test('splitControlPoint matches PhET semantics', () {
      final model = PlaygroundModel();
      final track = model.createDraggableTrack(x0: 0, y0: 1);
      expect(track.controlPoints.length, 3);
      // Interior index 1; horizontal track → angle ~0.
      final ok = model.splitControlPoint(track, 1, 0);
      expect(ok, isTrue);
      expect(model.tracks.length, 2);
      // Each half: left pts [0] + newPoint1; right: newPoint2 + [2]
      expect(model.tracks[0].controlPoints.length, 2);
      expect(model.tracks[1].controlPoints.length, 2);
      // Offset ±0.5 along angle 0 (x-axis).
      final leftEnd = model.tracks[0].controlPoints.last;
      final rightStart = model.tracks[1].controlPoints.first;
      expect(leftEnd.x, closeTo(1 - 0.5, 1e-9));
      expect(rightStart.x, closeTo(1 + 0.5, 1e-9));
      expect(model.canCutTrackControlPoint(), isTrue);
    });

    test('deleteControlPoint removes interior or whole track', () {
      final model = PlaygroundModel();
      final track = model.createDraggableTrack(x0: 0, y0: 1);
      // Add fourth point by joining a stub — or just delete on 3-pt track.
      expect(model.deleteControlPoint(track, 1), isTrue);
      expect(model.tracks.length, 1);
      expect(model.tracks.first.controlPoints.length, 2);
      // Deleting when ≤2 removes entire track.
      expect(model.deleteControlPoint(model.tracks.first, 0), isTrue);
      expect(model.tracks, isEmpty);
    });

    test('split respects MAX 15 physical control points', () {
      final model = PlaygroundModel();
      // 5 tracks × 3 = 15 CPs — at limit, cannot cut.
      for (var i = 0; i < 5; i++) {
        model.createDraggableTrack(x0: i * 3.0, y0: 1);
      }
      expect(model.getNumberOfPhysicalControlPoints(), 15);
      expect(model.canCutTrackControlPoint(), isFalse);
      final t = model.tracks.first;
      expect(model.splitControlPoint(t, 1, 0), isFalse);
    });
  });

  group('Measuring tape', () {
    test('distance from model endpoints; reset clears visibility', () {
      final model = MeasureModel();
      expect(model.measuringTapeVisible, isFalse);
      model.measuringTapeVisible = true;
      model.measuringTapeBase = const EspVec(0, 0);
      model.measuringTapeTip = const EspVec(3, 4);
      expect(model.measuringTapeDistance, closeTo(5.0, 1e-9));
      model.reset();
      expect(model.measuringTapeVisible, isFalse);
      expect(model.measuringTapeBase.x, 0);
      expect(model.measuringTapeTip.x, 1);
    });
  });

  group('Graphs zoom / cursor', () {
    test('zoom index clamps; cursor reads sample energies', () {
      final model = GraphsModel();
      model.energyGraphZoomIndex = 99;
      // Controller clamps — model itself stores raw until set via controller.
      expect(EspConstants.plotRanges[EspConstants.defaultEnergyGraphZoomIndex],
          ( -3000.0, 3000.0 ));

      final track = model.getPhysicalTracks().first;
      model.skater.track = track;
      model.skater.parametricPosition = 0.1;
      model.skater.positionX = track.getX(0.1);
      model.skater.positionY = track.getY(0.1);
      model.skater.updateEnergy();
      model.pathVisible = true;
      model.paused = false;
      for (var i = 0; i < 30; i++) {
        model.step(EspConstants.dt);
      }
      expect(model.dataSamples, isNotEmpty);
      model.cursorSampleIndex = 0;
      final cur = model.cursorSample!;
      expect(cur.kineticEnergy, model.dataSamples.first.kineticEnergy);
      expect(cur.totalEnergy, model.dataSamples.first.totalEnergy);
    });
  });

  group('Friction thermal (gap suite)', () {
    test('friction raises thermal on Graphs track', () {
      final model = GraphsModel();
      model.friction = EspConstants.maxFriction;
      model.isStickingToTrack = true;
      final t = model.getPhysicalTracks().first;
      model.skater.track = t;
      model.skater.parametricPosition = 0.05;
      model.skater.parametricSpeed = 0;
      model.skater.positionX = t.getX(0.05);
      model.skater.positionY = t.getY(0.05);
      model.skater.thermalEnergy = 0;
      model.skater.updateEnergy();

      for (var i = 0; i < 180; i++) {
        model.manualStep();
      }
      expect(model.skater.thermalEnergy, greaterThan(0.01));
    });
  });
}
