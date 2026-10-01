import 'dart:math' as math;

import '../cck_constants.dart';
import 'charge.dart';
import 'circuit.dart';
import 'elements.dart';
import 'vertex.dart';

/// `ChargeAnimator.ts`. Equalize order is index-based (source uses shuffle).
class CckChargeAnimator {
  CckChargeAnimator(this.circuit);

  final CckCircuit circuit;
  double scale = 1;
  final List<double> _avgWindow = <double>[];
  double timeScale = 1;

  void reset() {
    scale = 1;
    timeScale = 1;
    _avgWindow.clear();
  }

  void step(double dt) {
    if (circuit.charges.isEmpty || circuit.elements.isEmpty) return;
    dt = math.min(dt, CckConstants.maxChargeDt);

    var maxCurrent = 0.0;
    for (final el in circuit.elements) {
      maxCurrent = math.max(maxCurrent, el.current.abs());
    }
    final maxSpeed = maxCurrent * CckConstants.chargeSpeedScale;
    final maxPositionChange = maxSpeed * CckConstants.maxChargeDt;
    const maxChange = CckConstants.chargeSeparation * 0.43;
    scale = maxPositionChange >= maxChange ? maxChange / maxPositionChange : 1;
    _avgWindow.add(scale);
    if (_avgWindow.length > 30) _avgWindow.removeAt(0);
    final avg = _avgWindow.reduce((a, b) => a + b) / _avgWindow.length;
    timeScale = avg.clamp(0.0, 1.0);

    for (final charge in circuit.charges) {
      if (!charge.element.chargeLayoutDirty) {
        _propagate(charge, dt);
      }
    }
    for (var i = 0; i < 2; i++) {
      _equalizeAll(dt);
    }
    for (final charge in circuit.charges) {
      charge.updatePositionAndAngle();
    }
  }

  void _equalizeAll(double dt) {
    for (final charge in circuit.charges) {
      if (charge.element.chargeLayoutDirty) continue;
      if (charge.element.current.abs() < CckConstants.minCurrent) continue;
      _equalizeCharge(charge, dt);
    }
  }

  void _equalizeCharge(CckCharge charge, double dt) {
    final inEl = circuit.chargesIn(charge.element)
      ..sort((a, b) => a.distance.compareTo(b.distance));
    final index = inEl.indexOf(charge);
    if (index <= 0 || index >= inEl.length - 1) return;
    final upper = inEl[index + 1];
    final lower = inEl[index - 1];
    final neighborSeparation = upper.distance - lower.distance;
    final currentPosition = charge.distance;
    var desired = lower.distance + neighborSeparation / 2;
    final dist = (desired - currentPosition).abs();
    final sameDir = (desired - currentPosition).sign ==
        (-charge.element.current * charge.sign).sign;
    if (!sameDir) return;
    const equalizeSteps = 2;
    final stepSize =
        (5.5 / equalizeSteps * CckConstants.chargeSpeedScale * dt).abs();
    if (dist > stepSize) {
      desired = desired < currentPosition
          ? currentPosition - stepSize
          : currentPosition + stepSize;
    }
    if (desired >= 0 && desired <= charge.element.chargePathLength) {
      charge.distance = desired;
    }
  }

  void _propagate(CckCharge charge, double dt) {
    final current = -charge.element.current * charge.sign;
    if (current.abs() <= CckConstants.minCurrent) return;
    final speed = current * CckConstants.chargeSpeedScale;
    final delta = speed * dt * scale;
    final next = charge.distance + delta;
    if (next >= 0 && next <= charge.element.chargePathLength) {
      charge.distance = next;
      return;
    }
    final overshoot =
        current < 0 ? -next : (next - charge.element.chargePathLength);
    final vertex = next < 0 ? charge.element.start : charge.element.end;
    final positions = _getPositions(charge, overshoot, vertex, 0);
    if (positions.isEmpty) return;
    positions.sort(
      (a, b) => b.distanceToClosest.compareTo(a.distanceToClosest),
    );
    charge.element = positions.first.element;
    charge.distance = positions.first.distance;
  }

  List<_Hop> _getPositions(
    CckCharge charge,
    double overshoot,
    CckVertex vertex,
    int depth,
  ) {
    final hops = <_Hop>[];
    for (final el in circuit.neighbors(vertex)) {
      final current = -el.current * charge.sign;
      double? distance;
      var found = false;
      if (current > CckConstants.minCurrent && identical(el.start, vertex)) {
        distance = overshoot.clamp(0, el.chargePathLength);
        found = true;
      } else if (current < -CckConstants.minCurrent &&
          identical(el.end, vertex)) {
        distance = (el.chargePathLength - overshoot).clamp(0, el.chargePathLength);
        found = true;
      }
      if (!found || distance == null) continue;
      final charges = circuit.chargesIn(el);
      if (charges.isNotEmpty) {
        final atStart = identical(el.start, vertex);
        final closest = atStart
            ? charges.map((c) => c.distance).reduce(math.min)
            : el.chargePathLength -
                charges.map((c) => c.distance).reduce(math.max);
        hops.add(_Hop(el, distance, closest));
      } else if (depth < 20) {
        final downstream = _getPositions(
          charge,
          0,
          el.opposite(vertex),
          depth + 1,
        );
        if (downstream.isNotEmpty) {
          downstream.sort(
            (a, b) => a.distanceToClosest.compareTo(b.distanceToClosest),
          );
          hops.add(
            _Hop(
              el,
              distance,
              downstream.first.distanceToClosest + el.chargePathLength,
            ),
          );
        }
      }
    }
    return hops;
  }
}

class _Hop {
  _Hop(this.element, this.distance, this.distanceToClosest);
  final CckElement element;
  final double distance;
  final double distanceToClosest;
}
