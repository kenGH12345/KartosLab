import '../constants/qwi_constants.dart';
import '../constants/qwi_units.dart';
import 'source_type.dart';

/// Matter-wave properties. Photons must not use [deBroglieWavelengthM].
class MatterWaveProperties {
  const MatterWaveProperties({
    required this.sourceType,
    required this.speedMps,
  });

  final SourceType sourceType;
  final double speedMps;

  double get massKg => QwiConstants.particleMassKg(sourceType);

  /// Wavelength in meters (0 for photons).
  double get wavelengthM {
    if (sourceType.isPhoton) {
      return 0;
    }
    return QwiConstants.deBroglieWavelengthM(massKg: massKg, speedMps: speedMps);
  }

  double get wavelengthNm => QwiUnits.mToNm(wavelengthM);
}

/// Effective wavelength for any source type.
double effectiveWavelengthM({
  required SourceType sourceType,
  required double photonWavelengthNm,
  required double particleSpeedMps,
}) {
  if (sourceType.isPhoton) {
    return QwiUnits.nmToM(photonWavelengthNm);
  }
  return MatterWaveProperties(sourceType: sourceType, speedMps: particleSpeedMps).wavelengthM;
}
