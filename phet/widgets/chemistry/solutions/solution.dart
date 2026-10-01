/// PhET Solution — a liquid solution with solute, solvent, volume, and
/// concentration.
library;

import 'package:flutter/material.dart';

class Solution {
  String solute;
  String solvent;
  double volume; // mL
  double moles; // mol
  double temperature; // K
  Color color;

  Solution({
    this.solute = '',
    this.solvent = 'H₂O',
    this.volume = 100,
    this.moles = 0,
    this.temperature = 298,
    this.color = const Color(0x330000ff),
  });

  /// Concentration in mol/L (M).
  double get concentration => volume > 0 ? moles / (volume / 1000) : 0;

  /// Add solute.
  void addSolute(double mol) {
    moles += mol;
  }

  /// Add solvent (dilute).
  void addSolvent(double ml) {
    volume += ml;
  }

  /// Mix with another solution.
  void mix(Solution other) {
    final totalVol = volume + other.volume;
    if (totalVol > 0) {
      moles += other.moles;
      volume = totalVol;
    }
  }

  /// Reset to pure solvent.
  void reset() {
    moles = 0;
    volume = 100;
    temperature = 298;
    color = const Color(0x330000ff);
  }
}
