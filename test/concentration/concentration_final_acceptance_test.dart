import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/audio/concentration_audio.dart';
import 'package:kratos/concentration/model/concentration_constants.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/probe_region.dart';
import 'package:kratos/concentration/model/solute_definitions.dart';
import 'package:kratos/concentration/model/solute_form.dart';
import 'package:kratos/concentration/view/concentration_layout.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';

/// Phase 8 — end-to-end behavioral acceptance (no new features).
void main() {
  const eps = 1e-12;

  ConcentrationModel fresh([int? seed]) =>
      ConcentrationModel(random: seed == null ? null : math.Random(seed));

  Offset beakerBottom(ConcentrationModel m) =>
      Offset(m.beaker.position.dx, m.beaker.position.dy - 0.0001);

  Offset waterJump(ConcentrationModel m) =>
      m.solventFaucet.position + const Offset(0, 10);

  Offset dropperJump(ConcentrationModel m) =>
      m.dropper.position + const Offset(0, 10);

  Offset drainJump(ConcentrationModel m) =>
      m.drainFaucet.position + const Offset(0, 10);

  void settleShaker(ConcentrationModel m, {int frames = 40}) {
    for (var i = 0; i < frames; i++) {
      m.step(0.05);
    }
  }

  void shake(ConcentrationModel m, {int moves = 12}) {
    for (var i = 0; i < moves; i++) {
      m.setShakerPosition(Offset(340 + i * 3.0, 160));
      m.step(0.05);
    }
    settleShaker(m);
  }

  group('Initial state', () {
    test('fresh model matches source defaults', () {
      final m = fresh();
      expect(m.soluteMoles, 0);
      expect(m.solutionVolume, 0.5);
      expect(m.soluteForm, SoluteForm.solid);
      expect(m.concentration, 0);
      expect(m.precipitateMoles, 0);
      expect(m.isSaturated, isFalse);
      expect(m.meter.probePosition, ConcentrationConstants.probeInitialPosition);
      m.setProbePosition(m.meter.probePosition);
      expect(m.meter.value, isNull);
      expect(m.meter.region, ProbeRegion.none);
      expect(m.shaker.dispensingRate, 0);
      expect(m.dropper.isDispensing, isFalse);
      expect(m.solventFaucet.flowRate, 0);
      expect(m.drainFaucet.flowRate, 0);
      expect(m.evaporator.evaporationRate, 0);
      expect(m.shakerParticles.count, 0);
      expect(m.precipitateParticles.count, 0);
    });
  });

  group('Solid workflow', () {
    test('shaker → particles → moles; volume unchanged', () {
      final m = fresh(1);
      m.setSolute(SoluteDefinitions.drinkMix);
      final v0 = m.solutionVolume;
      final n0 = m.soluteMoles;
      shake(m);
      expect(m.soluteMoles, greaterThan(n0));
      expect(m.solutionVolume, v0);
      // Each dissolved particle contributes 1/200 mol.
      final delta = m.soluteMoles - n0;
      expect((delta * 200).round() / 200, closeTo(delta, 1e-9));
      expect(m.concentration, closeTo(m.soluteMoles / m.solutionVolume, eps));
    });
  });

  group('Solution workflow', () {
    test('form switch + dropper: Δn = stock × ΔV', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.setSoluteForm(SoluteForm.solution);
      expect(m.soluteForm, SoluteForm.solution);
      expect(m.dropper.isVisible(m.soluteForm), isTrue);

      final stock = m.solute.stockSolutionConcentration;
      final v0 = m.solutionVolume;
      final n0 = m.soluteMoles;
      m.setDropperDispensing(true);
      m.step(0.2); // 0.05 L/s × 0.2 = 0.01 L
      m.setDropperDispensing(false);
      final dV = m.solutionVolume - v0;
      final dN = m.soluteMoles - n0;
      expect(dV, closeTo(0.01, eps));
      expect(dN, closeTo(stock * dV, eps));
    });

    test('shaker vs dropper semantics differ', () {
      final solid = fresh(2);
      solid.setSolute(SoluteDefinitions.drinkMix);
      final vSolid = solid.solutionVolume;
      shake(solid);
      expect(solid.solutionVolume, vSolid);
      expect(solid.soluteMoles, greaterThan(0));

      final sol = fresh();
      sol.setSolute(SoluteDefinitions.drinkMix);
      sol.setSoluteForm(SoluteForm.solution);
      final v0 = sol.solutionVolume;
      sol.setDropperDispensing(true);
      sol.step(0.2);
      sol.setDropperDispensing(false);
      expect(sol.solutionVolume, greaterThan(v0));
      expect(sol.soluteMoles, greaterThan(0));
    });
  });

  group('Water / Drain / Evaporation workflows', () {
    test('water dilutes: volume↑ solute flat concentration↓', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      expect(m.concentration, closeTo(1.0, eps));
      m.setSolventFlowRate(0.25);
      m.step(0.4);
      m.setSolventFlowRate(0);
      expect(m.soluteMoles, closeTo(0.5, eps));
      expect(m.solutionVolume, closeTo(0.6, eps));
      expect(m.concentration, closeTo(0.5 / 0.6, eps));
    });

    test('drain: Δn = c × ΔV; concentration preserved', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      final c = m.concentration;
      m.setDrainFlowRate(0.25);
      m.step(0.4);
      m.setDrainFlowRate(0);
      expect(m.solutionVolume, closeTo(0.4, eps));
      expect(m.soluteMoles, closeTo(0.4, eps));
      expect(m.concentration, closeTo(c, 1e-12));
    });

    test('evaporation → saturation → release snaps to 0', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(0.6);
      expect(m.isSaturated, isFalse);
      m.setEvaporationRate(0.25);
      m.step(0.4);
      expect(m.isSaturated, isTrue);
      expect(m.concentration, closeTo(1.38, eps));
      expect(m.precipitateMoles, greaterThan(0));
      m.releaseEvaporation();
      expect(m.evaporator.evaporationRate, 0);
    });
  });

  group('Saturation cycle', () {
    test('unsaturated → saturated → dilute → unsaturated', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(0.5);
      expect(m.isSaturated, isFalse);
      m.addSoluteAmount(0.3);
      expect(m.isSaturated, isTrue);
      expect(m.precipitateParticles.count, greaterThan(0));
      expect(m.concentration, lessThanOrEqualTo(m.saturatedConcentration));

      m.setSolventFlowRate(0.25);
      m.step(1.2);
      m.setSolventFlowRate(0);
      expect(m.isSaturated, isFalse);
      expect(m.precipitateMoles, 0);
      expect(m.precipitateParticles.count, 0);
    });

    test('saturated + shaker: concentration capped, precipitate rises', () {
      final m = fresh(7);
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(0.8);
      expect(m.isSaturated, isTrue);
      final n0 = m.soluteMoles;
      final p0 = m.precipitateMoles;
      shake(m, moves: 16);
      expect(m.soluteMoles, greaterThan(n0));
      expect(m.concentration, closeTo(1.38, eps));
      expect(m.concentration, lessThanOrEqualTo(m.saturatedConcentration));
      expect(m.precipitateMoles, greaterThan(p0));
    });
  });

  group('Remove / switch solute', () {
    test('remove solute clears moles/precipitate/particles; volume kept', () {
      final m = fresh(9);
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(1.5);
      shake(m, moves: 6);
      final vol = m.solutionVolume;
      m.removeSolute();
      expect(m.soluteMoles, 0);
      expect(m.precipitateMoles, 0);
      expect(m.isSaturated, isFalse);
      expect(m.precipitateParticles.count, 0);
      expect(m.shakerParticles.count, 0);
      expect(m.solutionVolume, vol);
    });

    test('solute switch clears state and adopts new sat/stock', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(1.5);
      expect(m.isSaturated, isTrue);
      m.setSolute(SoluteDefinitions.drinkMix);
      expect(m.soluteMoles, 0);
      expect(m.precipitateMoles, 0);
      expect(m.isSaturated, isFalse);
      expect(m.saturatedConcentration, SoluteDefinitions.drinkMix.saturatedConcentration);
      expect(
        m.solute.stockSolutionConcentration,
        SoluteDefinitions.drinkMix.stockSolutionConcentration,
      );
    });
  });

  group('Probe / Meter / J', () {
    test('region matrix: outside/solution/water/stock/drain', () {
      final m = fresh();
      m.addSoluteAmount(0.5);

      m.setProbePosition(const Offset(900, 200));
      expect(m.meter.value, isNull);

      m.setProbePosition(beakerBottom(m));
      expect(m.meter.value, closeTo(1.0, eps));

      m.setSolventFlowRate(0.25);
      m.setProbePosition(waterJump(m));
      expect(m.meter.value, 0);
      m.setSolventFlowRate(0);
      expect(m.meter.value, isNull);

      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      m.setProbePosition(dropperJump(m));
      expect(
        m.meter.value,
        closeTo(m.solute.stockSolutionConcentration, eps),
      );
      m.setDropperDispensing(false);
      expect(m.meter.value, isNull);

      m.setDrainFlowRate(0.25);
      m.setProbePosition(drainJump(m));
      expect(m.meter.value, closeTo(m.concentration, eps));
      m.setDrainFlowRate(0);
      expect(m.meter.value, isNull);
    });

    test('probe in solution tracks dynamic concentration', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setProbePosition(beakerBottom(m));
      expect(m.meter.value, closeTo(1.0, eps));

      m.setSolventFlowRate(0.25);
      m.step(0.4);
      m.setSolventFlowRate(0);
      expect(m.meter.value, closeTo(0.5 / 0.6, eps));

      m.setEvaporationRate(0.25);
      m.step(0.4);
      m.releaseEvaporation();
      expect(m.meter.value, closeTo(0.5 / 0.5, eps));
    });

    test('liquid falls below probe → null', () {
      final m = fresh();
      m.addSoluteAmount(0.1);
      m.setProbePosition(const Offset(350, 480));
      expect(m.meter.region, ProbeRegion.solution);
      m.setDrainFlowRate(0.25);
      for (var i = 0; i < 20 && m.solutionVolume > 0.05; i++) {
        m.step(0.1);
      }
      m.setDrainFlowRate(0);
      expect(m.meter.value, isNull);
    });

    test('J cycle solid skips dropper; solution includes dropper', () {
      final solid = fresh();
      final hits = <String>[];
      for (var i = 0; i < 4; i++) {
        final p = solid.jumpProbeToNext();
        if ((p - dropperJump(solid)).distance < 1e-6) hits.add('dropper');
      }
      expect(hits, isEmpty);

      final sol = fresh();
      sol.setSoluteForm(SoluteForm.solution);
      var sawDropper = false;
      for (var i = 0; i < 5; i++) {
        final p = sol.jumpProbeToNext();
        if ((p - dropperJump(sol)).distance < 1e-6) sawDropper = true;
      }
      expect(sawDropper, isTrue);
    });

    test('unit switch changes display only', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setProbePosition(beakerBottom(m));
      final mol = m.meter.value!;
      m.setMeterUnits(ConcentrationMeterUnits.percent);
      expect(m.meter.value, closeTo(m.solution.percentConcentration, eps));
      expect(m.concentration, closeTo(mol, eps));
      m.setMeterUnits(ConcentrationMeterUnits.molesPerLiter);
      expect(m.meter.value, closeTo(mol, eps));
    });
  });

  group('Audio acceptance', () {
    test('grab/release once; reset clears latch', () async {
      final audio = RecordingConcentrationAudio();
      await audio.onDragStart();
      await audio.onDragStart();
      expect(audio.grabCount, 1);
      await audio.onDragEnd();
      expect(audio.releaseCount, 1);
      await audio.onDragStart();
      await audio.stopAll();
      expect(audio.isDragging, isFalse);
      await audio.onDragEnd();
      expect(audio.releaseCount, 1);
    });
  });

  group('Reset / lifecycle / cycles', () {
    test('full-state reset restores initials', () {
      final m = fresh(3);
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(1.2);
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      m.setSolventFlowRate(0.1);
      m.setDrainFlowRate(0.05);
      m.setEvaporationRate(0.1);
      m.setProbePosition(beakerBottom(m));
      m.jumpProbeToNext();
      shake(m, moves: 4);
      m.reset();

      expect(m.solute, SoluteDefinitions.drinkMix);
      expect(m.soluteForm, SoluteForm.solid);
      expect(m.soluteMoles, 0);
      expect(m.solutionVolume, 0.5);
      expect(m.isSaturated, isFalse);
      expect(m.precipitateParticles.count, 0);
      expect(m.shakerParticles.count, 0);
      expect(m.solventFaucet.flowRate, 0);
      expect(m.drainFaucet.flowRate, 0);
      expect(m.evaporator.evaporationRate, 0);
      expect(m.dropper.isDispensing, isFalse);
      expect(m.meter.probePosition, ConcentrationConstants.probeInitialPosition);
      expect(m.meter.value, isNull);
      expect(m.probeJump.index, 0);
    });

    test('reset while shaker particles airborne clears them', () {
      final m = fresh(5);
      for (var i = 0; i < 8; i++) {
        m.setShakerPosition(Offset(340 + i * 2.0, 160));
        m.step(0.05);
      }
      expect(m.shakerParticles.count, greaterThan(0));
      m.reset();
      expect(m.shakerParticles.count, 0);
    });

    test('reset while saturated clears precipitate', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(2.0);
      expect(m.isSaturated, isTrue);
      expect(m.precipitateParticles.count, greaterThan(0));
      m.reset();
      expect(m.isSaturated, isFalse);
      expect(m.precipitateMoles, 0);
      expect(m.solutionVolume, 0.5);
    });

    test('repeated solid cycle ×5 no accumulation', () {
      final m = fresh(11);
      for (var cycle = 0; cycle < 5; cycle++) {
        m.setSolute(SoluteDefinitions.drinkMix);
        shake(m, moves: 8);
        m.setSolventFlowRate(0.25);
        m.step(0.2);
        m.setSolventFlowRate(0);
        m.setDrainFlowRate(0.25);
        m.step(0.1);
        m.setDrainFlowRate(0);
        m.setEvaporationRate(0.1);
        m.step(0.1);
        m.releaseEvaporation();
        m.setProbePosition(beakerBottom(m));
        m.reset();
        expect(m.soluteMoles, 0);
        expect(m.solutionVolume, 0.5);
        expect(m.shakerParticles.count, 0);
        expect(m.precipitateParticles.count, 0);
        expect(m.meter.value, isNull);
      }
    });

    test('alternate solution-form cycle', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      m.step(0.3);
      m.setDropperDispensing(false);
      m.setSolventFlowRate(0.25);
      m.step(0.2);
      m.setSolventFlowRate(0);
      m.setDrainFlowRate(0.25);
      m.step(0.1);
      m.setDrainFlowRate(0);
      m.setProbePosition(beakerBottom(m));
      m.addSoluteAmount(2.0);
      if (m.isSaturated) {
        expect(m.precipitateParticles.count, greaterThan(0));
      }
      m.removeSolute();
      expect(m.soluteMoles, 0);
      m.reset();
      expect(m.soluteForm, SoluteForm.solid);
      expect(m.solutionVolume, 0.5);
    });
  });

  group('Simultaneous / boundary / performance', () {
    test('water + drain + evaporation same dt stay finite', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setSolventFlowRate(0.25);
      m.setDrainFlowRate(0.25);
      m.setEvaporationRate(0.25);
      m.step(0.1);
      expect(m.solutionVolume.isFinite, isTrue);
      expect(m.soluteMoles.isFinite, isTrue);
      expect(m.concentration.isFinite, isTrue);
      expect(m.solutionVolume, greaterThanOrEqualTo(0));
      expect(m.soluteMoles, greaterThanOrEqualTo(0));
    });

    test('boundary sweep volume and solute extremes', () {
      for (final v in [0.0, 1e-9, 0.5, 0.999, 1.0]) {
        final m = fresh();
        m.setVolumeDirect(v);
        m.step(0);
        expect(m.solventFaucet.enabled, v < 1.0);
        expect(m.drainFaucet.enabled, v > 0);
        expect(m.evaporator.enabled, v > 0);
      }
      for (final n in [0.0, 0.001, 0.5, 6.9, 7.0]) {
        final m = fresh();
        m.addSoluteAmount(n);
        expect(m.soluteMoles, lessThanOrEqualTo(7.0));
        expect(m.concentration, lessThanOrEqualTo(m.saturatedConcentration));
      }
    });

    test('high-state: precipitate + shaker + fluids stay consistent', () {
      final m = fresh(13);
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(7.0);
      expect(m.precipitateParticles.count, greaterThan(100));
      m.setSolventFlowRate(0.1);
      m.setDrainFlowRate(0.05);
      shake(m, moves: 10);
      m.setSolventFlowRate(0);
      m.setDrainFlowRate(0);
      m.setProbePosition(beakerBottom(m));
      expect(m.meter.value, isNotNull);
      expect(m.concentration, lessThanOrEqualTo(m.saturatedConcentration));
      expect(m.solutionVolume.isFinite, isTrue);
      m.reset();
      expect(m.precipitateParticles.count, 0);
      expect(m.shakerParticles.count, 0);
    });
  });

  group('State consistency / lifecycle widget', () {
    test('model color and precipitate sync with moles', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.drinkMix);
      final c0 = m.solution.color;
      m.addSoluteAmount(0.4);
      expect(m.solution.color, isNot(equals(c0)));
      m.addSoluteAmount(3.0);
      if (m.isSaturated) {
        expect(m.precipitateParticles.count, m.solution.numberOfPrecipitateParticles);
      }
    });

    testWidgets('enter → interact → leave → enter', (tester) async {
      final audio = RecordingConcentrationAudio();
      final model = ConcentrationModel(random: math.Random(17));

      await tester.pumpWidget(
        MaterialApp(home: ConcentrationScreen(model: model, audio: audio)),
      );
      await tester.pump();
      model.addSoluteAmount(0.3);
      model.setProbePosition(beakerBottom(model));
      await audio.onDragStart();
      await audio.onDragEnd();
      expect(audio.grabCount, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(audio.isDragging, isFalse);

      final audio2 = RecordingConcentrationAudio();
      await tester.pumpWidget(
        MaterialApp(home: ConcentrationScreen(model: model, audio: audio2)),
      );
      await tester.pump();
      await audio2.onDragStart();
      await audio2.onDragEnd();
      expect(audio2.grabCount, 1);
      expect(audio2.releaseCount, 1);
    });
  });

  group('Visual final matrix', () {
    Future<void> capture(
      WidgetTester tester,
      ConcentrationModel model,
      String name,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1100, 700));
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: ConcentrationLayout.layoutBounds.width,
                  height: ConcentrationLayout.layoutBounds.height,
                  child: ConcentrationPlayArea(
                    model: model,
                    dispenserLabel: model.solute.displayName,
                    stockColor: stockSolutionColor(model.solute),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image =
          await tester.runAsync(() => boundary.toImage(pixelRatio: 1));
      final bytes = await tester
          .runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
      final outDir = Directory('test/concentration/FLUTTER');
      outDir.createSync(recursive: true);
      File('${outDir.path}/$name.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    }

    testWidgets('final screenshot matrix (no pixel polish)', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final defaults = ConcentrationModel(random: math.Random(1));
      await capture(tester, defaults, 'CT_default');

      final particles = ConcentrationModel(random: math.Random(3));
      for (var i = 0; i < 12; i++) {
        particles.setShakerPosition(Offset(340 + i * 4.0, 160));
        particles.step(0.05);
      }
      await capture(tester, particles, 'CT_shaker_particles');

      final dropDisp = ConcentrationModel(random: math.Random(5));
      dropDisp.setSoluteForm(SoluteForm.solution);
      dropDisp.setDropperDispensing(true);
      dropDisp.step(0.1);
      await capture(tester, dropDisp, 'CT_dropper_dispensing');

      final waterHigh = ConcentrationModel();
      waterHigh.addSoluteAmount(0.2);
      waterHigh.setVolumeDirect(0.95);
      waterHigh.setSolventFlowRate(0.25);
      await capture(tester, waterHigh, 'CT_water_high');

      final drain = ConcentrationModel();
      drain.addSoluteAmount(0.4);
      drain.setDrainFlowRate(0.25);
      await capture(tester, drain, 'CT_drain');

      final evap = ConcentrationModel();
      evap.addSoluteAmount(0.4);
      evap.setEvaporationRate(0.25);
      await capture(tester, evap, 'CT_evaporation');

      final sat = ConcentrationModel();
      sat.setSolute(SoluteDefinitions.copperSulfate);
      sat.addSoluteAmount(1.5);
      await capture(tester, sat, 'CT_saturated');

      final probeSol = ConcentrationModel();
      probeSol.addSoluteAmount(0.5);
      probeSol.setProbePosition(beakerBottom(probeSol));
      await capture(tester, probeSol, 'CT_probe_solution');

      final probeWater = ConcentrationModel();
      probeWater.setSolventFlowRate(0.25);
      probeWater.setProbePosition(waterJump(probeWater));
      await capture(tester, probeWater, 'CT_probe_water');

      final probeStock = ConcentrationModel();
      probeStock.setSoluteForm(SoluteForm.solution);
      probeStock.setDropperDispensing(true);
      probeStock.setProbePosition(dropperJump(probeStock));
      await capture(tester, probeStock, 'CT_probe_stock');

      final probeDrain = ConcentrationModel();
      probeDrain.addSoluteAmount(0.5);
      probeDrain.setDrainFlowRate(0.25);
      probeDrain.setProbePosition(drainJump(probeDrain));
      await capture(tester, probeDrain, 'CT_probe_drain');

      final dirty = ConcentrationModel(random: math.Random(2));
      dirty.setSolute(SoluteDefinitions.copperSulfate);
      dirty.addSoluteAmount(1.5);
      dirty.setSolventFlowRate(0.1);
      dirty.setProbePosition(beakerBottom(dirty));
      dirty.reset();
      expect(dirty.soluteMoles, 0);
      expect(dirty.solutionVolume, 0.5);
      await capture(tester, dirty, 'CT_reset');

      final required = {
        'CT_default.png',
        'CT_shaker_particles.png',
        'CT_dropper_dispensing.png',
        'CT_water_high.png',
        'CT_drain.png',
        'CT_evaporation.png',
        'CT_saturated.png',
        'CT_probe_solution.png',
        'CT_probe_water.png',
        'CT_probe_stock.png',
        'CT_probe_drain.png',
        'CT_reset.png',
      };
      final files = Directory('test/concentration/FLUTTER')
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .toSet();
      for (final name in required) {
        expect(files.contains(name), isTrue, reason: 'missing $name');
      }
    }, timeout: const Timeout(Duration(minutes: 3)));
  });
}
