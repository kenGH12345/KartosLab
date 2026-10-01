import '../snap/snap_policy.dart';
import '../vector_addition_constants.dart';
import 'component_vector.dart';
import 'enums.dart';
import 'graph.dart';
import 'root_vector.dart';
import 'va_vec.dart';

/// Interactive vector — mirrors PhET `Vector.ts` (without PhET-iO).
///
/// Tip/tail updates go through [SnapPolicy] invariants.
class VaVector extends RootVector {
  VaVector({
    required super.tailPosition,
    required super.xyComponents,
    required this.graph,
    required this.coordinateSnapMode,
    required ComponentVectorStyle Function() componentStyle,
    super.symbol,
    this.isTipDraggable = true,
    this.isRemovableFromGraph = true,
    this.isOnGraph = false,
  }) : _componentStyle = componentStyle {
    xComponentVector = ComponentVector(
      parent: this,
      componentType: ComponentVectorType.xComponent,
      styleOf: _componentStyle,
    );
    yComponentVector = ComponentVector(
      parent: this,
      componentType: ComponentVectorType.yComponent,
      styleOf: _componentStyle,
    );
    xComponentVector.update();
    yComponentVector.update();
  }

  final Graph graph;
  final CoordinateSnapMode coordinateSnapMode;
  final ComponentVectorStyle Function() _componentStyle;

  final bool isTipDraggable;
  final bool isRemovableFromGraph;

  bool isOnGraph;
  bool animateToToolbox = false;
  bool isAnimating = false;

  late final ComponentVector xComponentVector;
  late final ComponentVector yComponentVector;

  double projectionXOffset = 0;
  double projectionYOffset = 0;

  SnapPolicy get _snap => SnapPolicy(
        mode: coordinateSnapMode,
        orientation: graph.orientation,
        graphBounds: graph.bounds,
      );

  void setProjectionOffsets(double x, double y) {
    projectionXOffset = x;
    projectionYOffset = y;
    xComponentVector.setProjectionOffsets(x, y);
    yComponentVector.setProjectionOffsets(x, y);
  }

  /// Move tip with Cartesian/Polar invariants. Rejects zero-magnitude.
  void moveTipToPositionWithInvariants(VaVec tipPosition) {
    assert(!isAnimating, 'cannot move tip while animating');
    final snapped = _snap.snapTip(tail: tailPosition, proposedTip: tipPosition);
    if (snapped != null) {
      setTip(snapped);
      _syncComponents();
    }
  }

  /// Translate vector: update tail only, **keep xyComponents** (tip moves with tail).
  /// Mirrors PhET `setTailPositionWithInvariants` (not RootVector.setTail).
  void moveTailToPositionWithInvariants(
    VaVec proposedTail, {
    List<({VaVec tail, VaVec tip})> otherEndpoints = const [],
  }) {
    assert(!isAnimating, 'cannot move tail while animating');
    final snapped = _snap.snapTail(
      proposedTail: proposedTail,
      xyComponents: xyComponents,
      otherEndpoints: otherEndpoints,
    );
    tailPosition = snapped;
    _syncComponents();

    if (isRemovableFromGraph) {
      final constrained = _snap.constrainedTailBounds;
      final dragOffset =
          constrained.closestPointTo(proposedTail) - proposedTail;
      if (dragOffset.x.abs() > VectorAdditionConstants.vectorDragThreshold ||
          dragOffset.y.abs() > VectorAdditionConstants.vectorDragThreshold) {
        popOffOfGraph();
      }
    }
  }

  void dropOntoGraph(
    VaVec proposedTail, {
    List<({VaVec tail, VaVec tip})> otherEndpoints = const [],
  }) {
    assert(!isOnGraph, 'already on graph');
    assert(!isAnimating, 'cannot drop while animating');
    isOnGraph = true;
    final snapped = _snap.snapTail(
      proposedTail: proposedTail,
      xyComponents: xyComponents,
      otherEndpoints: otherEndpoints,
    );
    // Translate onto graph — keep xy.
    tailPosition = snapped;
    _syncComponents();
  }

  void popOffOfGraph() {
    assert(isOnGraph, 'already off graph');
    assert(!isAnimating, 'cannot pop while animating');
    isOnGraph = false;
  }

  /// PhET `returnToToolbox` — reset flags; caller removes from activeVectors.
  void returnToToolbox() {
    assert(isRemovableFromGraph, 'vector cannot return to toolbox');
    isAnimating = false;
    animateToToolbox = false;
    isOnGraph = false;
    // Restore initial tail/xy (super.reset also clears isOnGraph).
    super.reset();
    animateToToolbox = false;
    isOnGraph = false;
    _syncComponents();
  }

  void _syncComponents() {
    xComponentVector.update();
    yComponentVector.update();
  }

  @override
  void setTip(VaVec tip) {
    super.setTip(tip);
    _syncComponents();
  }

  @override
  void setTail(VaVec tail) {
    super.setTail(tail);
    _syncComponents();
  }

  @override
  void reset() {
    isAnimating = false;
    animateToToolbox = false;
    isOnGraph = false;
    super.reset();
    _syncComponents();
  }
}

enum ComponentVectorType { xComponent, yComponent }
