import '../cck_constants.dart';
import '../cck_strings.dart';
import '../model/circuit.dart';
import '../model/elements.dart';
import '../model/enums.dart';
import 'cck_render_data.dart';

CckRenderData buildRenderData(CckCircuit circuit) {
  String? valueText(CckElement el) {
    if (!circuit.showValues) return null;
    if (el is CckBattery) return '${_fmt(el.voltage)} V';
    if (el is CckAcSource) return '${_fmt(el.maximumVoltage)} V';
    if (el is CckResistor) return '${_fmt(el.resistance)} Ω';
    if (el is CckLightBulb) return '${_fmt(el.resistance)} Ω';
    if (el is CckCapacitor) return '${_fmt(el.capacitance)} F';
    if (el is CckInductor) return '${_fmt(el.inductance)} H';
    if (el is CckFuse) return '${_fmt(el.currentRating)} A';
    if (el is CckSeriesAmmeter) return '${_fmt(el.current)} A';
    return null;
  }

  String? label(CckElement el) {
    if (!circuit.showLabels) return null;
    return switch (el.kind) {
      CckElementKind.wire => CckStrings.wire,
      CckElementKind.battery => CckStrings.battery,
      CckElementKind.acSource => CckStrings.acVoltage,
      CckElementKind.resistor => switch ((el as CckResistor).resistorKind) {
          CckResistorKind.resistor => CckStrings.resistor,
          CckResistorKind.coin => CckStrings.coin,
          CckResistorKind.paperClip => CckStrings.paperClip,
          CckResistorKind.pencil => CckStrings.pencil,
          CckResistorKind.thinPencil => CckStrings.thinPencil,
          CckResistorKind.eraser => CckStrings.eraser,
          CckResistorKind.dollarBill => CckStrings.dollarBill,
        },
      CckElementKind.lightBulb => CckStrings.lightBulb,
      CckElementKind.capacitor => CckStrings.capacitor,
      CckElementKind.inductor => CckStrings.inductor,
      CckElementKind.switch_ => CckStrings.switchLabel,
      CckElementKind.fuse => CckStrings.fuse,
      CckElementKind.seriesAmmeter => CckStrings.ammeter,
    };
  }

  return CckRenderData(
    viewType: circuit.viewType,
    currentType: circuit.currentType,
    showCurrent: circuit.showCurrent,
    zoom: circuit.animatedZoom,
    elements: [
      for (final el in circuit.elements)
        CckRenderElement(
          id: el.id,
          kind: el.kind,
          start: el.start.pos,
          end: el.end.pos,
          current: el.current,
          selected: identical(circuit.selectedElement, el),
          resistorKind: el is CckResistor ? el.resistorKind : null,
          closed: el is CckSwitch ? el.closed : null,
          tripped: el is CckFuse ? el.tripped : null,
          sparkProgress: el is CckFuse ? el.sparkProgress : -1,
          brightness: el is CckLightBulb ? el.computeBrightness() : 0,
          inductance: el is CckInductor ? el.inductance : 5,
          label: label(el),
          valueText: valueText(el),
          reversed: el is CckBattery && el.reversed,
        ),
    ],
    vertices: [
      for (final v in circuit.vertices)
        CckRenderVertex(
          id: v.id,
          pos: v.pos,
          connected: circuit.countAt(v) > 1,
          selected: identical(circuit.selectedVertex, v),
          voltageText: circuit.showValues
              ? '${v.voltage.toStringAsFixed(CckConstants.meterPrecision)} V'
              : null,
        ),
    ],
    charges: [
      if (circuit.showCurrent)
        for (final c in circuit.charges)
          if (circuit.currentType == CckCurrentType.electrons ||
              c.element.current.abs() >= CckConstants.conventionalThreshold)
            CckRenderCharge(
              x: c.position.x,
              y: c.position.y,
              angle: c.angle,
              sign: c.sign,
            ),
    ],
    voltmeters: [
      for (final m in circuit.voltmeters)
        CckRenderVoltmeter(
          body: m.body,
          redProbe: m.redProbe,
          blackProbe: m.blackProbe,
          active: m.active,
          reading: m.reading,
        ),
    ],
    stopwatchVisible: circuit.stopwatchVisible,
    stopwatchTime: circuit.stopwatchTime,
  );
}

String _fmt(double v) {
  if (v.abs() >= 100) return v.toStringAsFixed(0);
  if (v.abs() >= 10) return v.toStringAsFixed(1);
  return v.toStringAsFixed(CckConstants.meterPrecision);
}
