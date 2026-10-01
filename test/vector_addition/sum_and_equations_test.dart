import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/vector_addition/model/enums.dart';
import 'package:kratos/vector_addition/model/graph.dart';
import 'package:kratos/vector_addition/model/resultant_vector.dart';
import 'package:kratos/vector_addition/model/va_vec.dart';
import 'package:kratos/vector_addition/model/vector.dart';

VaVector _vec(VaVec xy, {required Graph g, bool onGraph = false}) {
  return VaVector(
    tailPosition: VaVec.zero,
    xyComponents: xy,
    graph: g,
    coordinateSnapMode: CoordinateSnapMode.cartesian,
    componentStyle: () => ComponentVectorStyle.invisible,
    isOnGraph: onGraph,
  );
}

void main() {
  late Graph graph;

  setUp(() {
    graph = Graph(initialBounds: VaBounds.defaultGraph);
  });

  group('SumVector', () {
    test('sums only isOnGraph vectors', () {
      final a = _vec(const VaVec(3, 0), g: graph, onGraph: true);
      final b = _vec(const VaVec(0, 4), g: graph, onGraph: true);
      final c = _vec(const VaVec(10, 10), g: graph, onGraph: false);

      final sum = SumVector(
        tailPosition: VaVec.zero,
        contributors: [a, b, c],
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
      );

      expect(sum.xyComponents, const VaVec(3, 4));
      expect(sum.isDefined, isTrue);
      expect(sum.isTipDraggable, isFalse);
      expect(sum.isRemovableFromGraph, isFalse);
      expect(sum.isOnGraph, isTrue);
    });

    test('isDefined false when none on graph', () {
      final a = _vec(const VaVec(1, 0), g: graph);
      final sum = SumVector(
        tailPosition: VaVec.zero,
        contributors: [a],
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
      );
      expect(sum.isDefined, isFalse);
      expect(sum.xyComponents, VaVec.zero);
    });

    test('recompute after drop', () {
      final a = _vec(const VaVec(2, 1), g: graph);
      final sum = SumVector(
        tailPosition: VaVec.zero,
        contributors: [a],
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
      );
      a.dropOntoGraph(const VaVec(5, 5));
      sum.recompute();
      expect(sum.xyComponents, const VaVec(2, 1));
      expect(sum.isDefined, isTrue);
    });
  });

  group('EquationsResultant', () {
    VaVector a() => _vec(const VaVec(3, 1), g: graph, onGraph: true);
    VaVector b() => _vec(const VaVec(1, 2), g: graph, onGraph: true);

    test('addition: c = a + b', () {
      final ops = [a(), b()];
      final c = EquationsResultant(
        tailPosition: const VaVec(25, 5),
        operands: ops,
        equationType: EquationType.addition,
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
      );
      expect(c.xyComponents, const VaVec(4, 3));
    });

    test('subtraction: c = a - b', () {
      final ops = [a(), b()];
      final c = EquationsResultant(
        tailPosition: const VaVec(25, 5),
        operands: ops,
        equationType: EquationType.subtraction,
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
      );
      expect(c.xyComponents, const VaVec(2, -1));
    });

    test('negation: c = -(a + b)', () {
      final ops = [a(), b()];
      final c = EquationsResultant(
        tailPosition: const VaVec(25, 5),
        operands: ops,
        equationType: EquationType.negation,
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
      );
      expect(c.xyComponents, const VaVec(-4, -3));
    });

    test('does not filter by isOnGraph (unlike SumVector)', () {
      // Equations operands are always on graph; compute ignores isOnGraph flag.
      final off = _vec(const VaVec(5, 0), g: graph, onGraph: false);
      final on = _vec(const VaVec(1, 0), g: graph, onGraph: true);
      final c = EquationsResultant(
        tailPosition: VaVec.zero,
        operands: [off, on],
        equationType: EquationType.addition,
        graph: graph,
        coordinateSnapMode: CoordinateSnapMode.cartesian,
        componentStyle: () => ComponentVectorStyle.invisible,
      );
      // Still sums all operands — NOT SumVector semantics.
      expect(c.xyComponents, const VaVec(6, 0));
      expect(SumVector.computeSum([off, on]), const VaVec(1, 0));
    });
  });
}
