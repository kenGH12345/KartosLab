import 'dart:math' as math;

import '../cck_constants.dart';
import 'cck_vec.dart';
import 'enums.dart';
import 'vertex.dart';

abstract class CckElement {
  CckElement({
    required this.id,
    required this.kind,
    required this.start,
    required this.end,
    required this.length,
  });

  final int id;
  final CckElementKind kind;
  CckVertex start;
  CckVertex end;
  double length;
  double current = 0;
  bool chargeLayoutDirty = true;
  bool get traversable => true;
  double get resistance => 0;
  bool get isMetallic => false;
  double get chargePathLength => math.max(viewLength, 1e-6);

  bool contains(CckVertex v) => identical(v, start) || identical(v, end);

  CckVertex opposite(CckVertex v) => identical(v, start) ? end : start;

  void replaceVertex(CckVertex oldV, CckVertex newV) {
    if (identical(start, oldV)) start = newV;
    if (identical(end, oldV)) end = newV;
  }

  CckVec get center =>
      CckVec((start.x + end.x) / 2, (start.y + end.y) / 2);

  double get viewLength => start.pos.distanceTo(end.pos);
}

class CckWire extends CckElement {
  CckWire({required super.id, required super.start, required super.end})
      : super(kind: CckElementKind.wire, length: CckConstants.wireLength);

  double resistivity = CckConstants.wireResistivityMin;
  double _resistance = CckConstants.minimumWireResistance;

  @override
  bool get isMetallic => true;

  @override
  double get resistance => _resistance;

  void updateResistance() {
    final modelLength = viewLength * CckConstants.metersPerViewCoordinate;
    length = modelLength;
    _resistance = math.max(
      CckConstants.minimumWireResistance,
      resistivity * modelLength / CckConstants.wireCrossSectionalArea,
    );
  }
}

class CckBattery extends CckElement {
  CckBattery({required super.id, required super.start, required super.end})
      : super(kind: CckElementKind.battery, length: CckConstants.batteryLength);

  double voltage = CckConstants.batteryVoltageDefault;
  double internalResistance = CckConstants.batteryMinimumResistance;
  bool reversed = false;
}

class CckAcSource extends CckElement {
  CckAcSource({required super.id, required super.start, required super.end})
      : super(kind: CckElementKind.acSource, length: CckConstants.acVoltageLength);

  double maximumVoltage = CckConstants.batteryVoltageDefault;
  double frequency = CckConstants.acDefaultFrequency;
  double phaseDeg = 0;
  double voltage = 0;
  double internalResistance = CckConstants.batteryMinimumResistance;

  void stepAc(double time) {
    voltage = -maximumVoltage *
        math.sin(
          2 * math.pi * frequency * time + phaseDeg * math.pi / 180,
        );
  }
}

class CckResistor extends CckElement {
  CckResistor({
    required super.id,
    required super.start,
    required super.end,
    this.resistorKind = CckResistorKind.resistor,
  }) : resistanceValue = switch (resistorKind) {
          CckResistorKind.resistor => CckConstants.defaultResistance,
          CckResistorKind.coin || CckResistorKind.paperClip => 0,
          CckResistorKind.pencil => CckConstants.pencilResistance,
          CckResistorKind.thinPencil => CckConstants.thinPencilResistance,
          CckResistorKind.eraser ||
          CckResistorKind.dollarBill =>
            CckConstants.householdLargeResistance,
        },
        super(
          kind: CckElementKind.resistor,
          length: switch (resistorKind) {
            CckResistorKind.resistor => CckConstants.resistorLength,
            CckResistorKind.coin => CckConstants.coinLength,
            CckResistorKind.paperClip => CckConstants.paperClipLength,
            CckResistorKind.pencil ||
            CckResistorKind.thinPencil =>
              CckConstants.pencilLength,
            CckResistorKind.eraser => CckConstants.eraserLength,
            CckResistorKind.dollarBill => CckConstants.dollarBillLength,
          },
        );

  final CckResistorKind resistorKind;
  double resistanceValue;

  @override
  double get resistance => resistanceValue;

  @override
  bool get isMetallic =>
      resistorKind == CckResistorKind.coin ||
      resistorKind == CckResistorKind.paperClip;
}

class CckLightBulb extends CckElement {
  CckLightBulb({required super.id, required super.start, required super.end})
      : super(kind: CckElementKind.lightBulb, length: CckConstants.resistorLength);

  double resistanceValue = CckConstants.defaultResistance;

  @override
  double get resistance => resistanceValue;

  /// `LightBulb.computeBrightness` — PhET source.
  double computeBrightness() {
    final power = (current * current * resistance).abs();
    const multiplier = 0.35;
    const maxPower = 2000.0;
    final numerator = math.log(1 + power * multiplier);
    final denominator = math.log(1 + maxPower * multiplier);
    var b = denominator == 0 ? 0.0 : numerator / denominator;
    b = b.clamp(0.0, 1.0);
    if (b < 1e-6) return 0;
    return b;
  }
}

class CckCapacitor extends CckElement {
  CckCapacitor({required super.id, required super.start, required super.end})
      : super(kind: CckElementKind.capacitor, length: CckConstants.capacitorLength);

  double capacitance = CckConstants.defaultCapacitance;
  double mnaVoltageDrop = 0;
  double mnaCurrent = 0;

  void clearDynamics() {
    mnaVoltageDrop = 0;
    mnaCurrent = 0;
  }
}

class CckInductor extends CckElement {
  CckInductor({required super.id, required super.start, required super.end})
      : super(kind: CckElementKind.inductor, length: CckConstants.inductorLength);

  double inductance = CckConstants.inductanceDefault;
  double mnaVoltageDrop = 0;
  double mnaCurrent = 0;

  void clearDynamics() {
    mnaVoltageDrop = 0;
    mnaCurrent = 0;
  }
}

class CckSwitch extends CckElement {
  CckSwitch({required super.id, required super.start, required super.end})
      : super(kind: CckElementKind.switch_, length: CckConstants.switchLength);

  bool closed = false;

  @override
  bool get traversable => closed;

  @override
  double get resistance =>
      closed ? 0 : CckConstants.maxResistance;
}

class CckFuse extends CckElement {
  CckFuse({required super.id, required super.start, required super.end})
      : super(kind: CckElementKind.fuse, length: CckConstants.fuseLength);

  double currentRating = CckConstants.fuseDefaultRating;
  bool tripped = false;
  double timeExceeded = 0;
  double sparkProgress = -1;
  double _resistance = 0.06 / CckConstants.fuseDefaultRating;

  @override
  bool get traversable => !tripped;

  @override
  double get resistance => _resistance;

  void stepFuse(double dt) {
    final wasTripped = tripped;
    final exceeded = current.abs() > currentRating + 1e-6;
    if (exceeded) {
      timeExceeded += dt;
    } else {
      timeExceeded = 0;
    }
    if (timeExceeded > 0) tripped = true;
    if (tripped && !wasTripped) sparkProgress = 0;
    _resistance = tripped
        ? CckConstants.maxResistance
        : 1 / currentRating * 0.06;
  }

  void resetFuse() {
    tripped = false;
    timeExceeded = 0;
    sparkProgress = -1;
    _resistance = 1 / currentRating * 0.06;
  }
}

class CckSeriesAmmeter extends CckElement {
  CckSeriesAmmeter({required super.id, required super.start, required super.end})
      : super(
          kind: CckElementKind.seriesAmmeter,
          length: CckConstants.seriesAmmeterLength,
        );

  @override
  double get resistance => 0;
}

class CckVoltmeter {
  CckVec body = const CckVec(400, 120);
  CckVec redProbe = const CckVec(360, 200);
  CckVec blackProbe = const CckVec(440, 200);
  bool active = false;
  double? reading;
}