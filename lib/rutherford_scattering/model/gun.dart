import 'dart:math' as math;

import '../rs_constants.dart';
import 'alpha_particle.dart';
import 'rs_base_model.dart';
import 'rs_geometry.dart';

/// Gun — port of PhET Gun.ts
class Gun {
  Gun(this.model) {
    // LinearFunction(width1=20, width2=bounds.width, correction1=2, correction2=10)
    _correctionSlope = (10 - 2) / (model.bounds.width - 20);
    _correctionIntercept = 2 - _correctionSlope * 20;
  }

  final RsBaseModel model;
  final math.Random _random = math.Random();

  double dtSinceGunFired = 0;
  bool on = false;

  late final double _correctionSlope;
  late final double _correctionIntercept;

  double _correctionFor(double atomBoundWidth) =>
      _correctionSlope * atomBoundWidth + _correctionIntercept;

  void step(double dt) {
    final initialSpeed = model.alphaParticleEnergy;
    dtSinceGunFired += RsConstants.gunIntensity * dt;
    final dtPerGunFired =
        (model.bounds.width / initialSpeed) / RsConstants.maxParticles;

    if (on && dtSinceGunFired >= dtPerGunFired) {
      final ySign = _random.nextDouble() < 0.5 ? 1.0 : -1.0;
      final rand = _random.nextDouble();
      var particleX = ySign * rand * model.bounds.width / 2;

      final xMin = RsConstants.x0MinFraction * model.bounds.width;
      for (final atom in model.getVisibleSpace().atoms) {
        if ((particleX - atom.position.x).abs() < xMin) {
          final correction = _correctionFor(atom.boundingRect.bounds.width);
          if (particleX > atom.position.x) {
            particleX += correction;
          } else {
            particleX -= correction;
          }
        }
      }

      final particleY = model.bounds.minY;
      final alphaParticle = AlphaParticle(
        speed: initialSpeed,
        defaultSpeed: initialSpeed,
        position: RsVec2(particleX, particleY),
      );
      model.addParticle(alphaParticle);
      dtSinceGunFired = dtSinceGunFired % dtPerGunFired;
    }
  }

  void reset() {
    on = false;
    dtSinceGunFired = 0;
  }
}
