import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/normal_modes/render/nm_mvt.dart';
import 'package:kratos/normal_modes/model/nm_vec.dart';
import 'package:kratos/normal_modes/normal_modes_constants.dart';
import 'package:kratos/normal_modes/solver/normal_mode_math.dart';

void main() {
  test('1D MVT origin and scale match ScreenView', () {
    final mvt = NmMvt.oneDimension();
    expect(mvt.origin.dx, closeTo(745 / 2 + 10 + 4, 1e-9));
    expect(
      mvt.origin.dy,
      closeTo((NormalModesConstants.layoutHeight - 300) / 2, 1e-9),
    );
    expect(mvt.scale, closeTo(745 / 2, 1e-9));
    final left = mvt.modelToView(const NmVec(-1, 0));
    final right = mvt.modelToView(const NmVec(1, 0));
    expect(right.dx - left.dx, closeTo(745, 1e-9));
  });

  test('MVT inverted Y: +model y is smaller view y', () {
    final mvt = NmMvt.oneDimension();
    final up = mvt.modelToView(const NmVec(0, 0.1));
    final down = mvt.modelToView(const NmVec(0, -0.1));
    expect(up.dy, lessThan(down.dy));
  });

  test('2D MVT uses 420 reserve', () {
    final mvt = NmMvt.twoDimensions();
    expect(
      mvt.origin.dx,
      closeTo((1024 - 420) / 2, 1e-9),
    );
    expect(mvt.origin.dy, closeTo(618 / 2, 1e-9));
  });

  test('toFixed2 matches PhET Utils.toFixed 2 places', () {
    expect(NormalModeMath.toFixed2(0.76536686473), '0.77');
    expect(NormalModeMath.toFixed2(1.41421356237), '1.41');
    expect(NormalModeMath.toFixed2(1.84775906502), '1.85');
  });
}
