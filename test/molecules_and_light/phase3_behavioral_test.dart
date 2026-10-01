import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/molecules_and_light/model/micro_photon.dart';
import 'package:kratos/molecules_and_light/model/molecules_and_light_model.dart';
import 'package:kratos/molecules_and_light/molecules_and_light_constants.dart';
import 'package:kratos/molecules_and_light/view/molecules_and_light_screen.dart';
import 'package:kratos/molecules_and_light/view/spectrum_diagram_painter.dart';

void main() {
  MoleculesAndLightModel seeded(MoleculeType type) {
    final model = MoleculesAndLightModel(random: math.Random(1));
    model.setMolecule(type);
    for (final strategy in model.molecule.strategies.values) {
      strategy.absorptionProbability = 1;
    }
    return model;
  }

  void absorb(MoleculesAndLightModel model, LightType light) {
    model.photons.add(MicroPhoton(light.wavelength)..x = 0);
    model.manualStep(0.02);
  }

  Future<MoleculesAndLightScreenState> pumpSim(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: MoleculesAndLightScreen()));
    await tester.pump();
    return tester.state<MoleculesAndLightScreenState>(
      find.byType(MoleculesAndLightScreen),
    );
  }

  group('spectrum diagram geometry', () {
    test('logarithmic frequency span matches SpectrumDiagram.js', () {
      expect(SpectrumDiagramPainter.subsectionWidth, 657);
      expect(SpectrumDiagramPainter.stripHeight, 87);
      expect(SpectrumDiagramPainter.minFrequency, 1e3);
      expect(SpectrumDiagramPainter.maxFrequency, 1e21);
      expect(SpectrumDiagramPainter.offsetFromFrequency(1e3), closeTo(0, 1e-9));
      expect(
        SpectrumDiagramPainter.offsetFromFrequency(1e21),
        closeTo(657, 1e-6),
      );
      final visLeft = SpectrumDiagramPainter.offsetFromFrequency(400e12);
      final visRight = SpectrumDiagramPainter.offsetFromFrequency(790e12);
      expect(visRight, greaterThan(visLeft));
      expect(visLeft, greaterThan(300));
      expect(visRight, lessThan(500));
    });
  });

  group('spectrum dialog lifecycle', () {
    testWidgets('open close reopen does not mutate simulation state',
        (tester) async {
      final state = await pumpSim(tester);
      state.model.setEmitterOn(true);
      state.model.setLight(LightType.visible);
      state.model.setMolecule(MoleculeType.water);
      state.model.running = false;
      state.model.timeSpeed = TimeSpeed.slow;
      state.model.manualStep(0.05);
      final photonCount = state.model.photons.length;
      final light = state.model.light;
      final molecule = state.model.moleculeType;
      final running = state.model.running;
      final speed = state.model.timeSpeed;
      final emitter = state.model.emitterOn;

      Future<void> openClose() async {
        await tester.tap(find.byKey(const Key('spectrum-button')));
        await tester.pump();
        expect(find.byKey(const Key('spectrum-dialog')), findsOneWidget);
        expect(find.byKey(const Key('spectrum-strip')), findsOneWidget);
        expect(find.byKey(const Key('spectrum-title')), findsOneWidget);
        await tester.tap(find.byKey(const Key('spectrum-close')));
        await tester.pump();
        expect(find.byKey(const Key('spectrum-dialog')), findsNothing);
      }

      await openClose();
      await openClose();

      expect(state.model.photons.length, photonCount);
      expect(state.model.light, light);
      expect(state.model.moleculeType, molecule);
      expect(state.model.running, running);
      expect(state.model.timeSpeed, speed);
      expect(state.model.emitterOn, emitter);
    });

    testWidgets('spectrum while playing and after light selection',
        (tester) async {
      final state = await pumpSim(tester);
      expect(state.model.running, isTrue);
      await tester.tap(find.byKey(const Key('light-Microwave')));
      await tester.pump();
      expect(state.model.light, LightType.microwave);

      await tester.tap(find.byKey(const Key('spectrum-button')));
      await tester.pump();
      expect(find.byKey(const Key('spectrum-dialog')), findsOneWidget);
      expect(state.model.light, LightType.microwave);
      expect(state.model.running, isTrue);

      await tester.tap(find.byKey(const Key('spectrum-close')));
      await tester.pump();
      expect(state.model.light, LightType.microwave);
      expect(state.model.running, isTrue);
    });
  });

  group('controls and state switches', () {
    testWidgets('pause slow step reset preserve source defaults',
        (tester) async {
      final state = await pumpSim(tester);

      await tester.tap(find.byKey(const Key('speed-toggle')));
      await tester.pump();
      expect(state.model.timeSpeed, TimeSpeed.slow);
      expect(
        MoleculesAndLightConstants.slowSpeedFactor,
        0.5,
      );

      await tester.tap(find.byKey(const Key('play-pause')));
      await tester.pump();
      expect(state.model.running, isFalse);

      state.model.setEmitterOn(true);
      final before = state.model.photons.length;
      await tester.tap(find.byKey(const Key('step-forward')));
      await tester.pump();
      expect(state.model.photons.length, greaterThanOrEqualTo(before));

      await tester.tap(find.byKey(const Key('molecule-CH₄')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('light-Ultraviolet')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('spectrum-button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('spectrum-close')));
      await tester.pump();

      await tester.tap(find.byType(KratosResetAllButton));
      await tester.pump();
      expect(state.model.light, LightType.infrared);
      expect(state.model.emitterOn, isFalse);
      expect(state.model.moleculeType, MoleculeType.carbonMonoxide);
      expect(state.model.running, isTrue);
      expect(state.model.timeSpeed, TimeSpeed.normal);
      expect(state.model.photons, isEmpty);
    });

    test('photon in flight cleared on light switch; absorbed identity kept',
        () {
      final model = seeded(MoleculeType.carbonMonoxide);
      model.setEmitterOn(true);
      model.manualStep(0.02);
      expect(model.photons, isNotEmpty);
      final flyingX = model.photons.first.x;
      model.setLight(LightType.microwave);
      expect(model.photons, isEmpty);
      expect(flyingX, isNotNull);

      absorb(model, LightType.infrared);
      expect(model.molecule.vibrating, isTrue);
      model.setLight(LightType.ultraviolet);
      model.manualStep(1.4);
      expect(
        model.photons.any((p) => p.wavelength == LightType.infrared.wavelength),
        isTrue,
      );
    });

    test('switching molecule while vibrating installs a fresh molecule', () {
      final model = seeded(MoleculeType.carbonMonoxide);
      absorb(model, LightType.infrared);
      expect(model.molecule.vibrating, isTrue);
      model.setMolecule(MoleculeType.nitrogen);
      expect(model.moleculeType, MoleculeType.nitrogen);
      expect(model.molecule.vibrating, isFalse);
      expect(model.molecule.strategies, isEmpty);
    });

    test('pause freezes canvas-driving model; resume continues', () {
      final model = seeded(MoleculeType.nitrogen);
      model.setEmitterOn(true);
      model.manualStep(0.02);
      final x = model.photons.first.x;
      model.running = false;
      model.step(0.5);
      expect(model.photons.first.x, x);
      model.running = true;
      model.step(0.05);
      expect(model.photons.first.x, greaterThan(x));
    });

    test('manual steps advance discretely while paused', () {
      final model = seeded(MoleculeType.nitrogen);
      model.setEmitterOn(true);
      model.running = false;
      model.manualStep();
      final x1 = model.photons.single.x;
      model.manualStep();
      final x2 = model.photons.single.x;
      model.manualStep();
      final x3 = model.photons.single.x;
      expect(x2, greaterThan(x1));
      expect(x3, greaterThan(x2));
      model.step(1);
      expect(model.photons.single.x, x3);
    });
  });

  group('32 combination view-model regression', () {
    const expected = {
      MoleculeType.carbonMonoxide: {
        LightType.microwave: 'rotation',
        LightType.infrared: 'vibration',
      },
      MoleculeType.nitrogen: {},
      MoleculeType.oxygen: {},
      MoleculeType.carbonDioxide: {LightType.infrared: 'vibration'},
      MoleculeType.methane: {LightType.infrared: 'vibration'},
      MoleculeType.water: {
        LightType.microwave: 'rotation',
        LightType.infrared: 'vibration',
      },
      MoleculeType.nitrogenDioxide: {
        LightType.microwave: 'rotation',
        LightType.infrared: 'vibration',
        LightType.visible: 'excitation',
        LightType.ultraviolet: 'break',
      },
      MoleculeType.ozone: {
        LightType.microwave: 'rotation',
        LightType.infrared: 'vibration',
        LightType.ultraviolet: 'break',
      },
    };

    for (final molecule in MoleculeType.values) {
      for (final light in LightType.values) {
        test('${molecule.name} × ${light.name}', () {
          final model = seeded(molecule);
          model.setLight(light);
          absorb(model, light);
          final want = expected[molecule]![light];
          if (want == null) {
            expect(model.molecule.vibrating, isFalse);
            expect(model.molecule.rotating, isFalse);
            expect(model.molecule.highElectronicEnergy, isFalse);
            expect(model.molecule.brokenApart, isFalse);
            expect(model.photons, isNotEmpty);
            return;
          }
          switch (want) {
            case 'rotation':
              expect(model.molecule.rotating, isTrue);
              expect(model.photons, isEmpty);
            case 'vibration':
              expect(model.molecule.vibrating, isTrue);
              expect(model.photons, isEmpty);
            case 'excitation':
              expect(model.molecule.highElectronicEnergy, isTrue);
              expect(model.photons, isEmpty);
            case 'break':
              model.manualStep(0.02);
              expect(model.molecule.brokenApart, isTrue);
          }
        });
      }
    }
  });

  testWidgets('dispose releases SimulationClock', (tester) async {
    await pumpSim(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
