import 'dart:ui';

import '../bending_light_constants.dart';
import '../physics/dispersion_function.dart';
import 'enums.dart';
import 'package:kratos/bending_light/bl_strings.dart';

/// Immutable medium substance (`Substance.ts`).
class Substance {
  Substance({
    required this.name,
    required this.indexForRed,
    required this.mystery,
    required this.custom,
  }) : dispersionFunction = DispersionFunction(
          indexForRed,
          BendingLightConstants.wavelengthRed,
        );

  final String name;
  final double indexForRed;
  final bool mystery;
  final bool custom;
  final DispersionFunction dispersionFunction;

  double get indexOfRefractionForRedLight =>
      dispersionFunction.getIndexOfRefraction(BendingLightConstants.wavelengthRed);

  static final air = Substance(
    name: BlStrings.air,
    indexForRed: 1.000293,
    mystery: false,
    custom: false,
  );
  static final water = Substance(
    name: BlStrings.water,
    indexForRed: 1.333,
    mystery: false,
    custom: false,
  );
  static final glass = Substance(
    name: BlStrings.glass,
    indexForRed: 1.5,
    mystery: false,
    custom: false,
  );
  static final diamond = Substance(
    name: BlStrings.diamond,
    indexForRed: 2.419,
    mystery: false,
    custom: false,
  );
  static final mysteryA = Substance(
    name: BlStrings.mysteryA,
    indexForRed: 2.419,
    mystery: true,
    custom: false,
  );
  static final mysteryB = Substance(
    name: BlStrings.mysteryB,
    indexForRed: 1.4,
    mystery: true,
    custom: false,
  );

  static Substance customWith(double indexForRed) => Substance(
        name: BlStrings.custom,
        indexForRed: indexForRed,
        mystery: false,
        custom: true,
      );
}

/// Medium = substance + optional fill hint (`Medium.ts`).
/// Shape bounds are not needed for Intro physics (fixed y=0 interface).
class Medium {
  Medium({
    required this.substance,
    this.colorArgb = 0xFFFFFFFF,
  });

  final Substance substance;
  final int colorArgb;

  double getIndexOfRefraction(double wavelengthMeters) =>
      substance.dispersionFunction.getIndexOfRefraction(wavelengthMeters);

  bool get isMystery => substance.mystery;
}

/// `MediumColorFactory.ts`. White profile for single-color mode, gray steps for white light.
class MediumColorFactory {
  ColorModeEnum lightType = ColorModeEnum.singleColor;

  static const Color _air = Color.fromARGB(255, 255, 255, 255);
  static const Color _water = Color.fromARGB(255, 198, 226, 246);
  static const Color _glass = Color.fromARGB(255, 171, 169, 212);
  static const Color _diamond = Color.fromARGB(255, 78, 79, 164);
  static const int _step = 55;

  int getColor(double indexForRed, {ColorModeEnum? lightType}) {
    final mode = lightType ?? this.lightType;
    final color = mode == ColorModeEnum.singleColor
        ? _profile(_air, _water, _glass, _diamond, indexForRed)
        : _profile(
            const Color.fromARGB(255, 0, 0, 0),
            const Color.fromARGB(255, _step, _step, _step),
            const Color.fromARGB(255, _step * 2, _step * 2, _step * 2),
            const Color.fromARGB(255, _step * 3, _step * 3, _step * 3),
            indexForRed,
          );
    return _pack(color);
  }

  static Color _profile(
    Color air,
    Color water,
    Color glass,
    Color diamond,
    double indexForRed,
  ) {
    final waterN = Substance.water.indexOfRefractionForRedLight;
    final glassN = Substance.glass.indexOfRefractionForRedLight;
    final diamondN = Substance.diamond.indexOfRefractionForRedLight;
    if (indexForRed < waterN) {
      return _blend(air, water, _linear(1, waterN, 0, 1, indexForRed));
    }
    if (indexForRed < glassN) {
      return _blend(water, glass, _linear(waterN, glassN, 0, 1, indexForRed));
    }
    if (indexForRed < diamondN) {
      return _blend(glass, diamond, _linear(glassN, diamondN, 0, 1, indexForRed));
    }
    return diamond;
  }

  static double _linear(double x0, double x1, double y0, double y1, double x) {
    if ((x1 - x0).abs() < 1e-15) return y0;
    return y0 + (x - x0) * (y1 - y0) / (x1 - x0);
  }

  static Color _blend(Color a, Color b, double ratio) {
    final t = ratio.clamp(0.0, 1.0);
    final u = 1 - t;
    int ch(double v) => (v * 255).round().clamp(0, 255);
    return Color.fromARGB(
      ch(a.a * u + b.a * t),
      ch(a.r * u + b.r * t),
      ch(a.g * u + b.g * t),
      ch(a.b * u + b.b * t),
    );
  }

  static int _pack(Color c) {
    int ch(double v) => (v * 255).round().clamp(0, 255);
    return (ch(c.a) << 24) | (ch(c.r) << 16) | (ch(c.g) << 8) | ch(c.b);
  }
}
