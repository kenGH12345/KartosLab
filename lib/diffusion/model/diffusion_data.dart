import '../diffusion_constants.dart';
import 'container.dart';
import 'particle.dart';

/// DiffusionData — counts + average T for one side.
class DiffusionData {
  int numberOfParticles1 = 0;
  int numberOfParticles2 = 0;
  double? averageTemperatureK;

  void update({
    required DiffusionContainer container,
    required bool leftSide,
    required List<DiffusionParticle> particles1,
    required List<DiffusionParticle> particles2,
  }) {
    var n1 = 0;
    var n2 = 0;
    var totalKe = 0.0;

    bool inSide(DiffusionParticle p) {
      if (leftSide) {
        return container.inLeft(p.x, p.y);
      }
      return container.inRight(p.x, p.y);
    }

    for (final p in particles1) {
      if (inSide(p)) {
        n1++;
        totalKe += p.getKineticEnergy();
      }
    }
    for (final p in particles2) {
      if (inSide(p)) {
        n2++;
        totalKe += p.getKineticEnergy();
      }
    }

    numberOfParticles1 = n1;
    numberOfParticles2 = n2;
    final total = n1 + n2;
    if (total == 0) {
      averageTemperatureK = null;
    } else {
      final averageKe = totalKe / total;
      averageTemperatureK =
          (2 / 3) * averageKe / DiffusionConstants.boltzmann;
    }
  }
}
