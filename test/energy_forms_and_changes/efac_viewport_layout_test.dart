
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/energy_forms_and_changes/common/layout/efac_viewport_layout.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';

void main() {
  const design = Size(
    EfacConstants.layoutWidth,
    EfacConstants.layoutHeight,
  );

  test('exact design viewport → identity', () {
    final layout = EfacViewportLayout.compute(design);
    expect(layout.scale, 1);
    expect(layout.widthLimited, isTrue);
    expect(layout.dx, 0);
    expect(layout.offsetYDesign, 0);
    expect(layout.offsetX, 0);
    expect(layout.offsetY, 0);
    expect(layout.fittedAlignment, Alignment.bottomCenter);
  });

  test('width-limited → bottom align, offsetY > 0', () {
    // scale = 1024/1024 = 1; leftover height 182
    final layout = EfacViewportLayout.compute(const Size(1024, 800));
    expect(layout.widthLimited, isTrue);
    expect(layout.scale, 1);
    expect(layout.dx, 0);
    expect(layout.offsetYDesign, 182);
    expect(layout.offsetY, 182);
    expect(layout.fittedAlignment, Alignment.bottomCenter);
  });

  test('height-limited → horizontal center, top align', () {
    // scale = 618/618 = 1; leftover width 376 → dx = 188
    final layout = EfacViewportLayout.compute(const Size(1400, 618));
    expect(layout.widthLimited, isFalse);
    expect(layout.scale, 1);
    expect(layout.offsetYDesign, 0);
    expect(layout.dx, 188);
    expect(layout.offsetX, 188);
    expect(layout.fittedAlignment, Alignment.topCenter);
  });

  test('uniform downscale width-limited', () {
    final layout = EfacViewportLayout.compute(const Size(512, 400));
    expect(layout.scale, closeTo(0.5, 1e-9));
    expect(layout.widthLimited, isTrue);
    expect(layout.dx, 0);
    expect(layout.offsetYDesign, closeTo(400 / 0.5 - 618, 1e-6));
    expect(layout.offsetY, closeTo(layout.offsetYDesign * 0.5, 1e-6));
  });
}
