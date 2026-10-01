import 'dart:math' as math;
import 'dart:ui';

import '../../numerics/field_sample.dart';
import '../../domain/wave_display_mode.dart';

/// Port of `WaveRasterizer.ts` (combined FieldSample path).
class WaveRasterizer {
  WaveRasterizer._();

  static const double fieldDisplayCutoff = 0.4;
  static const int unreachedVacuum = 0;
  static const int blockedVacuum = 48;
  static const int absorbedVacuum = 32;
  static const double defaultColorPower = 1.8;
  static const double amplitudeColorPowerMultiplier = 1.5;

  static Color fieldSampleToColor(
    FieldSample sample,
    WaveDisplayMode displayMode,
    Color baseColor, {
    double amplitudeScale = 1,
    double colorPower = defaultColorPower,
  }) {
    if (sample is UnreachedSample) {
      return const Color.fromARGB(255, unreachedVacuum, unreachedVacuum, unreachedVacuum);
    }
    if (sample is AbsorbedSample) {
      return const Color.fromARGB(255, absorbedVacuum, absorbedVacuum, absorbedVacuum);
    }
    if (sample is BlockedSample) {
      return const Color.fromARGB(255, blockedVacuum, blockedVacuum, blockedVacuum);
    }
    if (sample is! FieldValueSample) {
      return const Color.fromARGB(255, unreachedVacuum, unreachedVacuum, unreachedVacuum);
    }

    final groups = _coherenceGroups(sample);
    final state = _displayState(groups, amplitudeScale);
    final intensity = _displayModeIntensity(state, displayMode, amplitudeScale, colorPower);
    final br = (baseColor.r * 255.0).round().clamp(0, 255);
    final bg = (baseColor.g * 255.0).round().clamp(0, 255);
    final bb = (baseColor.b * 255.0).round().clamp(0, 255);
    final fr = br * intensity;
    final fg = bg * intensity;
    final fb = bb * intensity;
    final v = state.visibility;
    return Color.fromARGB(
      255,
      _blend(unreachedVacuum.toDouble(), fr, v).round().clamp(0, 255),
      _blend(unreachedVacuum.toDouble(), fg, v).round().clamp(0, 255),
      _blend(unreachedVacuum.toDouble(), fb, v).round().clamp(0, 255),
    );
  }

  static double _blend(double a, double b, double t) => a + (b - a) * t;

  static double _displayModeIntensity(
    _FieldDisplayState state,
    WaveDisplayMode mode,
    double amplitudeScale,
    double colorPower,
  ) {
    final boosted = amplitudeScale * colorPower * amplitudeColorPowerMultiplier;
    final real = state.real * amplitudeScale;
    if (mode == WaveDisplayMode.amplitude) {
      final scaledAmp = math.sqrt(state.intensity) * boosted;
      return (fieldDisplayCutoff * state.visibility + (1 - fieldDisplayCutoff) * scaledAmp * scaledAmp)
          .clamp(0.0, 1.0);
    }
    // electricField / realPart — bipolar phase mapping
    return _phaseDisplayIntensity(real * colorPower) * state.visibility;
  }

  static double _phaseDisplayIntensity(double value) {
    if (value > 0) {
      return (fieldDisplayCutoff + (1 - fieldDisplayCutoff) * value).clamp(fieldDisplayCutoff, 1.0);
    }
    return (fieldDisplayCutoff * (1 + value)).clamp(0.0, fieldDisplayCutoff);
  }

  static List<_GroupState> _coherenceGroups(FieldValueSample sample) {
    final components = sample.components;
    if (components.isEmpty) {
      return const [];
    }
    if (components.length == 1) {
      final g = _GroupState.from(components[0]);
      g.intensity = g.real * g.real + g.imaginary * g.imaginary;
      return [g];
    }
    if (components.length == 2) {
      final g0 = _GroupState.from(components[0]);
      if (components[0].coherenceGroup == components[1].coherenceGroup) {
        g0.add(components[1]);
        g0.intensity = g0.real * g0.real + g0.imaginary * g0.imaginary;
        return [g0];
      }
      final g1 = _GroupState.from(components[1]);
      g0.intensity = g0.real * g0.real + g0.imaginary * g0.imaginary;
      g1.intensity = g1.real * g1.real + g1.imaginary * g1.imaginary;
      return [g0, g1];
    }
    final map = <String, _GroupState>{};
    for (final c in components) {
      final existing = map[c.coherenceGroup];
      if (existing == null) {
        map[c.coherenceGroup] = _GroupState.from(c);
      } else {
        existing.add(c);
      }
    }
    for (final g in map.values) {
      g.intensity = g.real * g.real + g.imaginary * g.imaginary;
    }
    return map.values.toList();
  }

  static _FieldDisplayState _displayState(List<_GroupState> groups, double amplitudeScale) {
    if (groups.isEmpty) {
      return const _FieldDisplayState(real: 0, intensity: 0, visibility: 1);
    }
    var totalI = 0.0;
    _GroupState? strongest;
    for (final g in groups) {
      totalI += g.intensity;
      if (strongest == null || g.intensity > strongest.intensity) {
        strongest = g;
      }
    }
    final scale = strongest != null && strongest.intensity > 0 ? math.sqrt(totalI / strongest.intensity) : 0.0;
    return _FieldDisplayState(
      real: strongest == null ? 0 : strongest.real * scale,
      intensity: totalI,
      visibility: _visibility(groups, amplitudeScale),
    );
  }

  static double _visibility(List<_GroupState> groups, double amplitudeScale) {
    var hasExplicit = false;
    var explicit = 0.0;
    var componentIntensity = 0.0;
    for (final g in groups) {
      if (g.hasExplicitSupport) {
        hasExplicit = true;
        explicit = math.max(explicit, g.support);
      }
      componentIntensity += g.componentIntensity;
    }
    if (hasExplicit) {
      return explicit.clamp(0.0, 1.0);
    }
    return (math.sqrt(componentIntensity) * amplitudeScale).clamp(0.0, 1.0);
  }
}

class _GroupState {
  _GroupState({
    required this.coherenceGroup,
    required this.real,
    required this.imaginary,
    required this.componentIntensity,
    required this.support,
    required this.hasExplicitSupport,
  });

  factory _GroupState.from(FieldComponent c) {
    return _GroupState(
      coherenceGroup: c.coherenceGroup,
      real: c.value.real,
      imaginary: c.value.imaginary,
      componentIntensity: c.value.magnitudeSquared,
      support: c.support ?? 0,
      hasExplicitSupport: c.support != null,
    );
  }

  final String coherenceGroup;
  double real;
  double imaginary;
  double intensity = 0;
  double componentIntensity;
  double support;
  bool hasExplicitSupport;

  void add(FieldComponent c) {
    real += c.value.real;
    imaginary += c.value.imaginary;
    componentIntensity += c.value.magnitudeSquared;
    if (c.support != null) {
      hasExplicitSupport = true;
      support = math.max(support, c.support!);
    }
  }
}

class _FieldDisplayState {
  const _FieldDisplayState({
    required this.real,
    required this.intensity,
    required this.visibility,
  });

  final double real;
  final double intensity;
  final double visibility;
}
