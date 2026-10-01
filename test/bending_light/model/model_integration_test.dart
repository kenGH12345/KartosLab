import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/model/enums.dart';
import 'package:kratos/bending_light/model/intro_model.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';
import 'package:kratos/bending_light/model/prism.dart';
import 'package:kratos/bending_light/model/prisms_model.dart';
import 'package:kratos/bending_light/model/substance.dart';

void main() {
  group('IntroModel integration', () {
    test('defaults: laser off, top air, bottom water', () {
      final m = IntroModel(
        bottomSubstance: Substance.water,
        horizontalPlayAreaOffset: true,
      );
      expect(m.laser.on, isFalse);
      expect(m.topMedium.substance.name, 'Air');
      expect(m.bottomMedium.substance.name, 'Water');
      expect(m.rays, isEmpty);
    });

    test('laser on creates incident+transmitted', () {
      final m = IntroModel(
        bottomSubstance: Substance.water,
        horizontalPlayAreaOffset: true,
      )..setLaserOn(true);
      final types = m.rays.map((r) => r.rayType).toSet();
      expect(types.contains('incident'), isTrue);
      expect(types.contains('transmitted'), isTrue);
      expect(m.rays.length, greaterThanOrEqualTo(2));
    });

    test('changing angle updates refracted tip', () {
      final m = IntroModel(
        bottomSubstance: Substance.water,
        horizontalPlayAreaOffset: true,
      )..setLaserOn(true);
      final tipBefore =
          m.rays.firstWhere((r) => r.rayType == 'transmitted').tip;
      m.laser.setAngle(math.pi / 2 + 0.3);
      m.updateModel();
      final tipAfter =
          m.rays.firstWhere((r) => r.rayType == 'transmitted').tip;
      expect(tipAfter.x, isNot(closeTo(tipBefore.x, 1e-15)));
    });

    test('air→glass changes transmitted angle vs water', () {
      final water = IntroModel(
        bottomSubstance: Substance.water,
        horizontalPlayAreaOffset: true,
      )..setLaserOn(true);
      final glass = IntroModel(
        bottomSubstance: Substance.glass,
        horizontalPlayAreaOffset: true,
      )..setLaserOn(true);
      final tw = water.rays.firstWhere((r) => r.rayType == 'transmitted');
      final tg = glass.rays.firstWhere((r) => r.rayType == 'transmitted');
      expect(tw.getAngle(), isNot(closeTo(tg.getAngle(), 1e-6)));
    });

    test('TIR water→air at steep angle', () {
      final m = IntroModel(
        bottomSubstance: Substance.air,
        horizontalPlayAreaOffset: true,
      );
      m.setTopSubstance(Substance.water);
      m.laser.setAngle(math.pi / 2 + 1.2);
      m.setLaserOn(true);
      final hasT = m.rays.any((r) => r.rayType == 'transmitted');
      final hasR = m.rays.any((r) => r.rayType == 'reflected');
      expect(hasT, isFalse);
      expect(hasR, isTrue);
      final reflected = m.rays.firstWhere((r) => r.rayType == 'reflected');
      expect(reflected.powerFraction, closeTo(1.0, 1e-9));
    });

    test('reset restores defaults', () {
      final m = IntroModel(
        bottomSubstance: Substance.water,
        horizontalPlayAreaOffset: true,
      )
        ..setLaserOn(true)
        ..setBottomSubstance(Substance.glass)
        ..setLaserView(LaserViewEnum.wave)
        ..showAngles = true;
      m.reset();
      expect(m.laser.on, isFalse);
      expect(m.bottomMedium.substance.name, 'Water');
      expect(m.laserView, LaserViewEnum.ray);
      expect(m.showAngles, isFalse);
      expect(m.wavelength, 650e-9);
    });
  });

  group('MoreToolsModel', () {
    test('default bottom glass + sensors', () {
      final m = MoreToolsModel();
      expect(m.bottomMedium.substance.name, 'Glass');
      expect(m.velocitySensor.enabled, isFalse);
      expect(m.waveSensor.enabled, isFalse);
    });

    test('reset clears sensors', () {
      final m = MoreToolsModel()
        ..velocitySensor.enabled = true
        ..waveSensor.enabled = true
        ..setLaserOn(true);
      m.reset();
      expect(m.velocitySensor.enabled, isFalse);
      expect(m.waveSensor.enabled, isFalse);
      expect(m.laser.on, isFalse);
    });
  });

  group('PrismsModel reset', () {
    test('clears prisms and flags', () {
      final m = PrismsModel()
        ..setShowReflections(true)
        ..setManyRays(5)
        ..setLaserOn(true);
      final proto = m.getPrismPrototypes().first;
      m.addPrism(Prism(proto.$1, proto.$2));
      expect(m.prisms, isNotEmpty);
      m.reset();
      expect(m.prisms, isEmpty);
      expect(m.showReflections, isFalse);
      expect(m.manyRays, 1);
      expect(m.laser.on, isFalse);
    });
  });
}
