// Transformer Simulation — Physics Models
// Faraday's Electromagnetic Lab → Transformer page
//
// Three core models:
//   1. CircuitModel       — battery, voltage, current, wire, coil, electrons
//   2. MagneticFieldModel — B(x,y) via PhET Electromagnet dipole model
//   3. InductionModel      — magnetic flux, dΦ/dt, induced EMF, current, bulb, voltmeter
//
// Physics chain:
//   PowerSource(V) → Current(I) → Coil → Electromagnet → MagneticField B(x,y)
//   → PickupCoil Flux Φ → dΦ/dt → Induced EMF → Induced Current → Bulb/Voltmeter
//
// Magnetic field uses the same dipole model as magnet_and_compass:
//   Electromagnet (current × loops) → MagneticDipole → MagneticField
//   Current direction → N/S pole orientation
//   |Current| × loops → field strength

import 'dart:math';
import 'package:flutter/material.dart';
import '../phet/widgets/physics/magnetism/electromagnet.dart';

// ─────────────────────────────────────────────
//  Power Source — supports DC and AC
// ─────────────────────────────────────────────
enum PowerMode { dc, ac }

class PowerSource {
  double dcVoltage;
  double acAmplitude;
  double frequency;
  PowerMode mode;

  PowerSource({
    this.dcVoltage = 1.0,
    this.acAmplitude = 10.0,
    this.frequency = 0.5,
    this.mode = PowerMode.dc,
  });

  double voltageAt(double t) {
    switch (mode) {
      case PowerMode.dc:
        return dcVoltage;
      case PowerMode.ac:
        return acAmplitude * sin(2 * pi * frequency * t);
    }
  }
}

// ─────────────────────────────────────────────
//  Wire segment — a straight segment of the current path
// ─────────────────────────────────────────────
class WireSegment {
  final Offset start;
  final Offset end;
  const WireSegment(this.start, this.end);
  Offset get delta => end - start;
  double get length => delta.distance;
}

// ─────────────────────────────────────────────
//  1. CircuitModel — builds wire path, carries current
// ─────────────────────────────────────────────
class CircuitModel {
  List<WireSegment> segments = [];
  double current = 0.0;

  void buildPrimaryPath({
    required Offset sourcePos,
    required Offset coilCenter,
    required int turns,
    double sourceW = 70,
    double sourceH = 70,
    double coilW = 120,
    double coilH = 140,
  }) {
    segments.clear();

    // Battery is directly above the coil — wires go from battery bottom
    // down to coil top-left and top-right
    final srcBottomL = Offset(sourcePos.dx - sourceW * 0.25, sourcePos.dy + sourceH / 2);
    final srcBottomR = Offset(sourcePos.dx + sourceW * 0.25, sourcePos.dy + sourceH / 2);
    final coilTopL = Offset(coilCenter.dx - coilW / 2, coilCenter.dy - coilH / 2);
    final coilTopR = Offset(coilCenter.dx + coilW / 2, coilCenter.dy - coilH / 2);

    // Left wire: battery bottom-left → down → coil top-left
    segments.add(WireSegment(srcBottomL, Offset(srcBottomL.dx, coilTopL.dy)));
    segments.add(WireSegment(Offset(srcBottomL.dx, coilTopL.dy), coilTopL));

    // Coil loops (vertical segments)
    final loopSpacing = coilW / turns;
    for (int i = 0; i < turns; i++) {
      final cx = coilCenter.dx - coilW / 2 + (i + 0.5) * loopSpacing;
      segments.add(WireSegment(
        Offset(cx, coilCenter.dy + coilH / 2),
        Offset(cx, coilCenter.dy - coilH / 2),
      ));
    }

    // Right wire: coil top-right → up → battery bottom-right
    segments.add(WireSegment(coilTopR, Offset(srcBottomR.dx, coilTopR.dy)));
    segments.add(WireSegment(Offset(srcBottomR.dx, coilTopR.dy), srcBottomR));
  }

  void buildSecondaryPath({
    required Offset coilCenter,
    required Offset bulbPos,
    required int turns,
    double coilW = 120,
    double coilH = 140,
    double bulbSize = 50,
  }) {
    segments.clear();

    // Coil loops (vertical segments)
    final loopSpacing = coilW / turns;
    for (int i = 0; i < turns; i++) {
      final cx = coilCenter.dx - coilW / 2 + (i + 0.5) * loopSpacing;
      segments.add(WireSegment(
        Offset(cx, coilCenter.dy + coilH / 2),
        Offset(cx, coilCenter.dy - coilH / 2),
      ));
    }

    // Bulb is directly above the coil — wires go from coil top
    // up to bulb bottom-left and bottom-right
    final coilTopL = Offset(coilCenter.dx - coilW * 0.3, coilCenter.dy - coilH / 2);
    final coilTopR = Offset(coilCenter.dx + coilW * 0.3, coilCenter.dy - coilH / 2);
    final bulbLeft = Offset(bulbPos.dx - bulbSize * 0.25, bulbPos.dy + bulbSize * 0.3);
    final bulbRight = Offset(bulbPos.dx + bulbSize * 0.25, bulbPos.dy + bulbSize * 0.3);

    segments.add(WireSegment(coilTopL, Offset(coilTopL.dx, bulbLeft.dy)));
    segments.add(WireSegment(Offset(coilTopL.dx, bulbLeft.dy), bulbLeft));
    segments.add(WireSegment(coilTopR, Offset(coilTopR.dx, bulbRight.dy)));
    segments.add(WireSegment(Offset(coilTopR.dx, bulbRight.dy), bulbRight));
  }
}

// ─────────────────────────────────────────────
//  2. MagneticFieldModel — uses PhET Electromagnet dipole model
//
//  Same model as magnet_and_compass:
//    Electromagnet (current × loops) → MagneticDipole → MagneticField
//    Current direction → N/S pole orientation
//    |Current| × loops → field strength
//
//  B(p) = B_dipole(p)  — computed by PhET MagneticField class
// ─────────────────────────────────────────────
class MagneticFieldModel {
  /// Compute B at point [p] from an electromagnet (coil + current)
  /// Uses PhET's dipole model — same as magnet_and_compass
  static Offset compute({
    required Offset p,
    required Offset coilCenter,
    required double current,
    required int turns,
    double coilRadius = 60.0,
  }) {
    if (current.abs() < 1e-12) return Offset.zero;

    // Create electromagnet with current × turns as strength
    final emag = Electromagnet(
      center: coilCenter,
      axisAngle: 0,
      halfLength: 70,
      loops: turns,
      current: current,
    );

    // Get B-field at point p via PhET MagneticField
    final b = emag.field.valueAt(p);
    return b.toOffset();
  }

  /// Compute B at point [p] from multiple electromagnets (primary + secondary)
  static Offset computeTotal({
    required Offset p,
    required Offset primaryCenter,
    required double primaryCurrent,
    required int primaryTurns,
    required Offset secondaryCenter,
    required double secondaryCurrent,
    required int secondaryTurns,
  }) {
    final bP = compute(
      p: p, coilCenter: primaryCenter,
      current: primaryCurrent, turns: primaryTurns);
    final bS = compute(
      p: p, coilCenter: secondaryCenter,
      current: secondaryCurrent, turns: secondaryTurns);
    return Offset(bP.dx + bS.dx, bP.dy + bS.dy);
  }

  static double magnitude(Offset b) => sqrt(b.dx * b.dx + b.dy * b.dy);
  static double fieldAngle(Offset b) => atan2(b.dy, b.dx);

  /// Compute magnetic flux through pickup coil.
  /// Samples B at multiple points within the coil area and averages.
  /// Φ = B_avg × A
  static double computeFlux({
    required Offset coilCenter,
    required double coilRadius,
    required double areaFactor,
    required Offset sourceCenter,
    required double current,
    required int turns,
  }) {
    if (current.abs() < 1e-12) return 0.0;

    const samplePoints = 5;
    var sumBx = 0.0;
    var count = 0;
    final effectiveRadius = coilRadius * sqrt(areaFactor);

    for (int i = 0; i < samplePoints; i++) {
      for (int j = 0; j < samplePoints; j++) {
        final px = coilCenter.dx - effectiveRadius + (i + 0.5) * (2 * effectiveRadius / samplePoints);
        final py = coilCenter.dy - effectiveRadius + (j + 0.5) * (2 * effectiveRadius / samplePoints);
        final p = Offset(px, py);
        final dist = (p - coilCenter).distance;
        if (dist > effectiveRadius) continue;

        final b = compute(
          p: p, coilCenter: sourceCenter,
          current: current, turns: turns);
        sumBx += b.dx;
        count++;
      }
    }

    if (count == 0) return 0.0;
    final avgB = sumBx / count;
    final area = pi * effectiveRadius * effectiveRadius;
    return avgB * area * 0.0001;
  }
}

// ─────────────────────────────────────────────
//  3. InductionModel — flux, dΦ/dt, EMF, current, bulb, voltmeter
// ─────────────────────────────────────────────
enum IndicatorMode { bulb, voltmeter }

class InductionModel {
  /// Current magnetic flux through pickup coil
  double flux;

  /// Previous flux (for numerical dΦ/dt)
  double _prevFlux;

  /// Induced EMF
  double emf;

  /// Induced current
  double current;

  /// Light bulb brightness (0-1, smoothed)
  double brightness;
  double _rawBrightness;

  /// Voltmeter reading
  double voltmeterReading;

  /// Bulb resistance
  double bulbResistance;

  InductionModel({
    this.flux = 0.0,
    this._prevFlux = 0.0,
    this.emf = 0.0,
    this.current = 0.0,
    this.brightness = 0.0,
    double rawBrightness = 0.0,
    this.voltmeterReading = 0.0,
    this.bulbResistance = 10.0,
  })  : _rawBrightness = rawBrightness;

  /// Update induction: compute EMF from dΦ/dt, then current, then bulb
  void update({
    required double newFlux,
    required int pickupTurns,
    required double dt,
    required IndicatorMode indicatorMode,
  }) {
    _prevFlux = flux;
    flux = newFlux;

    // dΦ/dt — numerical differentiation
    final dPhiDt = dt > 1e-6 ? (flux - _prevFlux) / dt : 0.0;

    // Faraday's law: EMF = -N × dΦ/dt
    emf = -pickupTurns * dPhiDt;

    // Voltmeter reading
    voltmeterReading = emf;

    // Current: I = EMF / R
    current = emf / bulbResistance;

    // Bulb brightness: power ∝ I²R → brightness ∝ |I|
    if (indicatorMode == IndicatorMode.bulb) {
      final maxCurrent = 0.5;
      _rawBrightness = (current.abs() / maxCurrent).clamp(0.0, 1.0);
      final smoothFactor = 1.0 - exp(-dt * 10.0);
      brightness += (_rawBrightness - brightness) * smoothFactor;
    } else {
      brightness = 0.0;
    }
  }

  void reset() {
    flux = 0.0;
    _prevFlux = 0.0;
    emf = 0.0;
    current = 0.0;
    brightness = 0.0;
    _rawBrightness = 0.0;
    voltmeterReading = 0.0;
  }
}

// ─────────────────────────────────────────────
//  Electron model — positions along a wire path
// ─────────────────────────────────────────────
class ElectronModel {
  List<double> positions;

  ElectronModel({required this.positions});

  void tick(double current, double dt) {
    // Electrons are negative charges — they flow opposite to conventional current
    final speed = (-current * 0.03).clamp(-0.5, 0.5);
    for (int i = 0; i < positions.length; i++) {
      positions[i] += speed * dt * 60;
      positions[i] = positions[i] % 1.0;
      if (positions[i] < 0) positions[i] += 1.0;
    }
  }

  void reset(int count) {
    positions = List.generate(count, (i) => i / count);
  }
}

// ─────────────────────────────────────────────
//  Coil model — turns, position, area
// ─────────────────────────────────────────────
class CoilModel {
  int turns;
  Offset center;
  double current;
  double voltage;

  CoilModel({
    this.turns = 4,
    this.center = Offset.zero,
    this.current = 0.0,
    this.voltage = 0.0,
  });
}

// ─────────────────────────────────────────────
//  Complete transformer state
// ─────────────────────────────────────────────
class TransformerState {
  PowerSource source;
  CoilModel primaryCoil;
  CoilModel secondaryCoil;
  CircuitModel primaryCircuit;
  CircuitModel secondaryCircuit;
  InductionModel induction;

  // Pickup coil area factor (0.2 ~ 1.0)
  double pickupAreaFactor;

  // Indicator mode
  IndicatorMode indicatorMode;

  // Display flags
  bool showField;
  bool showPrimaryElectrons;
  bool showSecondaryElectrons;
  bool showCompass;
  bool showFieldMeter;
  bool lockToAxis;

  // Positions
  Offset sourcePos;
  Offset bulbPos;
  Offset compassPos;
  double compassAngle;
  Offset fieldMeterPos;

  // Control
  bool isPaused;
  double simulationTime;

  TransformerState({
    required this.source,
    required this.primaryCoil,
    required this.secondaryCoil,
    required this.primaryCircuit,
    required this.secondaryCircuit,
    required this.induction,
    required this.pickupAreaFactor,
    required this.indicatorMode,
    required this.showField,
    required this.showPrimaryElectrons,
    required this.showSecondaryElectrons,
    required this.showCompass,
    required this.showFieldMeter,
    required this.lockToAxis,
    required this.sourcePos,
    required this.bulbPos,
    required this.compassPos,
    required this.compassAngle,
    required this.fieldMeterPos,
    required this.isPaused,
    required this.simulationTime,
  });
}

// ─────────────────────────────────────────────
//  Physics engine — computes the full chain each tick
// ─────────────────────────────────────────────
class TransformerPhysics {
  static const double primaryResistance = 2.0;

  static void tick({
    required TransformerState state,
    required double dt,
  }) {
    final t = state.simulationTime;

    // 1. Source voltage
    final v1 = state.source.voltageAt(t);

    // 2. Primary current: I₁ = V₁ / R₁
    final i1 = v1 / primaryResistance;

    // 3. Update primary circuit
    state.primaryCoil.voltage = v1;
    state.primaryCoil.current = i1;
    state.primaryCircuit.current = i1;

    // 4. Compute magnetic flux through pickup coil
    //    Uses PhET dipole model — same as magnet_and_compass
    final newFlux = MagneticFieldModel.computeFlux(
      coilCenter: state.secondaryCoil.center,
      coilRadius: 60.0,
      areaFactor: state.pickupAreaFactor,
      sourceCenter: state.primaryCoil.center,
      current: i1,
      turns: state.primaryCoil.turns,
    );

    // 5. Update induction: dΦ/dt → EMF → current → bulb
    state.induction.update(
      newFlux: newFlux,
      pickupTurns: state.secondaryCoil.turns,
      dt: dt,
      indicatorMode: state.indicatorMode,
    );

    // 6. Update secondary coil
    state.secondaryCoil.voltage = state.induction.emf;
    state.secondaryCoil.current = state.induction.current;
    state.secondaryCircuit.current = state.induction.current;
  }
}
