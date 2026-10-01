import 'dart:math' as math;

import '../rs_constants.dart';
import 'alpha_particle.dart';
import 'atom.dart';
import 'atom_space.dart';
import 'rs_geometry.dart';

/// Rutherford atom with PhET trajectory algorithm — RutherfordAtom.ts
class RutherfordAtom extends Atom {
  RutherfordAtom({
    required this.space,
    required this.protonCountGetter,
    required RsVec2 position,
    required double boundingWidth,
  }) : super(position, boundingWidth);

  final AtomSpace space;
  final int Function() protonCountGetter;

  @override
  void removeParticle(AlphaParticle alphaParticle, {bool isError = false}) {
    super.removeParticle(alphaParticle);
    if (isError) {
      space.emitParticleRemovedFromAtom(alphaParticle);
    }
  }

  /// Port of RutherfordAtom.moveParticle — see SOURCE_ANALYSIS.md §6.
  @override
  void moveParticle(AlphaParticle alphaParticle, double dt) {
    final rotationAngle = alphaParticle.rotationAngle;
    final correctedInitialPosition = _rotatePointAround(
      alphaParticle.initialPosition,
      position,
      -rotationAngle,
    );
    final correctedPosition = _rotatePointAround(
      alphaParticle.position,
      position,
      -rotationAngle,
    );

    const x0Min = 0.00001;
    const lDivisor = 8;

    final L = boundingRect.bounds.width;
    final p = protonCountGetter();
    final pd = RsConstants.defaultProtonCount;
    final s = alphaParticle.speed;
    final s0 = alphaParticle.initialSpeed;
    final sd = RsConstants.defaultAlphaEnergy;

    final relativeInitialPosition = correctedInitialPosition.minus(position);
    var x0 = relativeInitialPosition.x.abs();
    if (x0 < x0Min) x0 = x0Min;
    final y0 = relativeInitialPosition.y;

    final relativePosition = correctedPosition.minus(position);
    var x = relativePosition.x;
    final y = relativePosition.y;
    var xWasNegative = false;
    if (x < 0) {
      x *= -1;
      xWasNegative = true;
    }

    if (pd <= 0 || s0 == 0) {
      removeParticle(alphaParticle, isError: true);
      return;
    }

    final D = (L / lDivisor) * (p / pd) * ((sd * sd) / (s0 * s0));

    final i0 = (x0 * x0) + (y0 * y0);
    if (i0 < 0) {
      removeParticle(alphaParticle, isError: true);
      return;
    }
    final b1 = math.sqrt(i0);

    final i1 = (-2 * D * b1) - (2 * D * y0) + (x0 * x0);
    if (i1 < 0) {
      removeParticle(alphaParticle, isError: true);
      return;
    }
    final b = 0.5 * (x0 + math.sqrt(i1));

    final i2 = (x * x) + (y * y);
    if (i2 < 0) {
      removeParticle(alphaParticle, isError: true);
      return;
    }
    final r = math.sqrt(i2);
    final phi = math.atan2(x, -y);

    final t1 = (b * math.cos(phi)) - ((D / 2) * math.sin(phi));
    final i3 = math.pow(b, 4).toDouble() + (r * r * t1 * t1);
    if (i3 < 0) {
      removeParticle(alphaParticle, isError: true);
      return;
    }
    final phiNew = phi + ((b * b * s * dt) / (r * math.sqrt(i3)));

    final i4 = (b * math.sin(phiNew)) + ((D / 2) * (math.cos(phiNew) - 1));
    if (i4 < 0) {
      removeParticle(alphaParticle, isError: true);
      return;
    }
    final rNew = (b * b / i4).abs();
    if (rNew == 0) {
      removeParticle(alphaParticle, isError: true);
      return;
    }
    final sNew = s0 * math.sqrt(1 - (D / rNew));

    var xNew = rNew * math.sin(phiNew);
    if (xWasNegative) xNew *= -1;
    final yNew = -rNew * math.cos(phiNew);

    if (!(b > 0) || !(sNew > 0)) {
      removeParticle(alphaParticle, isError: true);
      return;
    }

    var delta = RsVec2(xNew, yNew).minus(relativePosition);
    delta = delta.rotated(alphaParticle.rotationAngle);
    alphaParticle.setPosition(alphaParticle.position.plus(delta));
    alphaParticle.speed = sNew;
    alphaParticle.orientation = phiNew;
  }

  RsVec2 _rotatePointAround(RsVec2 point, RsVec2 rotatePoint, double angle) {
    final sinAngle = math.sin(angle);
    final cosAngle = math.cos(angle);
    final translated = point.minus(rotatePoint);
    final xNew = translated.x * cosAngle - translated.y * sinAngle;
    final yNew = translated.x * sinAngle + translated.y * cosAngle;
    return RsVec2(xNew, yNew).plus(rotatePoint);
  }
}
