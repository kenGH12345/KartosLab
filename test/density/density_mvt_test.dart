import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/density/density_constants.dart';
import 'package:kratos/density/model/density_vec.dart';
import 'package:kratos/density/model/intro_state.dart';
import 'package:kratos/density/render/density_mvt.dart';
import 'package:kratos/density/render/density_render_data.dart';
import 'package:kratos/density/solver/density_relation.dart';
import 'package:kratos/density/view/painters/scale_painter.dart';

void main() {
  group('DensityMvt', () {
    test('screen → world → screen roundtrip', () {
      final mvt = DensityMvt.fit(const Size(1024, 768));
      const world = DensityVec(-0.2, 0.2);
      final screen = mvt.toScreen(world);
      final back = mvt.toWorld(screen);
      expect(back.x, closeTo(world.x, 1e-9));
      expect(back.y, closeTo(world.y, 1e-9));
    });

    test('does not hardcode canvas pixels; scale follows size', () {
      final small = DensityMvt.fit(const Size(840, 520));
      final large = DensityMvt.fit(const Size(1366, 1024));
      expect(large.scale, greaterThan(small.scale));
      final a = small.toScreen(const DensityVec(0.3, 0.1));
      expect(a.dx, inExclusiveRange(0, 840));
      expect(a.dy, inExclusiveRange(0, 520));
    });

    test('cube front rect size tracks volume not a visualScale', () {
      final mvt = DensityMvt.fit(const Size(1024, 768));
      final intro = IntroState.initial();
      final r = mvt.cubeFrontRect(intro.blockA.position, intro.blockA.volume);
      final expectedSide = mvt.toScreenDelta(
        DensityRelation.cubeSideLength(intro.blockA.volume),
      );
      expect(r.width, closeTo(expectedSide, 1e-6));
      expect(r.height, closeTo(expectedSide, 1e-6));
    });

    test('starting fluid surface is below ground', () {
      final y = fluidSurfaceYFromVolume(DensityConstants.desiredStartingPoolVolume);
      expect(y, lessThan(0));
      expect(y, greaterThan(DensityMvt.poolMinY));
    });
  });

  testWidgets('scene painter paints without mutating intro state', (tester) async {
    final intro = IntroState.initial();
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 1024,
          height: 768,
          child: CustomPaint(
            size: const Size(1024, 768),
            painter: DensityScenePainter(
              DensityRenderData(
                mvt: DensityMvt.fit(const Size(1024, 768)),
                fluidSurfaceY: fluidSurfaceYFromVolume(
                  DensityConstants.desiredStartingPoolVolume,
                ),
                cubes: [
                  DensityCubeView(
                    id: intro.blockA.id,
                    tag: intro.blockA.tag,
                    center: intro.blockA.position,
                    volume: intro.blockA.volume,
                    color: const Color(0xFF8B5A2B),
                    massKg: DensityRelation.massOf(intro.blockA),
                    showMassLabel: true,
                    materialId: intro.blockA.materialId,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(intro.blockA.volume, 0.005);
    expect(intro.blockA.position, const DensityVec(-0.2, 0.2));
  });
}
