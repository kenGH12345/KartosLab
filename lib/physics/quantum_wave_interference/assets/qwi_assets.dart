import '../domain/source_type.dart';

/// Original PhET QWI asset paths (extracted / copied from source tree).
class QwiAssets {
  QwiAssets._();

  static const String _img = 'assets/simulations/quantum_wave_interference/images';
  static const String _snd = 'assets/simulations/quantum_wave_interference/sounds';

  static const String photon = '$_img/photon.svg';
  static const String electron = '$_img/electron.svg';
  static const String neutron = '$_img/neutron.svg';
  static const String heliumAtom = '$_img/heliumAtom.svg';
  static const String singleParticleEmitter = '$_img/singleParticleEmitter.svg';
  static const String experimentScreenIcon = '$_img/experimentScreenIcon.svg';
  static const String highIntensityScreenIcon = '$_img/highIntensityScreenIcon.svg';
  static const String singleParticlesScreenIcon = '$_img/singleParticlesScreenIcon.svg';

  /// scenery-phet `measuringTape.png` (original PhET tape body).
  static const String measuringTape = '$_img/measuringTape.png';

  /// Original `snapshotCaptured.mp3` decoded from source `snapshotCaptured_mp3.js`.
  static const String snapshotCaptured = '$_snd/snapshotCaptured.mp3';

  static String particleIcon(SourceType type) {
    switch (type) {
      case SourceType.photons:
        return photon;
      case SourceType.electrons:
        return electron;
      case SourceType.neutrons:
        return neutron;
      case SourceType.heliumAtoms:
        return heliumAtom;
    }
  }
}
