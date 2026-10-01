import '../cck_strings.dart';
import '../model/enums.dart';

class CckToolboxSpec {
  const CckToolboxSpec({
    required this.kind,
    required this.label,
    this.resistorKind,
  });

  final CckElementKind kind;
  final String label;
  final CckResistorKind? resistorKind;
}

/// LabScreenView.ts page 1 then page 2. Each page starts with Wire.
const List<CckToolboxSpec> kCckToolboxPage1 = [
  CckToolboxSpec(kind: CckElementKind.wire, label: CckStrings.wire),
  CckToolboxSpec(kind: CckElementKind.battery, label: CckStrings.battery),
  CckToolboxSpec(kind: CckElementKind.acSource, label: CckStrings.acVoltage),
  CckToolboxSpec(kind: CckElementKind.lightBulb, label: CckStrings.lightBulb),
  CckToolboxSpec(kind: CckElementKind.resistor, label: CckStrings.resistor),
  CckToolboxSpec(kind: CckElementKind.capacitor, label: CckStrings.capacitor),
  CckToolboxSpec(kind: CckElementKind.inductor, label: CckStrings.inductor),
  CckToolboxSpec(kind: CckElementKind.switch_, label: CckStrings.switchLabel),
];

const List<CckToolboxSpec> kCckToolboxPage2 = [
  CckToolboxSpec(kind: CckElementKind.wire, label: CckStrings.wire),
  CckToolboxSpec(kind: CckElementKind.fuse, label: CckStrings.fuse),
  CckToolboxSpec(
    kind: CckElementKind.resistor,
    label: CckStrings.dollarBill,
    resistorKind: CckResistorKind.dollarBill,
  ),
  CckToolboxSpec(
    kind: CckElementKind.resistor,
    label: CckStrings.paperClip,
    resistorKind: CckResistorKind.paperClip,
  ),
  CckToolboxSpec(
    kind: CckElementKind.resistor,
    label: CckStrings.coin,
    resistorKind: CckResistorKind.coin,
  ),
  CckToolboxSpec(
    kind: CckElementKind.resistor,
    label: CckStrings.eraser,
    resistorKind: CckResistorKind.eraser,
  ),
  CckToolboxSpec(
    kind: CckElementKind.resistor,
    label: CckStrings.pencil,
    resistorKind: CckResistorKind.pencil,
  ),
  CckToolboxSpec(
    kind: CckElementKind.resistor,
    label: CckStrings.thinPencil,
    resistorKind: CckResistorKind.thinPencil,
  ),
];
