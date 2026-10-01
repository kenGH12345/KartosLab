import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/model/concentration_constants.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/model/probe_fluid_geometry.dart';
import 'package:kratos/concentration/model/probe_region.dart';
import 'package:kratos/concentration/model/solute_definitions.dart';
import 'package:kratos/concentration/model/solute_form.dart';

void main() {
  const eps = 1e-12;

  ConcentrationModel fresh() => ConcentrationModel();

  Offset beakerBottom(ConcentrationModel m) =>
      Offset(m.beaker.position.dx, m.beaker.position.dy - 0.0001);

  Offset waterJump(ConcentrationModel m) =>
      m.solventFaucet.position + const Offset(0, 10);

  Offset dropperJump(ConcentrationModel m) =>
      m.dropper.position + const Offset(0, 10);

  Offset drainJump(ConcentrationModel m) =>
      m.drainFaucet.position + const Offset(0, 10);

  group('Initial / outside', () {
    test('initial probe outside → null (not 0)', () {
      final m = fresh();
      expect(m.solutionVolume, 0.5);
      expect(m.soluteMoles, 0);
      expect(m.concentration, 0);
      expect(m.meter.probePosition, ConcentrationConstants.probeInitialPosition);
      m.setProbePosition(m.meter.probePosition); // force detect
      expect(m.meter.region, ProbeRegion.none);
      expect(m.meter.value, isNull);
    });

    test('explicit outside position → null', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setProbePosition(const Offset(900, 200));
      expect(m.meter.region, ProbeRegion.none);
      expect(m.meter.value, isNull);
    });
  });

  group('Solution reading', () {
    test('probe in solution → exact concentration 1.234', () {
      final m = fresh();
      // V=0.5 → need 0.617 mol for 1.234 M
      m.addSoluteAmount(0.617);
      expect(m.concentration, closeTo(1.234, 1e-12));
      m.setProbePosition(beakerBottom(m));
      expect(m.meter.region, ProbeRegion.solution);
      expect(m.meter.value, closeTo(1.234, 1e-12));
    });

    test('saturated → capped concentration', () {
      final m = fresh();
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.addSoluteAmount(1.0); // sat 1.38
      m.setProbePosition(beakerBottom(m));
      expect(m.isSaturated, isTrue);
      expect(m.meter.value, closeTo(1.38, eps));
      expect(m.meter.value!, lessThanOrEqualTo(m.saturatedConcentration));
    });

    test('empty beaker under probe → null', () {
      final m = fresh();
      m.addSoluteAmount(0.25);
      m.setProbePosition(beakerBottom(m));
      expect(m.meter.value, isNotNull);
      m.setVolumeDirect(0);
      expect(m.meter.region, ProbeRegion.none);
      expect(m.meter.value, isNull);
    });
  });

  group('Water stream', () {
    test('probe in active water → 0', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setSolventFlowRate(0.25);
      m.setProbePosition(waterJump(m));
      expect(m.meter.region, ProbeRegion.waterStream);
      expect(m.meter.value, 0);
    });

    test('inactive water stream → no water reading', () {
      final m = fresh();
      m.setSolventFlowRate(0.25);
      m.setProbePosition(waterJump(m));
      expect(m.meter.value, 0);
      m.setSolventFlowRate(0);
      expect(m.meter.region, ProbeRegion.none);
      expect(m.meter.value, isNull);
    });
  });

  group('Stock stream', () {
    test('probe in dropper stock → stock concentration', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      final stock = m.solute.stockSolutionConcentration;
      m.setProbePosition(dropperJump(m));
      expect(m.meter.region, ProbeRegion.stockSolution);
      expect(m.meter.value, closeTo(stock, eps));
    });

    test('closed dropper → no stock reading', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      m.setProbePosition(dropperJump(m));
      expect(m.meter.value, isNotNull);
      m.setDropperDispensing(false);
      expect(m.meter.region, ProbeRegion.none);
      expect(m.meter.value, isNull);
    });
  });

  group('Drain stream', () {
    test('probe in drain → solution concentration', () {
      final m = fresh();
      m.addSoluteAmount(0.5); // c = 1.0
      m.setDrainFlowRate(0.25);
      m.setProbePosition(drainJump(m));
      expect(m.meter.region, ProbeRegion.drainStream);
      expect(m.meter.value, closeTo(1.0, eps));
    });

    test('closed drain → no drain reading', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setDrainFlowRate(0.25);
      m.setProbePosition(drainJump(m));
      expect(m.meter.value, closeTo(1.0, eps));
      m.setDrainFlowRate(0);
      expect(m.meter.region, ProbeRegion.none);
      expect(m.meter.value, isNull);
    });
  });

  group('Region transitions', () {
    test('outside → solution → outside', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setProbePosition(const Offset(900, 200));
      expect(m.meter.value, isNull);
      m.setProbePosition(beakerBottom(m));
      expect(m.meter.value, closeTo(1.0, eps));
      m.setProbePosition(const Offset(900, 200));
      expect(m.meter.value, isNull);
    });

    test('outside → water → solution', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setSolventFlowRate(0.25);
      m.setProbePosition(const Offset(900, 200));
      expect(m.meter.value, isNull);
      m.setProbePosition(waterJump(m));
      expect(m.meter.value, 0);
      m.setProbePosition(beakerBottom(m));
      expect(m.meter.value, closeTo(1.0, eps));
    });

    test('stock → water', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      m.setSolventFlowRate(0.25);
      m.setProbePosition(dropperJump(m));
      expect(m.meter.region, ProbeRegion.stockSolution);
      m.setProbePosition(waterJump(m));
      expect(m.meter.region, ProbeRegion.waterStream);
      expect(m.meter.value, 0);
    });

    test('drain → outside', () {
      final m = fresh();
      m.addSoluteAmount(0.25);
      m.setDrainFlowRate(0.25);
      m.setProbePosition(drainJump(m));
      expect(m.meter.value, closeTo(0.5, eps));
      m.setProbePosition(const Offset(50, 160));
      expect(m.meter.value, isNull);
    });
  });

  group('Dynamic reading', () {
    test('add water while probe in solution lowers reading', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setProbePosition(beakerBottom(m));
      expect(m.meter.value, closeTo(1.0, eps));
      m.setSolventFlowRate(0.25);
      m.step(0.4); // +0.1 L → c = 0.5/0.6
      expect(m.meter.region, ProbeRegion.solution);
      expect(m.meter.value, closeTo(0.5 / 0.6, eps));
    });

    test('evaporation while probe in solution raises reading', () {
      final m = fresh();
      m.addSoluteAmount(0.25);
      m.setProbePosition(beakerBottom(m));
      expect(m.meter.value, closeTo(0.5, eps));
      m.setEvaporationRate(0.25);
      m.step(0.4); // V→0.4 → c=0.625
      m.releaseEvaporation();
      expect(m.meter.value, closeTo(0.25 / 0.4, eps));
    });

    test('liquid falls below probe → null', () {
      final m = fresh();
      m.addSoluteAmount(0.1);
      // Place probe near top of current liquid (height 150 → top y=400)
      // At volume 0.1, height=30 → top=520. Probe at y=480 is above liquid.
      m.setProbePosition(const Offset(350, 480));
      // Initially volume 0.5 → liquid top 400; 480 is below surface → in solution
      expect(m.meter.region, ProbeRegion.solution);
      m.setDrainFlowRate(0.25);
      // Drain until liquid top rises above probe (volume small)
      for (var i = 0; i < 20 && m.solutionVolume > 0.05; i++) {
        m.step(0.1);
      }
      // volume ~0.05 → height 15 → top=535; probe at 480 is above liquid
      expect(m.meter.region, ProbeRegion.none);
      expect(m.meter.value, isNull);
    });

    test('solute switch updates stock reading', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      m.setProbePosition(dropperJump(m));
      expect(
        m.meter.value,
        closeTo(SoluteDefinitions.drinkMix.stockSolutionConcentration, eps),
      );
      m.setSolute(SoluteDefinitions.copperSulfate);
      m.setSoluteForm(SoluteForm.solution);
      m.setDropperDispensing(true);
      m.setProbePosition(dropperJump(m));
      expect(
        m.meter.value,
        closeTo(
          SoluteDefinitions.copperSulfate.stockSolutionConcentration,
          eps,
        ),
      );
    });
  });

  group('J jump', () {
    test('five-point cycle with dropper visible', () {
      final m = fresh();
      m.setSoluteForm(SoluteForm.solution);
      final expected = [
        beakerBottom(m),
        waterJump(m),
        dropperJump(m),
        drainJump(m),
        ConcentrationConstants.probeInitialPosition,
      ];
      for (var i = 0; i < 5; i++) {
        final p = m.jumpProbeToNext();
        expect(p.dx, closeTo(expected[i].dx, 1e-9));
        expect(p.dy, closeTo(expected[i].dy, 1e-9));
      }
      // wrap
      final again = m.jumpProbeToNext();
      expect(again.dx, closeTo(expected[0].dx, 1e-9));
      expect(again.dy, closeTo(expected[0].dy, 1e-9));
    });

    test('hidden dropper skips dropper point', () {
      final m = fresh();
      expect(m.soluteForm, SoluteForm.solid);
      final hits = <String>[];
      for (var i = 0; i < 4; i++) {
        final p = m.jumpProbeToNext();
        if ((p - beakerBottom(m)).distance < 1e-6) {
          hits.add('beaker');
        } else if ((p - waterJump(m)).distance < 1e-6) {
          hits.add('water');
        } else if ((p - dropperJump(m)).distance < 1e-6) {
          hits.add('dropper');
        } else if ((p - drainJump(m)).distance < 1e-6) {
          hits.add('drain');
        } else if ((p - ConcentrationConstants.probeInitialPosition).distance <
            1e-6) {
          hits.add('outside');
        }
      }
      expect(hits, isNot(contains('dropper')));
      expect(hits, containsAll(['beaker', 'water', 'drain', 'outside']));
    });

    test('J × 20 stays in bounds', () {
      final m = fresh();
      final bounds = ConcentrationConstants.probeDragBounds;
      for (var i = 0; i < 20; i++) {
        final p = m.jumpProbeToNext();
        expect(p.dx, inInclusiveRange(bounds.left, bounds.right));
        expect(p.dy, inInclusiveRange(bounds.top, bounds.bottom));
      }
    });

    test('reset restores probe and jump index', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.jumpProbeToNext();
      m.jumpProbeToNext();
      m.setProbePosition(beakerBottom(m));
      expect(m.meter.value, isNotNull);
      m.reset();
      expect(m.meter.probePosition, ConcentrationConstants.probeInitialPosition);
      expect(m.meter.value, isNull);
      expect(m.probeJump.index, 0);
      final first = m.jumpProbeToNext();
      expect(first.dx, closeTo(beakerBottom(m).dx, 1e-9));
    });
  });

  group('Units / drag stress', () {
    test('unit switch changes display value only', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      m.setProbePosition(beakerBottom(m));
      final mol = m.meter.value!;
      expect(mol, closeTo(1.0, eps));
      m.setMeterUnits(ConcentrationMeterUnits.percent);
      expect(m.meter.units, ConcentrationMeterUnits.percent);
      expect(m.meter.value, closeTo(m.solution.percentConcentration, eps));
      expect(m.concentration, closeTo(1.0, eps)); // physical unchanged
      m.setMeterUnits(ConcentrationMeterUnits.molesPerLiter);
      expect(m.meter.value, closeTo(1.0, eps));
    });

    test('500 drag updates stay finite and clamped', () {
      final m = fresh();
      m.addSoluteAmount(0.5);
      var pos = const Offset(400, 450);
      for (var i = 0; i < 500; i++) {
        pos = Offset(pos.dx + (i.isEven ? 3.0 : -2.5), pos.dy + (i % 3 - 1));
        m.setProbePosition(pos);
        expect(m.meter.probePosition.dx.isFinite, isTrue);
        expect(m.meter.probePosition.dy.isFinite, isTrue);
        final b = ConcentrationConstants.probeDragBounds;
        expect(m.meter.probePosition.dx, inInclusiveRange(b.left, b.right));
        expect(m.meter.probePosition.dy, inInclusiveRange(b.top, b.bottom));
        if (m.meter.value != null) {
          expect(m.meter.value!.isFinite, isTrue);
        }
      }
    });
  });

  group('Geometry helpers', () {
    test('empty stream rects never contain', () {
      final m = fresh();
      final water = ProbeFluidGeometry.waterStreamRect(
        faucet: m.solventFaucet,
        beaker: m.beaker,
      );
      expect(water, Rect.zero);
      expect(
        ProbeFluidGeometry.containsPoint(waterJump(m), water),
        isFalse,
      );
    });

    test('solution rect matches volume height', () {
      final m = fresh();
      final r = ProbeFluidGeometry.solutionRect(
        beaker: m.beaker,
        volume: 0.5,
      );
      expect(r.height, closeTo(150, eps));
      expect(ProbeFluidGeometry.containsPoint(beakerBottom(m), r), isTrue);
      expect(
        ProbeFluidGeometry.containsPoint(const Offset(350, 300), r),
        isFalse,
      );
    });
  });
}
