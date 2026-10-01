import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/curve_fitting/curve_fitting_constants.dart';
import 'package:kratos/curve_fitting/model/curve_fitting_model.dart';
import 'package:kratos/curve_fitting/model/data_point.dart';
import 'package:kratos/curve_fitting/model/fit_type.dart';
import 'package:kratos/curve_fitting/screens/curve_fitting_home.dart';
import 'package:kratos/curve_fitting/transform/math_coordinate_transform.dart';
import 'package:kratos/curve_fitting/widgets/bucket_widget.dart';
import 'package:kratos/curve_fitting/widgets/cf_drag_test_harness.dart';
import 'package:kratos/curve_fitting/widgets/data_point_widget.dart';

void main() {
  test('forGraphViewport origin offset keeps bucket in positive parent X', () {
    const colW = CurveFittingConstants.columnOuterWidth;
    const w = 1024.0;
    const h = 618.0;
    final graphW = w - 2 * colW;
    final t = MathCoordinateTransform.forGraphViewport(
      Size(graphW, h),
      viewOriginInParent: Offset(colW + graphW / 2, h / 2),
    );
    final bucketView = t.modelToView(
      const Offset(
        CurveFittingConstants.bucketPositionX,
        CurveFittingConstants.bucketPositionY,
      ),
    );
    expect(bucketView.dx, greaterThan(0));
    expect(bucketView.dx, lessThan(w));
    expect(bucketView.dy, greaterThan(0));
    expect(bucketView.dy, lessThan(h));
  });

  test('viewToModel round-trip at origin and graph corner', () {
    final t = MathCoordinateTransform.forGraphViewport(
      const Size(600, 500),
      viewOriginInParent: const Offset(400, 250),
    );
    final origin = t.viewToModel(const Offset(400, 250));
    expect(origin.dx, closeTo(0, 1e-9));
    expect(origin.dy, closeTo(0, 1e-9));

    final cornerView = t.modelToView(const Offset(10, -10));
    final back = t.viewToModel(cornerView);
    expect(back.dx, closeTo(10, 1e-9));
    expect(back.dy, closeTo(-10, 1e-9));
  });

  test('drag point → best fit + residual stats recompute', () {
    final model = CurveFittingModel();
    model.setCurveVisible(true);
    model.setFitType(FitType.best);
    model.setOrder(1);

    final p1 = DataPoint(x: 0, y: 0, delta: 1);
    final p2 = DataPoint(x: 1, y: 1, delta: 1);
    final p3 = DataPoint(x: 2, y: 2, delta: 1);
    model.addPoint(p1);
    model.addPoint(p2);
    model.addPoint(p3);

    expect(model.curve.coefficients[0], closeTo(0, 1e-6));
    expect(model.curve.coefficients[1], closeTo(1, 1e-6));
    expect(model.curve.rSquared, closeTo(1, 1e-6));
    expect(model.curve.chiSquared, closeTo(0, 1e-6));

    final coeffsBefore = List<double>.from(model.curve.coefficients);

    // Off-line move: model listener must refit (widget only writes position).
    p2.setPosition(1, 4);
    expect(model.curve.coefficients[0], isNot(closeTo(coeffsBefore[0], 1e-6)));
    expect(model.curve.chiSquared, greaterThan(0));
    expect(model.curve.rSquared, lessThan(1));
    // Fitted Y at x=1 differs from observed 4 → residual pipeline live.
    expect(model.curve.getYValueAt(1), isNot(closeTo(4, 1e-6)));
  });

  test('invalid drop outside graph triggers return path flags', () {
    final model = CurveFittingModel();
    final p = DataPoint(x: 1, y: 1, dragging: true);
    model.addPoint(p);
    p.setPosition(20, 0);
    expect(p.isInsideGraph, isFalse);
    p.setDragging(false);
    model.pointUpdated();
    // Widget owns animation; model marks relevant-filter via animationActive.
    p.animationActive = true;
    expect(model.points.getRelevantPoints(), isEmpty);
  });

  test('reset clears points after drag', () {
    final model = CurveFittingModel();
    model.addPoint(DataPoint(x: 1, y: 2));
    model.addPoint(DataPoint(x: 3, y: 4));
    model.reset();
    expect(model.points.length, 0);
    expect(model.curveVisible, isFalse);
  });

  test('hit radius = visual radius + PhET dilation(5)', () {
    expect(CurveFittingConstants.pointRadius, 8);
    expect(CurveFittingConstants.pointHitDilation, 5);
  });

  testWidgets('bucket decorative balls and graph points are present after drag',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 1024,
          height: 700,
          child: CurveFittingHome(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BucketWidget), findsOneWidget);

    final state = tester.state<CurveFittingHomeState>(
      find.byType(CurveFittingHome),
    );

    // Programmatic "drop" onto graph (widget drag covered by hit-test layer).
    state.model.addPoint(DataPoint(x: 1, y: 2));
    await tester.pump();
    expect(find.byType(DataPointWidget), findsOneWidget);

    // Drag via model path still updates fit when Curve on.
    state.model.setCurveVisible(true);
    state.model.setFitType(FitType.best);
    state.model.addPoint(DataPoint(x: 3, y: 6));
    await tester.pump();
    expect(state.model.curve.isCurvePresent, isTrue);
    expect(state.model.curve.coefficients.length, 2);
  });

  testWidgets('pointer down on bucket ball starts a drag (hit not stolen)',
      (tester) async {
    final model = CurveFittingModel();
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 800,
          height: 600,
          child: CfDragTestHarness(model: model),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(model.points.length, 0);
    final ball = find.byKey(const ValueKey('cf-bucket-ball-0'));
    expect(ball, findsOneWidget);

    final ballCenter = tester.getCenter(ball);
    final gesture = await tester.startGesture(ballCenter);
    await tester.pump();
    // Move into graph background [-10,10].
    await gesture.moveBy(const Offset(200, -150));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(model.points.length, greaterThan(0));
  });

  testWidgets('graph DataPointWidget pan updates model position', (tester) async {
    final model = CurveFittingModel();
    model.addPoint(DataPoint(x: 0, y: 0));
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 800,
          height: 600,
          child: CfDragTestHarness(model: model),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DataPointWidget), findsOneWidget);
    final pointFinder = find.byType(DataPointWidget);
    final start = tester.getCenter(pointFinder);
    final gesture = await tester.startGesture(start);
    await tester.pump();
    await gesture.moveBy(const Offset(40, -30));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    final p = model.points.points.first;
    expect(p.x != 0 || p.y != 0, isTrue);
  });
}
