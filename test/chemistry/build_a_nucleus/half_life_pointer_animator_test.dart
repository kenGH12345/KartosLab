import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/chemistry/build_a_nucleus/ban_constants.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/half_life_number_line.dart';
import 'package:kratos/chemistry/build_a_nucleus/model/half_life_pointer_animator.dart';

/// Phase 1G-3B-2：指针在 model X 上的 0.7s QUADRATIC_IN_OUT 动画。
void main() {
  HalfLifeNumberLineReading atExp(num exponent, {bool stable = false}) {
    if (stable) {
      return HalfLifeNumberLine.fromValues(
        halfLifeNumber: BanConstants.stableHalfLifeDisplay,
        isStable: true,
      );
    }
    return HalfLifeNumberLine.fromValues(
      halfLifeNumber: math.pow(10.0, exponent).toDouble(),
      isStable: false,
    );
  }

  const settle = 0.8; // 0.7 + 0.1 无论哪段在前

  test('0 → 3：先 0.1s 转正，再 0.7s 移动；终点精确', () {
    final a = HalfLifePointerAnimator();
    a.setTarget(atExp(0));
    a.tick(settle);
    expect(a.exponent, closeTo(0, 1e-12));

    a.setTarget(atExp(3));
    a.tick(HalfLifePointerAnimator.rotationDuration);
    expect(a.exponent, closeTo(0, 1e-12), reason: '旋转段不改 X');
    a.tick(HalfLifePointerAnimator.xDuration);
    expect(a.exponent, closeTo(3, 1e-12));
  });

  test('3 → 6：同样 0.7s X，与距离无关', () {
    final a = HalfLifePointerAnimator();
    a.setTarget(atExp(3));
    a.tick(settle);
    expect(a.exponent, closeTo(3, 1e-12));
    a.setTarget(atExp(6));
    a.tick(HalfLifePointerAnimator.rotationDuration);
    expect(a.exponent, closeTo(3, 1e-12));
    a.tick(HalfLifePointerAnimator.xDuration);
    expect(a.exponent, closeTo(6, 1e-12));
  });

  test('-6 → 18：远距离仍 0.7s', () {
    final a = HalfLifePointerAnimator();
    a.setTarget(atExp(-6));
    a.tick(settle);
    expect(a.exponent, closeTo(-6, 1e-9));
    a.setTarget(atExp(18));
    a.tick(HalfLifePointerAnimator.rotationDuration +
        HalfLifePointerAnimator.xDuration);
    expect(a.exponent, closeTo(18, 1e-9));
  });

  test('X 段中点：QUADRATIC_IN_OUT(0.5)=0.5', () {
    final a = HalfLifePointerAnimator();
    a.setTarget(atExp(0));
    a.tick(settle);
    a.setTarget(atExp(3));
    a.tick(HalfLifePointerAnimator.rotationDuration);
    a.tick(HalfLifePointerAnimator.xDuration / 2);
    expect(HalfLifePointerAnimator.quadraticInOut(0.5), 0.5);
    expect(a.exponent, closeTo(1.5, 1e-12));
  });

  test('Stable：先 0.7s 移到 +24，再 0.1s 转向右', () {
    final a = HalfLifePointerAnimator();
    a.setTarget(atExp(0));
    a.tick(settle);
    a.setTarget(atExp(24, stable: true));
    expect(a.visible, isTrue);
    a.tick(HalfLifePointerAnimator.xDuration);
    expect(a.exponent, closeTo(24, 1e-12));
    expect(a.rotation, closeTo(HalfLifePointerAnimator.rotationDown, 1e-12));
    a.tick(HalfLifePointerAnimator.rotationDuration);
    expect(a.rotation, closeTo(HalfLifePointerAnimator.rotationRight, 1e-12));
  });

  test('Unknown：立即隐藏，X 仍动画到指数 0', () {
    final a = HalfLifePointerAnimator();
    a.setTarget(atExp(3));
    a.tick(settle);
    expect(a.visible, isTrue);
    a.setTarget(HalfLifeNumberLine.fromValues(
      halfLifeNumber: BanConstants.unknownHalfLife,
      isStable: false,
    ));
    expect(a.visible, isFalse);
    expect(a.exponent, closeTo(3, 1e-12), reason: 'stop 后仍停在旧值直到 tick');
    a.tick(settle);
    expect(a.exponent, closeTo(0, 1e-12));
    expect(a.visible, isFalse);
  });

  test('Nonexistent：立即隐藏，X 动画到 0', () {
    final a = HalfLifePointerAnimator();
    a.setTarget(atExp(6));
    a.tick(settle);
    a.setTarget(HalfLifeNumberLine.fromValues(
      halfLifeNumber: BanConstants.nonexistentHalfLife,
      isStable: false,
    ));
    expect(a.visible, isFalse);
    a.tick(settle);
    expect(a.exponent, closeTo(0, 1e-12));
  });

  test('动画中再次 setTarget：stop 从当前值重开，不 queue', () {
    final a = HalfLifePointerAnimator();
    a.setTarget(atExp(18));
    a.tick(HalfLifePointerAnimator.rotationDuration);
    a.tick(0.2);
    final mid = a.exponent;
    expect(mid, greaterThan(0));
    expect(mid, lessThan(18));
    a.setTarget(atExp(3));
    expect(a.exponent, mid);
    a.tick(HalfLifePointerAnimator.rotationDuration);
    expect(a.exponent, closeTo(mid, 1e-12));
    a.tick(HalfLifePointerAnimator.xDuration);
    expect(a.exponent, closeTo(3, 1e-12));
  });

  test('Reset：setTarget 空核，中断后走向 0', () {
    final a = HalfLifePointerAnimator();
    a.setTarget(atExp(12));
    a.tick(0.3);
    a.setTarget(HalfLifeNumberLine.fromValues(
      halfLifeNumber: BanConstants.nonexistentHalfLife,
      isStable: false,
    ));
    a.tick(settle);
    expect(a.exponent, closeTo(0, 1e-12));
    expect(a.visible, isFalse);
  });

  test('stop / dispose：tick 不再改变', () {
    final a = HalfLifePointerAnimator();
    a.setTarget(atExp(9));
    a.tick(0.25);
    final frozen = a.exponent;
    a.stop();
    a.tick(1);
    expect(a.exponent, frozen);
  });
}
