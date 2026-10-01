/// PhET `getIsotopeColor.ts` — stable-isotope index → color cycle.
library;

import 'package:flutter/material.dart';

import 'data/data.dart';

const List<Color> kIsotopeColors = [
  Color.fromARGB(255, 180, 82, 205), // purple
  Color(0xFF008000), // green
  Color.fromARGB(255, 255, 69, 0), // orangered
  Color.fromARGB(255, 72, 137, 161), // teal
];

final Map<int, Map<int, Color>> _isotopeColorCache = {};

/// Color for isotope identified by proton/neutron counts (stable list order).
Color getIsotopeColor({
  required int protonCount,
  required int neutronCount,
}) {
  final byZ = _isotopeColorCache.putIfAbsent(protonCount, () {
    final stable = IsotopeRepository.instance
        .getStableIsotopesSortedByMass(protonCount);
    // PhET sorts by neutronCount when assigning colors.
    final sorted = List<IsotopeData>.from(stable)
      ..sort((a, b) => a.neutronCount.compareTo(b.neutronCount));
    final map = <int, Color>{};
    for (var i = 0; i < sorted.length; i++) {
      map[sorted[i].neutronCount] = kIsotopeColors[i % kIsotopeColors.length];
    }
    return map;
  });
  return byZ[neutronCount] ?? Colors.grey;
}

Color getIsotopeColorForMass({
  required int atomicNumber,
  required int massNumber,
}) {
  final n = massNumber - atomicNumber;
  return getIsotopeColor(protonCount: atomicNumber, neutronCount: n);
}
