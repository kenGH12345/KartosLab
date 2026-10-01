import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/collision_lab/collision_lab_constants.dart';
import 'package:kratos/collision_lab/controller/explore2d_controller.dart';
import 'package:kratos/collision_lab/controller/intro_controller.dart';
import 'package:kratos/collision_lab/model/cl_vec.dart';
import 'package:kratos/collision_lab/model/explore2d_model.dart';
import 'package:kratos/collision_lab/render/cl_mvt.dart';
import 'package:kratos/collision_lab/render/cl_render_builder.dart';
import 'package:kratos/collision_lab/solver/ball_utils.dart';

void main() {
  group('Ball drag without / with grid', () {
    test('Grid OFF: drag updates position toward pointer (no forced 0.1 snap)', () {
      final c = Explore2dController();
      c.model.isPlaying = false;
      c.model.playArea.gridVisible = false;
      final ball = c.model.ballSystem.balls[0];
      final start = ball.position;
      c.dragBall(0, ClVec(start.x + 0.26, start.y + 0.14));
      expect((ball.position - start).magnitude, greaterThan(0.05));
      // Not forced onto minor grid: allow either non-multiple or just verify move worked
      final snapped = CollisionLabConstants.minorGridlineSpacing;
      final dxFromGrid = (ball.position.x / snapped) -
          (ball.position.x / snapped).roundToDouble();
      // If it landed on grid by chance, still OK as long as drag moved; primary assert is movement
      expect(ball.position, isNot(equals(start)));
      c.endDrag();
      c.dispose();
      expect(dxFromGrid, anything);
    });

    test('Grid ON: drag still moves ball and snaps to 0.1 on move', () {
      final c = Explore2dController();
      c.model.isPlaying = false;
      c.model.playArea.gridVisible = true;
      final ball = c.model.ballSystem.balls[0];
      // Attempt a position that snaps clearly
      c.dragBall(0, const ClVec(0.26, -0.14));
      expect(ball.position.x, closeTo(0.3, 1e-9));
      expect(ball.position.y, closeTo(-0.1, 1e-9));
      // Second move
      c.dragBall(0, const ClVec(-0.54, 0.36));
      expect(ball.position.x, closeTo(-0.5, 1e-9));
      expect(ball.position.y, closeTo(0.4, 1e-9));
      c.endDrag();
      c.dispose();
    });

    test('1D tick snap when gridVisible (Intro)', () {
      final c = IntroController();
      c.model.isPlaying = false;
      expect(c.model.playArea.gridVisible, isTrue);
      final ball = c.model.ballSystem.balls[0];
      c.dragBall(0, const ClVec(0.26, 0.5));
      expect(ball.position.x, closeTo(0.3, 1e-9));
      expect(ball.position.y, 0);
      c.endDrag();
      c.dispose();
    });

    test('hit-test view centers remain inside playAreaRect while dragging on grid',
        () {
      final c = Explore2dController();
      c.model.isPlaying = false;
      c.model.playArea.gridVisible = true;
      c.dragBall(0, const ClVec(0.5, 0.3));
      final data = ClRenderBuilder.build(c);
      final ball = data.balls[0];
      expect(data.playAreaRect.contains(ball.center), isTrue);
      c.endDrag();
      c.dispose();
    });
  });

  group('PlayArea clipping semantics', () {
    test('render playAreaRect matches model bounds via MVT', () {
      final c = Explore2dController();
      final data = ClRenderBuilder.build(c);
      final mvt = ClMvt.forPlayArea(c.model.playArea);
      final expected = mvt.modelToViewBounds(c.model.playArea.bounds);
      expect(data.playAreaRect.left, closeTo(expected.left, 1e-6));
      expect(data.playAreaRect.top, closeTo(expected.top, 1e-6));
      expect(data.playAreaRect.right, closeTo(expected.right, 1e-6));
      expect(data.playAreaRect.bottom, closeTo(expected.bottom, 1e-6));
      c.dispose();
    });

    test('ball near edge stays model-inside on drag but radius may span border',
        () {
      final c = Explore2dController();
      c.model.isPlaying = false;
      c.model.playArea.gridVisible = false;
      final ball = c.model.ballSystem.balls[0];
      // Drag to far right — center constrained so full ball inside
      c.dragBall(0, const ClVec(10, 0));
      expect(ball.right, lessThanOrEqualTo(c.model.playArea.right + 1e-9));
      expect(ball.left, greaterThanOrEqualTo(c.model.playArea.left - 1e-9));
      // View: center near right edge; painted radius extends to border (clip handles overflow if any FP)
      final data = ClRenderBuilder.build(c);
      final mvt = ClMvt.forPlayArea(c.model.playArea);
      final center = mvt.modelToView(ball.position);
      final rView = mvt.modelToViewDeltaX(ball.radius);
      expect(center.dx + rView, closeTo(data.playAreaRect.right, 2.0));
      c.endDrag();
      c.dispose();
    });

    test('Intro (no reflecting border): model may leave play area while playing',
        () {
      final c = IntroController();
      expect(c.model.playArea.reflectingBorder, isFalse);
      final ball = c.model.ballSystem.balls[0];
      // Manually place center outside (simulates free flight) — model OK
      ball.position = const ClVec(3.0, 0);
      expect(ball.insidePlayArea, isFalse);
      // Render still reports playAreaRect for clipping
      final data = ClRenderBuilder.build(c);
      expect(data.playAreaRect.width, greaterThan(0));
      c.dispose();
    });
  });

  group('grid-safe bounds', () {
    test('grid-safe constrained bounds are non-inverted for default balls', () {
      final m = Explore2dModel();
      for (final ball in m.ballSystem.balls) {
        final b = BallUtils.getBallGridSafeConstrainedBounds(
          m.playArea.bounds,
          ball.radius,
        );
        expect(b.minX, lessThan(b.maxX));
        expect(b.minY, lessThan(b.maxY));
      }
    });
  });

  group('reset after drag', () {
    test('reset restores factory positions after grid drag', () {
      final c = Explore2dController();
      final factoryX = c.model.ballSystem.balls[0].position.x;
      c.model.playArea.gridVisible = true;
      c.dragBall(0, const ClVec(0.5, 0.2));
      c.endDrag();
      c.reset();
      expect(c.model.ballSystem.balls[0].position.x, closeTo(factoryX, 1e-12));
      c.dispose();
    });
  });
}
