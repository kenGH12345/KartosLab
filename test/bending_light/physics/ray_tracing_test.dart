import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/bending_light_constants.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/prism.dart';
import 'package:kratos/bending_light/model/prism_geometry.dart';
import 'package:kratos/bending_light/model/prisms_model.dart';
import 'package:kratos/bending_light/model/substance.dart';

void main() {
  group('Prism geometry', () {
    test('6 prototypes', () {
      final all = PrismPrototypes.createAll();
      expect(all.length, 6);
      expect(all.map((e) => e.$2).toList(), [
        'triangle',
        'trapezoid',
        'square',
        'circle',
        'semicircle',
        'diverging-lens',
      ]);
    });

    test('square contains center', () {
      final square =
          PrismPrototypes.createAll().firstWhere((e) => e.$2 == 'square').$1;
      expect(square.containsPoint(BlVec2.zero), isTrue);
      expect(square.containsPoint(const BlVec2(1, 1)), isFalse);
    });

    test('circle intersection from outside', () {
      final circle = CircleShape(BlVec2.zero, 1e-5);
      final hits = circle.getIntersections(
        const BlVec2(-2e-5, 0),
        const BlVec2(1, 0),
      );
      expect(hits, isNotEmpty);
      expect(hits.first.point.x, closeTo(-1e-5, 1e-9));
    });

    test('no intersection miss', () {
      final circle = CircleShape(BlVec2.zero, 1e-5);
      final hits = circle.getIntersections(
        const BlVec2(-2e-5, 5e-5),
        const BlVec2(1, 0),
      );
      expect(hits, isEmpty);
    });
  });

  group('Ray tracing PrismsModel', () {
    test('laser off means no rays', () {
      final m = PrismsModel();
      expect(m.laser.on, isFalse);
      expect(m.rays, isEmpty);
    });

    test('laser on no prism means single unbounded ray', () {
      final m = PrismsModel()..setLaserOn(true);
      expect(m.rays.length, 1);
      expect(
        m.rays.first.getLength(),
        closeTo(BendingLightConstants.prismUnboundedRayLength, 1e-12),
      );
      expect(m.rays.first.powerFraction, closeTo(1.0, 1e-12));
    });

    test('square prism transmission creates path segments', () {
      final m = PrismsModel();
      final proto = m.getPrismPrototypes().firstWhere((e) => e.$2 == 'square');
      final prism = Prism(proto.$1, proto.$2)..setPosition(BlVec2.zero);
      m.addPrism(prism);
      m.laser.emissionPoint = const BlVec2(-3e-5, 0);
      m.laser.pivot = BlVec2.zero;
      m.setLaserOn(true);
      expect(m.rays, isNotEmpty);
      for (final ray in m.rays) {
        expect(ray.tail.x.isFinite, isTrue);
        expect(ray.tip.x.isFinite, isTrue);
        expect(ray.getLength(), greaterThan(0));
      }
    });

    test('max recursion terminates', () {
      final m = PrismsModel()..setShowReflections(true);
      final proto = m.getPrismPrototypes().firstWhere((e) => e.$2 == 'square');
      m.addPrism(Prism(proto.$1, proto.$2)..setPosition(BlVec2.zero));
      m.laser.emissionPoint = const BlVec2(-3e-5, 0);
      m.laser.pivot = BlVec2.zero;
      m.setLaserOn(true);
      expect(m.rays.length, lessThan(500));
    });

    test('prism rotation keeps finite tips', () {
      final m = PrismsModel();
      final proto = m.getPrismPrototypes().firstWhere((e) => e.$2 == 'triangle');
      final prism = Prism(proto.$1, proto.$2);
      m.addPrism(prism);
      m.laser.emissionPoint = const BlVec2(-4e-5, 0);
      m.laser.pivot = BlVec2.zero;
      m.setLaserOn(true);
      final before = m.rays.map((r) => r.tip).toList();
      prism.rotate(math.pi / 6);
      m.updateModel();
      final after = m.rays.map((r) => r.tip).toList();
      for (final p in [...before, ...after]) {
        expect(p.x.isFinite && p.y.isFinite, isTrue);
      }
    });

    test('diamond prism with reflections finite powers', () {
      final m = PrismsModel()
        ..setPrismSubstance(Substance.diamond)
        ..setShowReflections(true);
      final proto = m.getPrismPrototypes().firstWhere((e) => e.$2 == 'triangle');
      m.addPrism(Prism(proto.$1, proto.$2));
      m.laser.emissionPoint = const BlVec2(-3e-5, 0);
      m.laser.pivot = BlVec2.zero;
      m.setLaserOn(true);
      expect(m.rays.every((r) => r.powerFraction.isFinite), isTrue);
    });
  });
}
