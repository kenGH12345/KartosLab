
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/vector_addition/model/va_vec.dart';
import 'package:kratos/vector_addition/transform/math_coordinate_transform.dart';
import 'package:kratos/vector_addition/vector_addition_constants.dart';

void main() {
  group('MathCoordinateTransform', () {
    late MathCoordinateTransform t;

    setUp(() {
      t = MathCoordinateTransform.fromGraph(
        modelBounds: VaBounds.defaultGraph,
        bottomLeft: const Offset(
          VectorAdditionConstants.defaultGraphBottomLeftX,
          VectorAdditionConstants.defaultGraphBottomLeftY,
        ),
      );
    });

    test('scale is 14.5', () {
      expect(t.scaleX, VectorAdditionConstants.modelToViewScale);
      expect(t.scaleY, VectorAdditionConstants.modelToViewScale);
    });

    test('view size matches model * scale', () {
      expect(t.viewBounds.width, closeTo(50 * 14.5, 1e-9));
      expect(t.viewBounds.height, closeTo(30 * 14.5, 1e-9));
    });

    test('model +y maps to view -y (inversion centralized)', () {
      final origin = t.modelToView(VaVec.zero);
      final up = t.modelToView(const VaVec(0, 1));
      expect(up.dy, lessThan(origin.dy));
      expect(up.dx, closeTo(origin.dx, 1e-9));
    });

    test('round-trip model → view → model', () {
      const p = VaVec(10, 5);
      final back = t.viewToModel(t.modelToView(p));
      expect(back.x, closeTo(p.x, 1e-9));
      expect(back.y, closeTo(p.y, 1e-9));
    });

    test('delta Y signs opposite', () {
      final d = t.modelToViewDelta(const VaVec(0, 2));
      expect(d.dx, 0);
      expect(d.dy, closeTo(-2 * 14.5, 1e-9));
      final back = t.viewToModelDelta(d);
      expect(back.y, closeTo(2, 1e-9));
    });
  });
}
