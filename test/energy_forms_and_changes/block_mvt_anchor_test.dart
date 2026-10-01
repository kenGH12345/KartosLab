
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/intro/widgets/block_node_widget.dart';

void main() {
  group('BlockNode MVT local origin (BlockNode.ts)', () {
    test('node origin is untransformed bottom-center, not painted front', () {
      const face = EfacConstants.blockSurfaceWidth * EfacConstants.introMvtScaleFactor;
      final faceOff = BlockNodeWidget.blockFaceOffset(face);
      final originInCanvas = BlockNodeWidget.localOriginFromTopLeft(face);

      // Painted front bottom-center in PhET local = faceOffset.
      // In canvas = canvasOrigin + faceOffset.
      final paintedBottom = originInCanvas + faceOff;

      // Widget positions MVT at originInCanvas — painted sits at +faceOff.
      expect(faceOff.dy, greaterThan(0)); // Y-down: front shifts down
      expect(faceOff.dx, lessThan(0)); // front shifts left
      expect(paintedBottom.dy - originInCanvas.dy, closeTo(faceOff.dy, 1e-9));
    });

    test('perspective constants match EFACConstants', () {
      expect(
        BlockNodeWidget.perspectiveEdgeProportion,
        closeTo(0.3535533905932738, 1e-9),
      );
      expect(BlockNodeWidget.perspectiveAngle, closeTo(0.7853981633974483, 1e-9));
    });
  });
}
