import 'package:flutter/material.dart';

/// Simulation state for the Magnet & Compass simulation.
///
/// Renamed from `SimState` → `MagnetState` to match the
/// `SoundState` / `BuildANucleusState` naming convention.
///
/// Extracted from `simulations/magnet_and_compass.dart:11-67`.
class MagnetState {
  Offset magnetPos;
  double magnetAngle;
  double strength;
  bool flipped;
  bool showField;
  bool seeInside;
  bool earthField;
  bool showCompass;
  bool showFieldMeter;
  Offset compassPos;
  double compassAngle;
  Offset fieldMeterPos;

  MagnetState({
    required this.magnetPos,
    required this.magnetAngle,
    required this.strength,
    required this.flipped,
    required this.showField,
    required this.seeInside,
    required this.earthField,
    required this.showCompass,
    required this.showFieldMeter,
    required this.compassPos,
    required this.compassAngle,
    required this.fieldMeterPos,
  });

  MagnetState copyWith({
    Offset? magnetPos,
    double? magnetAngle,
    double? strength,
    bool? flipped,
    bool? showField,
    bool? seeInside,
    bool? earthField,
    bool? showCompass,
    bool? showFieldMeter,
    Offset? compassPos,
    double? compassAngle,
    Offset? fieldMeterPos,
  }) => MagnetState(
    magnetPos: magnetPos ?? this.magnetPos,
    magnetAngle: magnetAngle ?? this.magnetAngle,
    strength: strength ?? this.strength,
    flipped: flipped ?? this.flipped,
    showField: showField ?? this.showField,
    seeInside: seeInside ?? this.seeInside,
    earthField: earthField ?? this.earthField,
    showCompass: showCompass ?? this.showCompass,
    showFieldMeter: showFieldMeter ?? this.showFieldMeter,
    compassPos: compassPos ?? this.compassPos,
    compassAngle: compassAngle ?? this.compassAngle,
    fieldMeterPos: fieldMeterPos ?? this.fieldMeterPos,
  );
}
