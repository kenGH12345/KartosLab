import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/view/woas_layout.dart';
import 'package:kratos/wave_on_a_string/view/woas_string_painter.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

void main() {
  test('beadViewX spans VIEW_ORIGIN to VIEW_END', () {
    expect(beadViewX(0), viewOriginX);
    expect(beadViewX(60), closeTo(viewEndX, 1e-9));
    expect(beadViewX(1) - beadViewX(0),
        closeTo(scaleFromOriginal * modelUnitsPerGap, 1e-12));
  });

  test('modelToViewY / viewToModelY inverse', () {
    expect(modelToViewY(0), viewOriginY);
    expect(viewToModelY(modelToViewY(40)), closeTo(40, 1e-12));
  });

  test('woasBeadDisplayYs: bead0=nextLeftY, rest=yDraw', () {
    final model = WoasModel();
    model.nextLeftY = 12;
    model.debugSeedBead(index: 5, yDraw: 7);
    final ys = woasBeadDisplayYs(model);
    expect(ys.length, 61);
    expect(ys[0], 12);
    expect(ys[5], 7);
  });

  test('beadViewRadius = scale * gap/2', () {
    expect(beadViewRadius, closeTo(scaleFromOriginal * 5, 1e-12));
  });
}
