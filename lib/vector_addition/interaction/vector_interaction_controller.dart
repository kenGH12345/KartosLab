import 'dart:ui';

import '../model/enums.dart';
import '../model/graph.dart';
import '../model/resultant_vector.dart';
import '../model/va_vec.dart';
import '../model/vector.dart';
import '../snap/snap_policy.dart';
import '../transform/math_coordinate_transform.dart';
import '../vector_addition_constants.dart';

/// Hit-test helpers for body/tip — mirrors RootVectorNode + VectorTipNode dilations.
/// Used by InteractionController; Painters do not own hit policy.
class VaHitTester {
  VaHitTester({
    required this.transform,
    this.headWidth = VectorAdditionConstants.headWidth,
    this.headHeight = VectorAdditionConstants.headHeight,
    this.tailWidth = VectorAdditionConstants.tailWidth,
    this.fractionalHeadHeight =
        VectorAdditionConstants.fractionalHeadHeight,
  });

  final MathCoordinateTransform transform;
  final double headWidth;
  final double headHeight;
  final double tailWidth;
  final double fractionalHeadHeight;

  /// Approximate body hit: capsule along view segment with dilation.
  bool hitsBody({
    required VaVec tail,
    required VaVec xy,
    required Offset viewPoint,
    required double dilation,
  }) {
    if (xy.magnitude < VectorAdditionConstants.zeroThreshold) return false;
    final a = transform.modelToView(tail);
    final b = transform.modelToView(tail + xy);
    return _distanceToSegment(viewPoint, a, b) <=
        (tailWidth / 2 + dilation);
  }

  /// Tip triangle hit in view space (simplified bounding circle for Phase 4).
  bool hitsTip({
    required VaVec tail,
    required VaVec xy,
    required Offset viewPoint,
    required bool isTouch,
  }) {
    if (xy.magnitude < VectorAdditionConstants.zeroThreshold) return false;

    final tipView = transform.modelToView(tail + xy);
    final dilation = isTouch
        ? VectorAdditionConstants.tipTouchAreaDilation
        : VectorAdditionConstants.tipMouseAreaDilation;

    var tipH = headHeight;
    if (xy.magnitude <= VectorAdditionConstants.shortMagnitude) {
      final viewMag = transform.modelToViewDelta(xy).distance;
      final maxTipH = fractionalHeadHeight * viewMag;
      if (headHeight > maxTipH) {
        tipH = VectorAdditionConstants.smallHeadScale * headHeight;
      }
    }

    // Conservative circle covering dilated tip.
    final radius = (tipH > headWidth ? tipH : headWidth) / 2 + dilation;
    return (viewPoint - tipView).distance <= radius;
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final abLen2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (abLen2 == 0) return (p - a).distance;
    var t = (ap.dx * ab.dx + ap.dy * ab.dy) / abLen2;
    t = t.clamp(0.0, 1.0);
    final proj = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
    return (p - proj).distance;
  }
}

/// Interaction façade for one vector — snap + isOnGraph rules; no RenderData.
class VectorInteractionController {
  VectorInteractionController({
    required this.vector,
    required this.snap,
    this.peerEndpoints = const [],
  });

  final VaVector vector;
  final SnapPolicy snap;
  List<({VaVec tail, VaVec tip})> peerEndpoints;

  void onBodyDrag(VaVec proposedTailModel) {
    if (!vector.isOnGraph) {
      vector.tailPosition = proposedTailModel;
      return;
    }
    vector.moveTailToPositionWithInvariants(
      proposedTailModel,
      otherEndpoints: peerEndpoints,
    );
  }

  void onTipDrag(VaVec proposedTipModel) {
    if (!vector.isTipDraggable) return;
    vector.moveTipToPositionWithInvariants(proposedTipModel);
  }

  void onDrop(VaVec shadowTailModel) {
    if (vector.isOnGraph) return;
    vector.dropOntoGraph(shadowTailModel, otherEndpoints: peerEndpoints);
  }

  void requestAnimateToToolbox() {
    if (!vector.isRemovableFromGraph) return;
    vector.animateToToolbox = true;
  }
}

/// Convenience factory for graph + snap pair used by screens.
({Graph graph, SnapPolicy snap}) createGraphWithSnap({
  required VaBounds bounds,
  required CoordinateSnapMode mode,
  GraphOrientation orientation = GraphOrientation.twoDimensional,
}) {
  final graph = Graph(initialBounds: bounds, orientation: orientation);
  final snap = SnapPolicy(
    mode: mode,
    orientation: orientation,
    graphBounds: graph.bounds,
  );
  return (graph: graph, snap: snap);
}

/// Recompute sum when contributors change — call from screen model listeners.
void syncSum(SumVector sum) => sum.recompute();

void syncEquations(EquationsResultant r) => r.recompute();
