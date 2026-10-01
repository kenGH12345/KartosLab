import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/gases_intro/view/layout_policy.dart';

void main() {
  test('fitScale never exceeds 1 and floors at 0.55', () {
    expect(GasesIntroLayoutPolicy.fitScale(2000, 1200), 1.0);
    expect(GasesIntroLayoutPolicy.fitScale(1008, 618), 1.0);
    final tablet = GasesIntroLayoutPolicy.fitScale(1024, 768);
    expect(tablet, lessThanOrEqualTo(1.0));
    expect(tablet, greaterThanOrEqualTo(0.55));
    expect(GasesIntroLayoutPolicy.fitScale(200, 200), 0.55);
  });

  test('physicalSize preserves aspect', () {
    final s = GasesIntroLayoutPolicy.fitScale(800, 600);
    final size = GasesIntroLayoutPolicy.physicalSize(s);
    expect(
      size.width / size.height,
      closeTo(
        GasesIntroLayoutPolicy.logicalWidth /
            GasesIntroLayoutPolicy.logicalHeight,
        1e-9,
      ),
    );
  });

  test('right panel logical width >= Fine/Coarse chrome need', () {
    // 4×40 buttons + 40 value + padding budget
    expect(GasesIntroLayoutPolicy.rightPanelWidthLogical, greaterThanOrEqualTo(236));
  });
}
