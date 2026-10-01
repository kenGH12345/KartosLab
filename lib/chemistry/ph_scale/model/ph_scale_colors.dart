import 'dart:ui';

/// Colors from PhET `PHScaleColors.ts`.
class PhScaleColors {
  PhScaleColors._();

  static const Color screenBackground = Color(0xFFFFFFFF);
  static const Color panelFill = Color.fromARGB(255, 230, 230, 230);

  static const Color acidic = Color.fromARGB(255, 238, 79, 73);
  static const Color basic = Color.fromARGB(255, 70, 129, 206);
  static const Color neutral = Color(0xFFFFFFFF);

  static const Color h2oBackground = Color.fromARGB(255, 20, 184, 238);

  static const Color phProbe = Color.fromARGB(255, 64, 0, 111);
  static const Color phProbeWire = Color.fromARGB(255, 80, 80, 80);
  static const Color phMeterDisabled = Color(0xFF757575);

  /// Water solvent color `rgb(224, 255, 255)`.
  static const Color water = Color.fromARGB(255, 224, 255, 255);

  /// PhetColorScheme.RED_COLORBLIND = rgb(255, 85, 0).
  static const Color oxygen = Color.fromARGB(255, 255, 85, 0);
  static const Color hydrogen = Color(0xFFFFFFFF);

  static const Color h3oParticles = Color.fromARGB(255, 204, 0, 0);
  static const Color h3oParticlesStroke = Color.fromARGB(255, 249, 210, 194);
  static const Color ohParticles = Color.fromARGB(255, 0, 0, 255);
  static const Color ohParticlesStroke = Color(0xFF000000);
}
