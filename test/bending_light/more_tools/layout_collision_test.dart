import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/interaction/layout_bump.dart';

void main() {
  test('overlapping a right panel shifts the tool left', () {
    final node = const Rect.fromLTWH(700, 20, 80, 40);
    final panel = const Rect.fromLTWH(640, 8, 190, 160);
    final dx = bumpLeftViewDx(node, [panel]);
    expect(dx, lessThan(0));
    expect(node.shift(Offset(dx, 0)).right, lessThanOrEqualTo(panel.left));
  });

  test('a tool clear of the panels is not moved', () {
    final node = const Rect.fromLTWH(100, 100, 40, 20);
    final panel = const Rect.fromLTWH(640, 8, 190, 160);
    expect(bumpLeftViewDx(node, [panel]), 0);
  });
}
