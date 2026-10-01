import 'enums.dart';
import 'va_vec.dart';
import 'vector.dart';

/// Base for resultant vectors — tip not draggable, not removable, always on graph.
/// Mirrors PhET `ResultantVector.ts`.
abstract class ResultantVector extends VaVector {
  ResultantVector({
    required super.tailPosition,
    required super.xyComponents,
    required super.graph,
    required super.coordinateSnapMode,
    required super.componentStyle,
    super.symbol = '',
  }) : super(
          isTipDraggable: false,
          isRemovableFromGraph: false,
          isOnGraph: true,
        ) {
    _initialTail = tailPosition;
  }

  late final VaVec _initialTail;

  /// At least one contributing vector on the graph (Sum) or operands present (Equations).
  bool get isDefined;

  /// Reset tail; subclasses recompute xy. Keeps [isOnGraph] true.
  void resetResultant() {
    isAnimating = false;
    animateToToolbox = false;
    isOnGraph = true;
    tailPosition = _initialTail;
  }
}

/// Sum of on-graph vectors — Explore 1D / 2D / Lab.
/// Mirrors PhET `SumVector.ts` + `computeSum`.
class SumVector extends ResultantVector {
  SumVector({
    required super.tailPosition,
    required this.contributors,
    required super.graph,
    required super.coordinateSnapMode,
    required super.componentStyle,
    super.symbol = 's',
  }) : super(xyComponents: computeSum(contributors)) {
    recompute();
  }

  /// Non-resultant vectors that may contribute when [VaVector.isOnGraph].
  final List<VaVector> contributors;

  @override
  bool get isDefined => contributors.any((v) => v.isOnGraph);

  void recompute() {
    xyComponents = computeSum(contributors);
    xComponentVector.update();
    yComponentVector.update();
  }

  /// Σ xyComponents for vectors with isOnGraph === true.
  static VaVec computeSum(List<VaVector> vectors) {
    var sum = VaVec.zero;
    for (final v in vectors) {
      if (v.isOnGraph) {
        sum = sum + v.xyComponents;
      }
    }
    return sum;
  }

  @override
  void reset() {
    resetResultant();
    recompute();
  }
}

/// Equations-screen resultant — **not** the same as [SumVector].
/// Mirrors PhET `EquationsResultantVector.update`.
///
/// [operands] are active non-resultant vectors (typically a,b or d,e only).
class EquationsResultant extends ResultantVector {
  EquationsResultant({
    required super.tailPosition,
    required this.operands,
    required this.equationType,
    required super.graph,
    required super.coordinateSnapMode,
    required super.componentStyle,
    super.symbol = 'c',
  }) : super(xyComponents: VaVec.zero) {
    recompute();
  }

  final List<VaVector> operands;
  EquationType equationType;

  @override
  bool get isDefined => operands.isNotEmpty;

  void recompute() {
    xyComponents = compute(operands, equationType);
    xComponentVector.update();
    yComponentVector.update();
  }

  static VaVec compute(List<VaVector> vectors, EquationType type) {
    switch (type) {
      case EquationType.addition:
        var sum = VaVec.zero;
        for (final v in vectors) {
          sum = sum + v.xyComponents;
        }
        return sum;
      case EquationType.subtraction:
        if (vectors.isEmpty) return VaVec.zero;
        var result = vectors.first.xyComponents;
        for (var i = 1; i < vectors.length; i++) {
          result = result - vectors[i].xyComponents;
        }
        return result;
      case EquationType.negation:
        var sum = VaVec.zero;
        for (final v in vectors) {
          sum = sum + v.xyComponents;
        }
        return -sum;
    }
  }

  @override
  void reset() {
    resetResultant();
    recompute();
  }
}
