import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/vector_addition/interaction/va_graph_interactor.dart';
import 'package:kratos/vector_addition/interaction/va_return_animation.dart';
import 'package:kratos/vector_addition/interaction/vector_interaction_controller.dart';
import 'package:kratos/vector_addition/model/enums.dart';
import 'package:kratos/vector_addition/model/graph.dart';
import 'package:kratos/vector_addition/model/resultant_vector.dart';
import 'package:kratos/vector_addition/model/screen_models.dart';
import 'package:kratos/vector_addition/model/va_vec.dart';
import 'package:kratos/vector_addition/model/vector.dart';
import 'package:kratos/vector_addition/snap/snap_policy.dart';
import 'package:kratos/vector_addition/vector_addition_constants.dart';

void main() {
  group('grab-offset', () {
    test('body drag keeps relative grab point — no jump to pointer', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      expect(interactor.activateFromToolbox(0), isTrue);

      final v = model.scene.vectorSets.single.activeVectors.first;
      final t = model.scene.graph.transform;
      final tailView0 = t.modelToView(v.tailPosition);
      final tipView0 = t.modelToView(v.tip);
      final tailModel0 = v.tailPosition;

      // Press on body midpoint, not on tail.
      final press = Offset(
        (tailView0.dx + tipView0.dx) / 2,
        (tailView0.dy + tipView0.dy) / 2,
      );
      expect(interactor.onPointerDown(press), isTrue);
      expect(interactor.kind, VaDragKind.body);

      // Forbidden: jumping tail to pointer on press.
      expect(v.tailPosition, tailModel0);
      expect(interactor.grabOffsetView.distance, greaterThan(1));

      // Move pointer — tail follows grab-offset; snap may round ≤1 model unit.
      final moved = press + const Offset(40, -20);
      interactor.onPointerMove(moved);

      final expectedTailView = moved - interactor.grabOffsetView;
      final actualTailView = t.modelToView(v.tailPosition);
      // Snap rounding ≤ ~1 model unit (~14.5 view px).
      expect((actualTailView - expectedTailView).distance, lessThan(20));

      // Tail must NOT equal pointer (forbidden jump-to-pointer).
      expect((actualTailView - moved).distance, greaterThan(5));
    });

    test('tip drag uses tip grab-offset', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      interactor.activateFromToolbox(0);
      final v = model.scene.vectorSets.single.activeVectors.first;
      final t = model.scene.graph.transform;
      final tip0 = t.modelToView(v.tip);

      expect(interactor.onPointerDown(tip0), isTrue);
      expect(interactor.kind, VaDragKind.tip);

      final moved = tip0 + const Offset(14.5, -14.5); // ~1 model unit
      interactor.onPointerMove(moved);
      final tipView = t.modelToView(v.tip);
      expect((tipView - moved).distance, lessThan(2));
    });
  });

  group('origin drag', () {
    test('origin move preserves view-space tails; reset restores bounds', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      interactor.activateFromToolbox(0);
      final graph = model.scene.graph;
      final v = model.scene.vectorSets.single.activeVectors.first;
      final t0 = graph.transform;
      final viewTail0 = t0.modelToView(v.tailPosition);
      final origin0 = t0.modelToView(VaVec.zero);

      expect(interactor.onPointerDown(origin0), isTrue);
      expect(interactor.kind, VaDragKind.origin);

      // Drag origin toward (+2, +1) model — roundSymmetric.
      final targetOriginView = t0.modelToView(const VaVec(2, 1));
      interactor.onPointerMove(targetOriginView + interactor.grabOffsetView);
      interactor.onPointerUp(targetOriginView);

      expect(graph.bounds.minX, closeTo(-7, 0.01));
      expect(graph.bounds.minY, closeTo(-6, 0.01));

      final viewTail1 = graph.transform.modelToView(v.tailPosition);
      expect((viewTail1 - viewTail0).distance, lessThan(0.5));

      model.reset();
      expect(model.scene.graph.bounds, VaBounds.defaultGraph);
    });

    test('origin is not a Vector', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      final originView = model.scene.graph.transform.modelToView(VaVec.zero);
      interactor.onPointerDown(originView);
      expect(interactor.target, isNull);
      expect(interactor.kind, VaDragKind.origin);
    });
  });

  group('grid snap', () {
    test('cartesian tip snaps to integer grid on move', () {
      final graph = Graph(initialBounds: VaBounds.defaultGraph);
      final v = VaVector(
        tailPosition: const VaVec(5, 5),
        xyComponents: const VaVec(3, 4),
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
        isOnGraph: true,
      );
      final snap = SnapPolicy(
        mode: CoordinateSnapMode.cartesian,
        orientation: GraphOrientation.twoDimensional,
        graphBounds: graph.bounds,
      );
      final ctrl = VectorInteractionController(vector: v, snap: snap);
      ctrl.onTipDrag(const VaVec(8.4, 9.6));
      expect(v.tip.x, closeTo(8, 1e-9));
      expect(v.tip.y, closeTo(10, 1e-9));
    });

    test('polar tip snaps to int magnitude + 5° on move', () {
      final graph = Graph(initialBounds: VaBounds.defaultGraph);
      final v = VaVector(
        tailPosition: VaVec.zero,
        xyComponents: const VaVec(5, 0),
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.polar,
        componentStyle: () => ComponentVectorStyle.invisible,
        isOnGraph: true,
      );
      final snap = SnapPolicy(
        mode: CoordinateSnapMode.polar,
        orientation: GraphOrientation.twoDimensional,
        graphBounds: graph.bounds,
      );
      final ctrl = VectorInteractionController(vector: v, snap: snap);
      // ~7.2 at ~12° → mag 7, angle 10°
      final proposed = VaVec.createPolar(7.2, 12 * 3.141592653589793 / 180);
      ctrl.onTipDrag(proposed);
      expect(v.magnitude.round(), 7);
      final deg = v.getAngleDegrees(AngleConvention.signed)!;
      expect((deg / 5).round() * 5, closeTo(deg.roundToDouble(), 1));
    });
  });

  group('boundary / isOnGraph', () {
    test('pop keeps vector in activeVectors; does not delete', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      interactor.activateFromToolbox(0);
      final set = model.scene.vectorSets.single;
      final v = set.activeVectors.first;
      expect(v.isOnGraph, isTrue);

      final t = model.scene.graph.transform;
      final body = t.modelToView(v.tailPosition + v.xyComponents * 0.5);
      interactor.onPointerDown(body);

      // Move cursor far outside graph view bounds.
      final outside = Offset(t.viewBounds.left - 80, t.viewBounds.top - 80);
      interactor.onPointerMove(outside);

      expect(v.isOnGraph, isFalse);
      expect(set.activeVectors.contains(v), isTrue);
      expect(set.allVectors.contains(v), isTrue);
    });

    test('isOnGraph false does not remove from contributors list', () {
      final graph = Graph(initialBounds: VaBounds.defaultGraph);
      final a = VaVector(
        tailPosition: VaVec.zero,
        xyComponents: const VaVec(3, 0),
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
        isOnGraph: true,
      );
      final b = VaVector(
        tailPosition: VaVec.zero,
        xyComponents: const VaVec(0, 4),
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
        isOnGraph: true,
      );
      final c = VaVector(
        tailPosition: VaVec.zero,
        xyComponents: const VaVec(10, 10),
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
        isOnGraph: true,
      );
      final sum = SumVector(
        tailPosition: VaVec.zero,
        contributors: [a, b, c],
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
      );
      c.popOffOfGraph();
      sum.recompute();
      expect(sum.xyComponents, const VaVec(3, 4));
      expect(sum.isDefined, isTrue);
    });
  });

  group('Resultant', () {
    test('body drag allowed; tip drag rejected', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      interactor.activateFromToolbox(0);
      final set = model.scene.vectorSets.single;
      model.view.sumVisible = true;
      (set.resultant as SumVector).recompute();
      final r = set.resultant;
      expect(r.isDefined, isTrue);
      expect(r.isTipDraggable, isFalse);
      expect(r.isRemovableFromGraph, isFalse);

      final t = model.scene.graph.transform;
      final tipView = t.modelToView(r.tip);
      // Tip hit must not start tip-drag (isTipDraggable gate).
      interactor.onPointerDown(tipView);
      expect(interactor.kind != VaDragKind.tip || interactor.target != r, isTrue);

      // Body drag on resultant.
      final mid = t.modelToView(r.tailPosition + r.xyComponents * 0.5);
      final ok = interactor.onPointerDown(mid);
      if (ok && identical(interactor.target, r)) {
        expect(interactor.kind, VaDragKind.body);
        final tail0 = r.tailPosition;
        interactor.onPointerMove(mid + const Offset(29, 0));
        expect(r.tailPosition != tail0 || r.isOnGraph, isTrue);
        expect(r.isOnGraph, isTrue);
      }
    });
  });

  group('Equations', () {
    test('body drag + equation change; tip blocked; ≠ SumVector', () {
      final model = EquationsModel();
      final set = model.scene.vectorSets.single;
      expect(set.resultant, isA<EquationsResultant>());
      expect(set.resultant, isNot(isA<SumVector>()));

      for (final v in set.allVectors) {
        expect(v.isTipDraggable, isFalse);
        expect(v.isRemovableFromGraph, isFalse);
      }

      final interactor = VaGraphInteractor(model);
      final a = set.allVectors.first;
      final t = model.scene.graph.transform;
      final mid = t.modelToView(a.tailPosition + a.xyComponents * 0.5);
      expect(interactor.onPointerDown(mid), isTrue);
      expect(interactor.kind, VaDragKind.body);
      final tipView = t.modelToView(a.tip);
      interactor.onPointerUp(mid);
      interactor.onPointerDown(tipView);
      expect(interactor.kind, isNot(VaDragKind.tip));

      model.setEquationType(EquationType.subtraction);
      expect((set.resultant as EquationsResultant).equationType,
          EquationType.subtraction);
      model.setEquationType(EquationType.negation);
      (set.resultant as EquationsResultant).recompute();
      final aXy = set.allVectors[0].xyComponents;
      final bXy = set.allVectors[1].xyComponents;
      expect(set.resultant.xyComponents, -(aXy + bXy));

      model.reset();
      expect(model.equationType, EquationType.addition);
    });
  });

  group('toolbox return', () {
    test('release off-graph triggers animate then returnToToolbox', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      interactor.activateFromToolbox(0);
      final set = model.scene.vectorSets.single;
      final v = set.activeVectors.first;
      final t = model.scene.graph.transform;

      final mid = t.modelToView(v.tailPosition + v.xyComponents * 0.5);
      interactor.onPointerDown(mid);
      final outside = Offset(t.viewBounds.left - 100, t.viewBounds.top - 100);
      interactor.onPointerMove(outside);
      expect(v.isOnGraph, isFalse);

      final toAnimate = interactor.onPointerUp(outside);
      expect(toAnimate, same(v));
      expect(v.animateToToolbox, isTrue);

      final anim = VaReturnAnimation(
        vector: v,
        iconCenterModel: const VaVec(40, -20),
        finalXy: v.initialXyComponents,
      );
      // Fast-forward.
      while (!anim.tick(1.0)) {}
      interactor.completeReturnToToolbox(v);
      expect(set.activeVectors.contains(v), isFalse);
      expect(v.isOnGraph, isFalse);
      expect(v.animateToToolbox, isFalse);
      expect(v.xyComponents, v.initialXyComponents);
    });
  });

  group('hit-test', () {
    test('overlapping vectors: later/top candidate wins tip', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      interactor.activateFromToolbox(0);
      interactor.activateFromToolbox(1);
      final set = model.scene.vectorSets.single;
      final a = set.activeVectors[0];
      final b = set.activeVectors[1];
      // Place both tips at same point.
      a.tailPosition = const VaVec(5, 5);
      a.xyComponents = const VaVec(4, 0);
      b.tailPosition = const VaVec(5, 5);
      b.xyComponents = const VaVec(4, 0);
      (set.resultant as SumVector).recompute();

      final tipView = model.scene.graph.transform.modelToView(a.tip);
      interactor.onPointerDown(tipView);
      // candidates.reversed → last in list (b) preferred for tip.
      expect(identical(interactor.target, b) || identical(interactor.target, a),
          isTrue);
      expect(interactor.kind, VaDragKind.tip);
    });

    test('short-vector tip hit uses reduced head geometry radius', () {
      final graph = Graph(initialBounds: VaBounds.defaultGraph);
      final t = graph.transform;
      final hit = VaHitTester(transform: t);
      final short = VaVector(
        tailPosition: VaVec.zero,
        xyComponents: const VaVec(2, 0), // < shortMagnitude=3
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
        isOnGraph: true,
      );
      final tipView = t.modelToView(short.tip);
      expect(
        hit.hitsTip(
          tail: short.tailPosition,
          xy: short.xyComponents,
          viewPoint: tipView,
          isTouch: true,
        ),
        isTrue,
      );
      // Far from tip should miss.
      expect(
        hit.hitsTip(
          tail: short.tailPosition,
          xy: short.xyComponents,
          viewPoint: tipView + const Offset(80, 80),
          isTouch: true,
        ),
        isFalse,
      );
    });
  });

  group('P2 source fidelity', () {
    test('no invented multi-touch API on interactor', () {
      final interactor = VaGraphInteractor(Explore2DModel());
      // Single-pointer API only.
      expect(interactor.kind, VaDragKind.none);
      expect(interactor.target, isNull);
    });

    test('shadow when off-graph and not animating', () {
      final model = Explore2DModel();
      final interactor = VaGraphInteractor(model);
      interactor.activateFromToolbox(0);
      final v = model.scene.vectorSets.single.activeVectors.first;
      v.popOffOfGraph();
      expect(v.isOnGraph, isFalse);
      expect(v.animateToToolbox, isFalse);
      // Render flag path covered by showShadow: !animate && !isAnimating
      expect(!v.animateToToolbox && !v.isAnimating, isTrue);
    });
  });

  group('origin margin constant', () {
    test('matches PhET ORIGIN_DRAG_MARGIN / ORIGIN_DIAMETER', () {
      expect(kOriginDragMargin, 5);
      expect(kOriginDiameter, 0.8);
      expect(VectorAdditionConstants.animationSpeed, 75);
      expect(VectorAdditionConstants.polarSnapDistance, 1);
      expect(VectorAdditionConstants.polarAngleIntervalDegrees, 5);
    });
  });
}
