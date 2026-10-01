import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/view/woas_layout.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

/// Source WrenchNode / StartNode geometry lock.
void main() {
  test('wrench Image offset uses StartNode scale, not image×start compound', () {
    // Image(x:-40,y:-24,scale:0.9/4) under StartNode(scale:1.25) at VIEW_ORIGIN.
    const imageContentScale = 0.9 / 4;
    const intrinsicW = 240.0;
    const intrinsicH = 846.0;

    final left = viewOriginX + (-40) * scaleFromOriginal;
    final top = viewOriginY + (-24) * scaleFromOriginal;
    final w = intrinsicW * imageContentScale * scaleFromOriginal;
    final h = intrinsicH * imageContentScale * scaleFromOriginal;

    expect(left, closeTo(100, 1e-9));
    expect(top, closeTo(235, 1e-9));
    expect(w, closeTo(67.5, 1e-9));
    expect(h, closeTo(237.9375, 1e-9));

    // Jaw/node origin = bead0 at equilibrium (VIEW_ORIGIN).
    expect(beadViewX(0), viewOriginX);
    expect(modelToViewY(0), viewOriginY);

    // Regression: wrong compounding would place wrench near bead (≈138.75).
    final wrongLeft = viewOriginX - 40 * imageContentScale * scaleFromOriginal;
    expect(left, isNot(closeTo(wrongLeft, 1)));
  });
}
