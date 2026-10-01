/// Nucleus packing — shred `ParticleAtom.reconfigureNucleus`.
///
/// Same algorithm as IAAM `NucleusReconfigure` / BAN `NucleusLayout`, adapted
/// to [BaaParticle] so BAA does not couple to IAAM particle types.
library;

import 'dart:math';

import 'baa_particle.dart';

/// Places nucleons around [centerX],[centerY] in model units.
class NucleusPacking {
  NucleusPacking._();

  static const int topLayer = 1;

  static void reconfigure({
    required List<BaaParticle> protons,
    required List<BaaParticle> neutrons,
    required double nucleonRadius,
    required double centerX,
    required double centerY,
  }) {
    final nucleons = <BaaParticle>[];
    var protonIndex = 0;
    var neutronIndex = 0;
    final neutronsPerProton =
        protons.isEmpty ? double.infinity : neutrons.length / protons.length;
    var neutronsToAdd = 0.0;
    while (nucleons.length < neutrons.length + protons.length) {
      neutronsToAdd += neutronsPerProton;
      while (neutronsToAdd >= 1 && neutronIndex < neutrons.length) {
        nucleons.add(neutrons[neutronIndex++]);
        neutronsToAdd -= 1;
      }
      if (protonIndex < protons.length) {
        nucleons.add(protons[protonIndex++]);
      }
    }

    final r = nucleonRadius;
    if (nucleons.isEmpty) return;

    if (nucleons.length == 1) {
      _place(nucleons[0], centerX, centerY, topLayer);
    } else if (nucleons.length == 2) {
      const angle = 0.2 * 2 * pi;
      _place(nucleons[0], centerX + r * cos(angle), centerY + r * sin(angle),
          topLayer);
      _place(nucleons[1], centerX - r * cos(angle), centerY - r * sin(angle),
          topLayer);
    } else if (nucleons.length == 3) {
      const angle = 0.7 * 2 * pi;
      final distFromCenter = r * 1.155;
      for (var i = 0; i < 3; i++) {
        final a = angle + (2 * pi / 3) * i;
        _place(
          nucleons[i],
          centerX + distFromCenter * cos(a),
          centerY + distFromCenter * sin(a),
          topLayer,
        );
      }
    } else if (nucleons.length == 4) {
      const angle = 1.4 * 2 * pi;
      _place(nucleons[0], centerX + r * cos(angle), centerY + r * sin(angle),
          topLayer);
      _place(nucleons[2], centerX - r * cos(angle), centerY - r * sin(angle),
          topLayer);
      final distFromCenter = r * 2 * cos(pi / 3);
      _place(
        nucleons[1],
        centerX + distFromCenter * cos(angle + pi / 2),
        centerY + distFromCenter * sin(angle + pi / 2),
        topLayer + 1,
      );
      _place(
        nucleons[3],
        centerX - distFromCenter * cos(angle + pi / 2),
        centerY - distFromCenter * sin(angle + pi / 2),
        topLayer + 1,
      );
    } else {
      _spiral(nucleons, r, centerX, centerY);
    }
  }

  static void _spiral(
    List<BaaParticle> nucleons,
    double r,
    double centerX,
    double centerY,
  ) {
    final scaleFactor = _linearClamped(3, 10, 2.4, 1.35, r);
    var placementRadius = 0.0;
    var numAtThisRadius = 1;
    var level = 0;
    var placementAngle = 0.0;
    var placementAngleDelta = 0.0;

    for (var i = 0; i < nucleons.length; i++) {
      _place(
        nucleons[i],
        centerX + placementRadius * cos(placementAngle),
        centerY + placementRadius * sin(placementAngle),
        level + topLayer,
      );
      numAtThisRadius--;
      if (numAtThisRadius > 0) {
        placementAngle += placementAngleDelta;
      } else {
        level++;
        placementRadius += r * scaleFactor / level;
        placementAngle += 2 * pi * 0.2 + level * pi;
        numAtThisRadius = (placementRadius * pi / r).floor();
        if (numAtThisRadius < 1) numAtThisRadius = 1;
        placementAngleDelta = 2 * pi / numAtThisRadius;
      }
    }
  }

  static void _place(BaaParticle p, double x, double y, int z) {
    p.setDestination(x, y);
    p.zLayer = z;
  }

  static double _linearClamped(
    double x0,
    double x1,
    double y0,
    double y1,
    double x,
  ) {
    final t = ((x - x0) / (x1 - x0)).clamp(0.0, 1.0);
    return y0 + (y1 - y0) * t;
  }
}
