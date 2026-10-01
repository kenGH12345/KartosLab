import 'dart:math' as math;

import 'complex.dart';

enum FieldComponentSource {
  incident,
  topSlit,
  bottomSlit,
}

typedef DecoherenceSlit = FieldComponentSource;

class FieldComponent {
  const FieldComponent({
    required this.source,
    required this.coherenceGroup,
    required this.value,
    this.support,
  });

  final FieldComponentSource source;
  final String coherenceGroup;
  final Complex value;
  final double? support;

  FieldComponent copyWith({
    Complex? value,
    double? support,
  }) {
    return FieldComponent(
      source: source,
      coherenceGroup: coherenceGroup,
      value: value ?? this.value,
      support: support ?? this.support,
    );
  }
}

sealed class FieldSample {
  const FieldSample();
}

class UnreachedSample extends FieldSample {
  const UnreachedSample();
}

class AbsorbedSample extends FieldSample {
  const AbsorbedSample();
}

class BlockedSample extends FieldSample {
  const BlockedSample();
}

class FieldValueSample extends FieldSample {
  const FieldValueSample(this.components);

  final List<FieldComponent> components;
}

/// `FieldSampleMath.computeSampleIntensity`
double computeSampleIntensity(FieldSample sample) {
  if (sample is! FieldValueSample) {
    return 0;
  }
  final components = sample.components;
  if (components.isEmpty) {
    return 0;
  }
  if (components.length == 1) {
    return components[0].value.magnitudeSquared;
  }
  if (components.length == 2) {
    final v0 = components[0].value;
    final v1 = components[1].value;
    if (components[0].coherenceGroup == components[1].coherenceGroup) {
      final real = v0.real + v1.real;
      final imag = v0.imaginary + v1.imaginary;
      return real * real + imag * imag;
    }
    return v0.magnitudeSquared + v1.magnitudeSquared;
  }

  final groups = <String, Complex>{};
  for (final c in components) {
    final prev = groups[c.coherenceGroup] ?? Complex.zero;
    groups[c.coherenceGroup] = prev + c.value;
  }
  var intensity = 0.0;
  for (final sum in groups.values) {
    intensity += sum.magnitudeSquared;
  }
  return intensity;
}

Complex getRepresentativeComplex(FieldSample sample) {
  if (sample is! FieldValueSample || sample.components.isEmpty) {
    return Complex.zero;
  }
  final components = sample.components;
  if (components.length == 1) {
    return components[0].value;
  }
  if (components.length == 2) {
    final v0 = components[0].value;
    final v1 = components[1].value;
    if (components[0].coherenceGroup == components[1].coherenceGroup) {
      return v0 + v1;
    }
    final i0 = v0.magnitudeSquared;
    final i1 = v1.magnitudeSquared;
    return _representativeFromStrongest(i0 + i1, i0 >= i1 ? v0 : v1, i0 >= i1 ? i0 : i1);
  }

  final groups = <String, Complex>{};
  for (final c in components) {
    final prev = groups[c.coherenceGroup] ?? Complex.zero;
    groups[c.coherenceGroup] = prev + c.value;
  }
  var total = 0.0;
  var strongest = Complex.zero;
  var strongestI = 0.0;
  for (final sum in groups.values) {
    final i = sum.magnitudeSquared;
    total += i;
    if (i > strongestI) {
      strongestI = i;
      strongest = sum;
    }
  }
  return _representativeFromStrongest(total, strongest, strongestI);
}

Complex _representativeFromStrongest(double totalIntensity, Complex strongest, double strongestIntensity) {
  if (totalIntensity <= 0 || strongestIntensity <= 0) {
    return Complex.zero;
  }
  final scale = math.sqrt(totalIntensity / strongestIntensity);
  return strongest.scale(scale);
}
