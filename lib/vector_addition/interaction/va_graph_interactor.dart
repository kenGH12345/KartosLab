import 'package:flutter/material.dart';

import '../interaction/vector_interaction_controller.dart';
import '../model/resultant_vector.dart';
import '../model/screen_models.dart';
import '../model/va_vec.dart';
import '../model/vector.dart';
import '../model/vector_set.dart';
import '../snap/snap_policy.dart';
import '../transform/math_coordinate_transform.dart';
import '../vector_addition_constants.dart';

enum VaDragKind { none, body, tip, origin }

/// Closest the user can drag the origin to the edge — PhET `ORIGIN_DRAG_MARGIN`.
const double kOriginDragMargin = 5;

/// Origin manipulator diameter in model units — PhET `ORIGIN_DIAMETER`.
const double kOriginDiameter = 0.8;

/// Pointer → model interaction.
///
/// Grab-offset mirrors PhET `SoundDragListener` + `positionProperty` (tail or tip):
/// `newPos = pointer − (pointer₀ − pos₀)` so the vector does not jump on press.
///
/// Snap runs on **drag move** via `moveTip/Tail…WithInvariants` (not only on release).
class VaGraphInteractor {
  VaGraphInteractor(this.model);

  final VaScreenModel model;

  VaVector? target;
  VaVectorSet? targetSet;
  VaDragKind kind = VaDragKind.none;

  /// View-space: pointer − (tail | tip | origin) at press.
  Offset grabOffsetView = Offset.zero;

  MathCoordinateTransform? _transform;

  MathCoordinateTransform get transform =>
      _transform ??= model.scene.graph.transform;

  void invalidateTransform() => _transform = null;

  SnapPolicy snapFor(VaVector v) => SnapPolicy(
        mode: v.coordinateSnapMode,
        orientation: model.scene.graph.orientation,
        graphBounds: model.scene.graph.bounds,
      );

  List<({VaVec tail, VaVec tip})> peers(VaVector self, VaVectorSet set) {
    final out = <({VaVec tail, VaVec tip})>[];
    for (final v in set.activeVectors) {
      if (identical(v, self)) continue;
      if (v.isOnGraph) {
        out.add((tail: v.tailPosition, tip: v.tip));
      }
    }
    final r = set.resultant;
    if (r.isDefined) {
      out.add((tail: r.tailPosition, tip: r.tip));
    }
    return out;
  }

  void recomputeResultant(VaVectorSet set) {
    final r = set.resultant;
    if (r is SumVector) {
      r.recompute();
    } else if (r is EquationsResultant) {
      r.recompute();
    }
  }

  /// Hit-test order: tip → body → origin.
  bool onPointerDown(Offset viewPoint) {
    invalidateTransform();
    final t = transform;
    final hit = VaHitTester(transform: t);

    final candidates = <({VaVector v, VaVectorSet set})>[];
    for (final set in model.scene.vectorSets) {
      if (set.resultant.isDefined) {
        candidates.add((v: set.resultant, set: set));
      }
      for (final v in set.activeVectors) {
        candidates.add((v: v, set: set));
      }
    }

    for (final c in candidates.reversed) {
      if (c.v.isTipDraggable &&
          hit.hitsTip(
            tail: c.v.tailPosition,
            xy: c.v.xyComponents,
            viewPoint: viewPoint,
            isTouch: true,
          )) {
        target = c.v;
        targetSet = c.set;
        kind = VaDragKind.tip;
        model.scene.selected = c.v;
        grabOffsetView = viewPoint - t.modelToView(c.v.tip);
        return true;
      }
    }

    for (final c in candidates.reversed) {
      if (hit.hitsBody(
        tail: c.v.tailPosition,
        xy: c.v.xyComponents,
        viewPoint: viewPoint,
        dilation: VectorAdditionConstants.vectorMouseAreaDilation,
      )) {
        target = c.v;
        targetSet = c.set;
        kind = VaDragKind.body;
        if (c.v.isOnGraph) {
          model.scene.selected = c.v;
        }
        grabOffsetView = viewPoint - t.modelToView(c.v.tailPosition);
        return true;
      }
    }

    final originView = t.modelToView(VaVec.zero);
    final originHitR = t.modelToViewDeltaX(kOriginDiameter);
    if ((viewPoint - originView).distance <= originHitR * 1.5) {
      target = null;
      targetSet = null;
      kind = VaDragKind.origin;
      grabOffsetView = viewPoint - originView;
      model.scene.selected = null;
      return true;
    }

    model.scene.selected = null;
    kind = VaDragKind.none;
    target = null;
    targetSet = null;
    return false;
  }

  void onPointerMove(Offset viewPoint) {
    if (kind == VaDragKind.none) return;

    if (kind == VaDragKind.origin) {
      _dragOrigin(viewPoint);
      return;
    }

    final v = target;
    final set = targetSet;
    if (v == null || set == null) return;
    final t = transform;

    final ctrl = VectorInteractionController(
      vector: v,
      snap: snapFor(v),
      peerEndpoints: peers(v, set),
    );

    if (kind == VaDragKind.tip) {
      final tipView = viewPoint - grabOffsetView;
      ctrl.onTipDrag(t.viewToModel(tipView));
      recomputeResultant(set);
      return;
    }

    if (kind == VaDragKind.body) {
      final tailView = viewPoint - grabOffsetView;
      final proposedTail = t.viewToModel(tailView);

      if (!v.isOnGraph) {
        v.tailPosition = proposedTail;
      } else {
        ctrl.onBodyDrag(proposedTail);
        // Pop when cursor leaves graph — vector stays in activeVectors.
        final cursorModel = t.viewToModel(viewPoint);
        if (v.isRemovableFromGraph &&
            v.isOnGraph &&
            !model.scene.graph.bounds.containsPoint(cursorModel)) {
          v.popOffOfGraph();
          model.scene.selected = null;
        }
      }
      recomputeResultant(set);
    }
  }

  void _dragOrigin(Offset viewPoint) {
    final graph = model.scene.graph;
    final oldT = graph.transform;
    final eroded = graph.bounds.eroded(kOriginDragMargin);
    final erodedView = oldT.modelToViewRect(eroded);

    var originView = viewPoint - grabOffsetView;
    originView = Offset(
      originView.dx.clamp(erodedView.left, erodedView.right),
      originView.dy.clamp(erodedView.top, erodedView.bottom),
    );

    final modelPoint = oldT.viewToModel(originView);
    if (!graph.bounds.containsPoint(modelPoint)) return;

    final preserved = <({VaVector v, Offset viewTail})>[];
    for (final set in model.scene.vectorSets) {
      for (final v in set.allVectors) {
        if (v.isOnGraph || set.activeVectors.contains(v)) {
          preserved.add((v: v, viewTail: oldT.modelToView(v.tailPosition)));
        }
      }
      if (set.resultant.isDefined) {
        preserved.add((
          v: set.resultant,
          viewTail: oldT.modelToView(set.resultant.tailPosition),
        ));
      }
    }

    graph.moveOriginToPoint(modelPoint);
    invalidateTransform();
    final newT = graph.transform;

    for (final p in preserved) {
      final m = newT.viewToModel(p.viewTail);
      p.v.tailPosition = VaVec(_fixed8(m.x), _fixed8(m.y));
    }
  }

  static double _fixed8(double x) => (x * 1e8).roundToDouble() / 1e8;

  /// Returns a vector that should animate to the toolbox, if any.
  VaVector? onPointerUp(Offset viewPoint) {
    VaVector? toAnimate;

    if (kind == VaDragKind.body) {
      final v = target;
      final set = targetSet;
      if (v != null && set != null && !v.isOnGraph) {
        final cursorModel = transform.viewToModel(viewPoint);
        if (model.scene.graph.bounds.containsPoint(cursorModel)) {
          final ctrl = VectorInteractionController(
            vector: v,
            snap: snapFor(v),
            peerEndpoints: peers(v, set),
          );
          // Drop at current tail (kept via grab-offset during drag).
          ctrl.onDrop(v.tailPosition);
          if (!set.activeVectors.contains(v)) {
            set.activeVectors = [...set.activeVectors, v];
          }
          model.scene.selected = v;
          recomputeResultant(set);
        } else {
          v.animateToToolbox = true;
          toAnimate = v;
        }
      }
    }

    kind = VaDragKind.none;
    target = null;
    targetSet = null;
    grabOffsetView = Offset.zero;
    return toAnimate;
  }

  void completeReturnToToolbox(VaVector v) {
    for (final set in model.scene.vectorSets) {
      if (!set.allVectors.contains(v)) continue;
      set.activeVectors =
          set.activeVectors.where((x) => !identical(x, v)).toList();
      v.returnToToolbox();
      if (identical(model.scene.selected, v)) {
        model.scene.selected = null;
      }
      recomputeResultant(set);
      break;
    }
  }

  bool activateFromToolbox(int slotIndex) {
    final sets = model.scene.vectorSets;
    if (sets.isEmpty) return false;

    late VaVectorSet set;
    late VaVector vector;

    if (sets.length == 1) {
      set = sets.first;
      if (slotIndex < 0 || slotIndex >= set.allVectors.length) return false;
      vector = set.allVectors[slotIndex];
      if (vector.isOnGraph || set.activeVectors.contains(vector)) return false;
    } else {
      if (slotIndex < 0 || slotIndex >= sets.length) return false;
      set = sets[slotIndex];
      final free =
          set.allVectors.where((v) => !set.activeVectors.contains(v)).toList();
      if (free.isEmpty) return false;
      vector = free.first;
    }

    if (!set.activeVectors.contains(vector)) {
      set.activeVectors = [...set.activeVectors, vector];
    }
    vector.dropOntoGraph(
      model.scene.graph.bounds.center,
      otherEndpoints: peers(vector, set),
    );
    model.scene.selected = vector;
    recomputeResultant(set);
    return true;
  }
}
