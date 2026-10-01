import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/hookes_law/constants/hookes_law_constants.dart';
import 'package:kratos/hookes_law/view/parametric_spring_geometry.dart';

void main() {
  test('prolate cycloid folds backward in x and meets the model length', () {
    const length = 1.5;
    final geometry = ParametricSpringGeometry.intro(
      lengthMeters: length,
      springConstant: 200,
      minK: 100,
    );

    expect(geometry.points.length, 12 * 40 + 1);
    expect(geometry.lineWidth, closeTo(3.5, 1e-12));
    expect(
      geometry.rightTipX,
      closeTo(length * HookesLawConstants.unitDisplacementX, 1e-9),
    );

    var folded = false;
    for (var i = 1; i < geometry.points.length; i++) {
      if (geometry.points[i].x < geometry.points[i - 1].x) {
        folded = true;
        break;
      }
    }
    expect(folded, isTrue, reason: 'a sine ribbon is monotonic in x; a prolate cycloid is not');

    final fronts = geometry.points.where((point) => point.front).length;
    final backs = geometry.points.length - fronts;
    expect(fronts, greaterThan(0));
    expect(backs, greaterThan(0));

    final (back, front) = geometry.toPaths();
    expect(back.computeMetrics().isEmpty, isFalse);
    expect(front.computeMetrics().isEmpty, isFalse);
  });

  test('line width tracks k above the Intro minimum', () {
    expect(
      ParametricSpringGeometry.lineWidthFor(100, minK: 100),
      3,
    );
    expect(
      ParametricSpringGeometry.lineWidthFor(1000, minK: 100),
      closeTo(7.5, 1e-12),
    );
  });
}
