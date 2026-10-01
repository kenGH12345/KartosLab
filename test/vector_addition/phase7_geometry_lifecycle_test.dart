import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/screens/home_screen.dart';
import 'package:kratos/vector_addition/interaction/va_graph_interactor.dart';
import 'package:kratos/vector_addition/model/enums.dart';
import 'package:kratos/vector_addition/model/root_vector.dart';
import 'package:kratos/vector_addition/model/screen_models.dart';
import 'package:kratos/vector_addition/model/va_vec.dart';
import 'package:kratos/vector_addition/painters/va_angle_arc_geometry.dart';
import 'package:kratos/vector_addition/painters/va_arrow_geometry.dart';
import 'package:kratos/vector_addition/render/va_render_builder.dart';
import 'package:kratos/vector_addition/screens/vector_addition_home.dart';
import 'package:kratos/vector_addition/vector_addition_constants.dart';
import 'package:kratos/vector_addition/vector_addition_strings.dart';
import 'package:kratos/vector_addition/widgets/va_screen_body.dart';

void main() {
  group('arrow geometry', () {
    const geo = VaArrowGeometry();

    test('defaults match PhET head 12×14 tail 3.5 fractional 0.5', () {
      expect(geo.headWidth, 12);
      expect(geo.headHeight, 14);
      expect(geo.tailWidth, 3.5);
      expect(geo.fractionalHeadHeight, 0.5);
      expect(geo.isHeadDynamic, isTrue);
    });

    test('short vector scales head below fractional limit', () {
      final sized = geo.sizedHead(20);
      expect(sized.headHeight, lessThanOrEqualTo(10));
      expect(sized.headWidth, lessThan(12));
    });

    test('reverse vector uses π direction for leftward tip', () {
      final angle = math.atan2(0.0, -10.0);
      expect(angle.abs(), closeTo(math.pi, 1e-9));
      final sized = geo.sizedHead(100);
      expect(sized.headHeight, 14);
    });
  });

  group('angle arc / convention', () {
    test('flutter sweep is negation of model angle (Y-down)', () {
      expect(VaAngleArcGeometry.flutterSweep(math.pi / 2),
          closeTo(-math.pi / 2, 1e-12));
      expect(VaAngleArcGeometry.flutterSweep(-math.pi / 4),
          closeTo(math.pi / 4, 1e-12));
      expect(VaAngleArcGeometry.flutterSweep(0), 0);
      expect(VaAngleArcGeometry.flutterSweep(math.pi), closeTo(-math.pi, 1e-12));
    });

    test('radius clamps to maxCurvedArrowRadius', () {
      expect(VaAngleArcGeometry.radiusForViewMagnitude(1000), 25);
      expect(
        VaAngleArcGeometry.radiusForViewMagnitude(10),
        closeTo(0.79 * 10, 1e-9),
      );
    });

    test('signed vs unsigned degrees from RootVector', () {
      final v = RootVector(
        tailPosition: VaVec.zero,
        xyComponents: const VaVec(-1, 0),
      );
      expect(v.getAngleDegrees(AngleConvention.signed)!.abs(), closeTo(180, 1e-6));
      final neg = RootVector(
        tailPosition: VaVec.zero,
        xyComponents: const VaVec(0, -1),
      );
      expect(neg.getAngleDegrees(AngleConvention.signed), closeTo(-90, 1e-6));
      expect(neg.getAngleDegrees(AngleConvention.unsigned), closeTo(270, 1e-6));
    });

    test('atan2 is CCW from +x (RootVector comment clockwise is wrong)', () {
      expect(const VaVec(0, 1).angle, closeTo(math.pi / 2, 1e-12));
      expect(const VaVec(0, -1).angle, closeTo(-math.pi / 2, 1e-12));
    });
  });

  group('base vectors toggle', () {
    test('default hidden; toggle shows 2 base arrows', () {
      final model = EquationsModel();
      expect(model.view.baseVectorsVisible, isFalse);
      var data = const VaRenderBuilder().build(model);
      expect(data.baseVectors, isEmpty);

      model.view.baseVectorsVisible = true;
      data = const VaRenderBuilder().build(model);
      expect(data.baseVectors, hasLength(2));
      expect(data.baseVectors.every((b) => b.isBaseVector), isTrue);
      expect(data.baseVectors.every((b) => b.strokeWidth == 1.5), isTrue);
      expect(data.baseVectors.first.color, Colors.white);
    });

    test('reset clears baseVectorsVisible', () {
      final model = EquationsModel();
      model.view.baseVectorsVisible = true;
      model.reset();
      expect(model.view.baseVectorsVisible, isFalse);
    });
  });

  group('vector values display data', () {
    test('precision 1 decimal; follows angleConvention', () {
      final model = Explore2DModel();
      VaGraphInteractor(model).activateFromToolbox(0);
      model.view.angleConvention = AngleConvention.unsigned;
      final data = const VaRenderBuilder().build(model);
      final v = data.selectedValues!;
      expect(VectorAdditionConstants.vectorValueDecimalPlaces, 1);
      final m = model.scene.selected!;
      expect(v.xComponent, m.xComponent);
      expect(v.yComponent, m.yComponent);
      expect(v.angleDegrees, m.getAngleDegrees(AngleConvention.unsigned));
    });
  });

  group('reset / eraser / scene independence', () {
    test('reset restores origin bounds + controls', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      interactor.activateFromToolbox(0);
      model.view.sumVisible = true;
      model.view.anglesVisible = true;
      model.view.angleConvention = AngleConvention.unsigned;
      model.componentStyle.style = ComponentVectorStyle.projection;
      final t = model.scene.graph.transform;
      final origin = t.modelToView(VaVec.zero);
      interactor.onPointerDown(origin);
      expect(interactor.kind, VaDragKind.origin);
      interactor.onPointerMove(t.modelToView(const VaVec(2, 1)));
      interactor.onPointerUp(Offset.zero);

      model.reset();
      expect(model.scene.graph.bounds, VaBounds.defaultGraph);
      expect(model.view.sumVisible, isFalse);
      expect(model.view.anglesVisible, isFalse);
      expect(model.view.angleConvention, AngleConvention.signed);
      expect(model.componentStyle.style, ComponentVectorStyle.invisible);
      expect(model.scene.vectorSets.single.activeVectors, isEmpty);
    });

    test('eraser clears vectors only', () {
      final model = Explore2DModel();
      VaGraphInteractor(model).activateFromToolbox(0);
      model.view.valuesVisible = true;
      model.erase();
      expect(model.scene.vectorSets.single.numberOnGraph, 0);
      expect(model.view.valuesVisible, isTrue);
    });

    test('screens are independent models', () {
      final e1 = Explore1DModel();
      final e2 = Explore2DModel();
      VaGraphInteractor(e1).activateFromToolbox(0);
      expect(e2.scene.vectorSets.single.activeVectors, isEmpty);
      e1.view.sumVisible = true;
      expect(e2.view.sumVisible, isFalse);
    });

    test('scene switch does not leak activeVectors across scenes', () {
      final model = Explore2DModel();
      VaGraphInteractor(model).activateFromToolbox(0);
      expect(model.scene.vectorSets.single.activeVectors, isNotEmpty);
      model.selectScene(1);
      expect(model.scene.coordinateSnapMode, CoordinateSnapMode.polar);
      expect(model.scene.vectorSets.single.activeVectors, isEmpty);
    });
  });

  group('AC-1 Home lifecycle', () {
    testWidgets('reopen VectorAdditionHome creates fresh models', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: VectorAdditionHome()),
      );
      final state = tester.state<VectorAdditionHomeState>(
        find.byType(VectorAdditionHome),
      );
      VaGraphInteractor(state.explore2d).activateFromToolbox(0);
      expect(state.explore2d.scene.vectorSets.single.activeVectors, isNotEmpty);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pumpWidget(const MaterialApp(home: VectorAdditionHome()));
      final state2 = tester.state<VectorAdditionHomeState>(
        find.byType(VectorAdditionHome),
      );
      expect(identical(state, state2), isFalse);
      expect(state2.explore2d.scene.vectorSets.single.activeVectors, isEmpty);
      expect(state2.explore2d.view.sumVisible, isFalse);
      expect(state2.generation, 1);
    });

    testWidgets('HomeScreen lists Vector Addition card title', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text(VectorAdditionStrings.title), findsOneWidget);
    });

    testWidgets('VaScreenBody dispose cleans up without error', (tester) async {
      final model = Explore2DModel();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: VaScreenBody(model: model, embedded: true)),
        ),
      );
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
