import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/vector_addition/model/enums.dart';
import 'package:kratos/vector_addition/model/graph.dart';
import 'package:kratos/vector_addition/model/va_vec.dart';
import 'package:kratos/vector_addition/model/vector.dart';

void main() {
  late Graph graph;
  late VaVector parent;
  var style = ComponentVectorStyle.invisible;

  setUp(() {
    graph = Graph(initialBounds: VaBounds.defaultGraph);
    style = ComponentVectorStyle.invisible;
    parent = VaVector(
      tailPosition: const VaVec(2, 3),
      xyComponents: const VaVec(4, 5),
      graph: graph,
      coordinateSnapMode: CoordinateSnapMode.cartesian,
      componentStyle: () => style,
      isOnGraph: true,
    );
  });

  test('triangle: x shares tail; y shares tip', () {
    style = ComponentVectorStyle.triangle;
    parent.xComponentVector.update();
    parent.yComponentVector.update();

    final x = parent.xComponentVector;
    expect(x.tailPosition, parent.tailPosition);
    expect(x.tip, VaVec(parent.tip.x, parent.tailPosition.y));

    final y = parent.yComponentVector;
    expect(y.tip, parent.tip);
    expect(y.tailPosition, VaVec(parent.tip.x, parent.tailPosition.y));
  });

  test('parallelogram: both share tail', () {
    style = ComponentVectorStyle.parallelogram;
    parent.xComponentVector.update();
    parent.yComponentVector.update();

    expect(parent.xComponentVector.tailPosition, parent.tailPosition);
    expect(
      parent.xComponentVector.tip,
      VaVec(parent.tip.x, parent.tailPosition.y),
    );
    expect(parent.yComponentVector.tailPosition, parent.tailPosition);
    expect(
      parent.yComponentVector.tip,
      VaVec(parent.tailPosition.x, parent.tip.y),
    );
  });

  test('projection: on axes with offsets', () {
    style = ComponentVectorStyle.projection;
    parent.setProjectionOffsets(-1.5, -1.5);
    final x = parent.xComponentVector;
    expect(x.tailPosition.y, -1.5);
    expect(x.tip.y, -1.5);
    expect(x.xyComponents.x, closeTo(4, 1e-9));

    final y = parent.yComponentVector;
    expect(y.tailPosition.x, -1.5);
    expect(y.tip.x, -1.5);
    expect(y.xyComponents.y, closeTo(5, 1e-9));
  });
}
