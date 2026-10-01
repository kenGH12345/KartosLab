// Transformer Simulation Page
// Faraday's Electromagnetic Lab — Transformer
//
// Three core models:
//   CircuitModel       — battery, voltage, current, wire, coil, electrons
//   MagneticFieldModel — B(x,y), compass, field meter
//   InductionModel      — flux, dΦ/dt, EMF, current, bulb, voltmeter
//
// Layout:
//   Top-left:   DC Power Supply panel
//   Top-right:  Electromagnet Control panel (primary coil loops)
//   Mid-left:   Electromagnet Coil
//   Mid-right:  Pickup Coil + Bulb/Voltmeter
//   Right-mid: Pickup Coil panel (loops, area, indicator)
//   Right-bot:  Tools panel (field, electrons, compass, meter, lock)
//   Bottom:     Pause / Reset

import 'dart:math';
import 'package:flutter/material.dart';
import 'transformer_model.dart';
import 'transformer_painter.dart';

// ─────────────────────────────────────────────
//  Compass widget
// ─────────────────────────────────────────────
class _CompassWidget extends StatelessWidget {
  final Offset center;
  final double needleAngle;

  const _CompassWidget({required this.center, required this.needleAngle});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - 30,
      top: center.dy - 30,
      child: CustomPaint(
        size: const Size(60, 60),
        painter: _CompassPainter(angle: needleAngle),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double angle;
  const _CompassPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;

    canvas.drawCircle(c, r, Paint()..color = Colors.black26);
    canvas.drawCircle(c, r, Paint()..color = const Color(0xfff5f5f5));
    canvas.drawCircle(c, r, Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4;
      canvas.drawLine(
        Offset(c.dx + cos(a) * (r - 4), c.dy + sin(a) * (r - 4)),
        Offset(c.dx + cos(a) * r, c.dy + sin(a) * r),
        Paint()..color = Colors.black38..strokeWidth = 1);
    }

    final needleLen = r - 6;
    final tip = Offset(c.dx + cos(angle) * needleLen, c.dy + sin(angle) * needleLen);
    final tail = Offset(c.dx - cos(angle) * needleLen, c.dy - sin(angle) * needleLen);

    canvas.drawLine(c, tip, Paint()..color = Colors.red..strokeWidth = 3..strokeCap = StrokeCap.round);
    canvas.drawLine(c, tail, Paint()..color = Colors.white54..strokeWidth = 3..strokeCap = StrokeCap.round);
    canvas.drawCircle(c, 2.5, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.angle != angle;
}

// ─────────────────────────────────────────────
//  Field Meter widget
// ─────────────────────────────────────────────
class _FieldMeterWidget extends StatelessWidget {
  final Offset center;
  final double magnitude;
  final double angleDeg;
  final double bx;
  final double by;

  const _FieldMeterWidget({
    required this.center,
    required this.magnitude,
    required this.angleDeg,
    required this.bx,
    required this.by,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - 80,
      top: center.dy - 55,
      child: Container(
        width: 160,
        height: 110,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.lightBlue, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomPaint(
          size: const Size(160, 110),
          painter: TransformerFieldMeterPainter(
            magnitude: magnitude, angleDeg: angleDeg, bx: bx, by: by),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Main Transformer Page
// ─────────────────────────────────────────────
class TransformerPage extends StatefulWidget {
  const TransformerPage({super.key});

  @override
  State<TransformerPage> createState() => _TransformerPageState();
}

class _TransformerPageState extends State<TransformerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late TransformerState _state;
  late ElectronModel _primaryElectrons;
  late ElectronModel _secondaryElectrons;

  // Layout positions
  late Offset _sourcePos;
  late Offset _primaryCenter;
  late Offset _secondaryCenter;
  late Offset _bulbPos;

  // Source group (battery + primary coil) drag state
  bool _isSourceDragging = false;
  Offset _sourceDragOffset = Offset.zero;

  // Bulb group (bulb + secondary coil) drag state
  bool _isBulbDragging = false;
  Offset _bulbDragOffset = Offset.zero;

  // Track which components have been initialized
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _state = TransformerState(
      source: PowerSource(
        dcVoltage: 0.0,
        acAmplitude: 10.0,
        frequency: 0.5,
        mode: PowerMode.dc,
      ),
      primaryCoil: CoilModel(turns: 4),
      secondaryCoil: CoilModel(turns: 4),
      primaryCircuit: CircuitModel(),
      secondaryCircuit: CircuitModel(),
      induction: InductionModel(bulbResistance: 10.0),
      pickupAreaFactor: 0.75,
      indicatorMode: IndicatorMode.bulb,
      showField: true,
      showPrimaryElectrons: true,
      showSecondaryElectrons: true,
      showCompass: false,
      showFieldMeter: false,
      lockToAxis: false,
      sourcePos: Offset.zero,
      bulbPos: Offset.zero,
      compassPos: const Offset(200, 300),
      compassAngle: 0,
      fieldMeterPos: const Offset(300, 200),
      isPaused: false,
      simulationTime: 0.0,
    );

    _primaryElectrons = ElectronModel(positions: []);
    _primaryElectrons.reset(10);
    _secondaryElectrons = ElectronModel(positions: []);
    _secondaryElectrons.reset(10);

    _animController.addListener(_tick);
  }

  void _tick() {
    if (_state.isPaused) return;
    final dt = 1 / 60.0;
    _state.simulationTime += dt;

    // Run physics chain
    TransformerPhysics.tick(state: _state, dt: dt);

    // Update electrons — speed ∝ |current|, direction follows sign
    _primaryElectrons.tick(_state.primaryCoil.current, dt);
    _secondaryElectrons.tick(_state.induction.current, dt);

    // Update compass angle from local magnetic field (PhET dipole model)
    final b = MagneticFieldModel.compute(
      p: _state.compassPos,
      coilCenter: _primaryCenter,
      current: _state.primaryCircuit.current,
      turns: _state.primaryCoil.turns,
    );
    if (MagneticFieldModel.magnitude(b) > 1e-8) {
      _state.compassAngle = MagneticFieldModel.fieldAngle(b);
    }

    setState(() {});
  }

  @override
  void dispose() {
    _animController.removeListener(_tick);
    _animController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _state = TransformerState(
        source: PowerSource(
          dcVoltage: 0.0,
          acAmplitude: 10.0,
          frequency: 0.5,
          mode: PowerMode.dc,
        ),
        primaryCoil: CoilModel(turns: 4),
        secondaryCoil: CoilModel(turns: 4),
        primaryCircuit: CircuitModel(),
        secondaryCircuit: CircuitModel(),
        induction: InductionModel(bulbResistance: 10.0),
        pickupAreaFactor: 0.75,
        indicatorMode: IndicatorMode.bulb,
        showField: true,
        showPrimaryElectrons: true,
        showSecondaryElectrons: true,
        showCompass: false,
        showFieldMeter: false,
        lockToAxis: false,
        sourcePos: _state.sourcePos,
        bulbPos: _state.bulbPos,
        compassPos: const Offset(200, 300),
        compassAngle: 0,
        fieldMeterPos: const Offset(300, 200),
        isPaused: false,
        simulationTime: 0.0,
      );
      _primaryElectrons.reset(10);
      _secondaryElectrons.reset(10);
      _initialized = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Faraday\'s Electromagnetic Lab — Transformer'),
        backgroundColor: const Color(0xff16213e),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          // Initialize layout positions only once
          if (!_initialized) {
            _sourcePos = Offset(w * 0.18, h * 0.30);
            _primaryCenter = Offset(w * 0.18, h * 0.60);
            _secondaryCenter = Offset(w * 0.72, h * 0.60);
            _bulbPos = Offset(w * 0.72, h * 0.30);
            _initialized = true;
          }
          _state.sourcePos = _sourcePos;
          _state.bulbPos = _bulbPos;
          _state.primaryCoil.center = _primaryCenter;
          _state.secondaryCoil.center = _secondaryCenter;

          // Rebuild circuit paths every frame
          _state.primaryCircuit.buildPrimaryPath(
            sourcePos: _sourcePos,
            coilCenter: _primaryCenter,
            turns: _state.primaryCoil.turns,
          );
          _state.secondaryCircuit.buildSecondaryPath(
            coilCenter: _secondaryCenter,
            bulbPos: _bulbPos,
            turns: _state.secondaryCoil.turns,
          );

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              final pos = details.localPosition;
              // Battery drag region
              final srcRect = Rect.fromCenter(
                center: _sourcePos,
                width: TransformerGeometry.sourceW + 20,
                height: TransformerGeometry.sourceH + 20,
              );
              // Primary coil drag region
              final primaryRect = Rect.fromCenter(
                center: _primaryCenter,
                width: TransformerGeometry.coilW + 20,
                height: TransformerGeometry.coilH + 20,
              );
              // Bulb drag region
              final bulbRect = Rect.fromCenter(
                center: _bulbPos,
                width: 70,
                height: 70,
              );
              // Secondary coil drag region
              final secondaryRect = Rect.fromCenter(
                center: _secondaryCenter,
                width: TransformerGeometry.coilW + 20,
                height: TransformerGeometry.coilH + 20,
              );

              if (srcRect.contains(pos) || primaryRect.contains(pos)) {
                _isSourceDragging = true;
                _sourceDragOffset = pos - _sourcePos;
              } else if (bulbRect.contains(pos) || secondaryRect.contains(pos)) {
                _isBulbDragging = true;
                _bulbDragOffset = pos - _bulbPos;
              }
            },
            onPanUpdate: (details) {
              setState(() {
                if (_isSourceDragging) {
                  final delta = details.localPosition - _sourceDragOffset - _sourcePos;
                  _sourcePos = details.localPosition - _sourceDragOffset;
                  _primaryCenter = _primaryCenter + delta;
                  _state.sourcePos = _sourcePos;
                  _state.primaryCoil.center = _primaryCenter;
                  _state.primaryCircuit.buildPrimaryPath(
                    sourcePos: _sourcePos,
                    coilCenter: _primaryCenter,
                    turns: _state.primaryCoil.turns,
                  );
                } else if (_isBulbDragging) {
                  final delta = details.localPosition - _bulbDragOffset - _bulbPos;
                  _bulbPos = details.localPosition - _bulbDragOffset;
                  _secondaryCenter = _secondaryCenter + delta;
                  _state.bulbPos = _bulbPos;
                  _state.secondaryCoil.center = _secondaryCenter;
                  _state.secondaryCircuit.buildSecondaryPath(
                    coilCenter: _secondaryCenter,
                    bulbPos: _bulbPos,
                    turns: _state.secondaryCoil.turns,
                  );
                }
              });
            },
            onPanEnd: (_) {
              _isSourceDragging = false;
              _isBulbDragging = false;
            },
            child: Stack(
            children: [
              // Background magnetic field arrows — same PhET dipole model as magnet_and_compass
              if (_state.showField)
                CustomPaint(
                  size: Size(w, h),
                  painter: TransformerFieldPainter(
                    primaryCenter: _primaryCenter,
                    secondaryCenter: _secondaryCenter,
                    primaryCurrent: _state.primaryCircuit.current,
                    secondaryCurrent: _state.secondaryCircuit.current,
                    primaryTurns: _state.primaryCoil.turns,
                    secondaryTurns: _state.secondaryCoil.turns,
                  ),
                ),

              // Main circuit
              ClipRect(
                child: CustomPaint(
                  size: Size(w, h),
                  painter: TransformerPainter(
                    primaryCenter: _primaryCenter,
                    secondaryCenter: _secondaryCenter,
                    sourcePos: _sourcePos,
                    bulbPos: _bulbPos,
                    sourceVoltage: _state.source.voltageAt(_state.simulationTime),
                    primaryTurns: _state.primaryCoil.turns,
                    secondaryTurns: _state.secondaryCoil.turns,
                    primaryCurrent: _state.primaryCoil.current,
                    secondaryCurrent: _state.induction.current,
                    bulbBrightness: _state.induction.brightness,
                    voltmeterReading: _state.induction.voltmeterReading,
                    powerMode: _state.source.mode,
                    indicatorMode: _state.indicatorMode,
                    pickupAreaFactor: _state.pickupAreaFactor,
                  ),
                ),
              ),

              // Electrons — primary and secondary independently controlled
              if (_state.showPrimaryElectrons || _state.showSecondaryElectrons)
                CustomPaint(
                  size: Size(w, h),
                  painter: TransformerElectronPainter(
                    primaryCenter: _primaryCenter,
                    secondaryCenter: _secondaryCenter,
                    sourcePos: _sourcePos,
                    bulbPos: _bulbPos,
                    primaryElectronPositions: _primaryElectrons.positions,
                    secondaryElectronPositions: _secondaryElectrons.positions,
                    primaryTurns: _state.primaryCoil.turns,
                    secondaryTurns: _state.secondaryCoil.turns,
                    showPrimary: _state.showPrimaryElectrons,
                    showSecondary: _state.showSecondaryElectrons,
                  ),
                ),

              // Compass
              if (_state.showCompass)
                _CompassWidget(
                  center: _state.compassPos,
                  needleAngle: _state.compassAngle,
                ),

              // Field Meter
              if (_state.showFieldMeter)
                _FieldMeterWidget(
                  center: _state.fieldMeterPos,
                  magnitude: _computeFieldMagnitudeAt(_state.fieldMeterPos),
                  angleDeg: _computeFieldAngleDegAt(_state.fieldMeterPos),
                  bx: _computeBxAt(_state.fieldMeterPos),
                  by: _computeByAt(_state.fieldMeterPos),
                ),

              // ── Panels ──

              // Top-left: DC Power Supply
              Positioned(
                left: 10,
                top: 10,
                child: _buildPowerSupplyPanel(),
              ),

              // Top-right: Electromagnet Control
              Positioned(
                right: 10,
                top: 10,
                width: 200,
                child: _buildElectromagnetPanel(),
              ),

              // Right: Pickup Coil panel
              Positioned(
                right: 10,
                top: 220,
                width: 200,
                child: _buildPickupCoilPanel(),
              ),

              // Right: Tools panel
              Positioned(
                right: 10,
                top: 460,
                width: 200,
                child: _buildToolsPanel(),
              ),

              // Bottom: Pause / Reset
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildSimControls(),
              ),
            ],
            ),
          );
        },
      ),
    );
  }

  // ── Field computation helpers — use PhET dipole model ──

  Offset _computeFieldAt(Offset p) {
    final bP = MagneticFieldModel.compute(
      p: p,
      coilCenter: _primaryCenter,
      current: _state.primaryCircuit.current,
      turns: _state.primaryCoil.turns);
    final bS = MagneticFieldModel.compute(
      p: p,
      coilCenter: _secondaryCenter,
      current: _state.secondaryCircuit.current,
      turns: _state.secondaryCoil.turns);
    return Offset(bP.dx + bS.dx, bP.dy + bS.dy);
  }

  double _computeFieldMagnitudeAt(Offset p) =>
      MagneticFieldModel.magnitude(_computeFieldAt(p));
  double _computeFieldAngleDegAt(Offset p) =>
      MagneticFieldModel.fieldAngle(_computeFieldAt(p)) * 180 / pi;
  double _computeBxAt(Offset p) => _computeFieldAt(p).dx;
  double _computeByAt(Offset p) => _computeFieldAt(p).dy;

  // ── Panel builders ──

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: const Color(0xff0f3460).withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white12),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.lightBlueAccent,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _subLabel(String text) {
    return Text(text, style: const TextStyle(color: Colors.white54, fontSize: 10));
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Top-left: DC Power Supply
  Widget _buildPowerSupplyPanel() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(10),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionLabel('DC Power Supply'),
          _buildModeToggle(),
          const SizedBox(height: 8),
          if (_state.source.mode == PowerMode.dc)
            _buildDcVoltageSlider()
          else ...[
            _buildSliderRow(
              label: 'AC Amplitude',
              value: _state.source.acAmplitude,
              min: 0, max: 20,
              onChanged: (v) => setState(() => _state.source.acAmplitude = v),
            ),
            _buildSliderRow(
              label: 'AC Frequency',
              value: _state.source.frequency,
              min: 0.1, max: 2.0,
              onChanged: (v) => setState(() => _state.source.frequency = v),
            ),
          ],
          const SizedBox(height: 6),
          _infoRow('V₁', '${_state.primaryCoil.voltage.toStringAsFixed(2)} V'),
          _infoRow('I₁', '${_state.primaryCoil.current.toStringAsFixed(3)} A'),
        ],
      ),
    );
  }

  // Top-right: Electromagnet Control
  Widget _buildElectromagnetPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionLabel('Electromagnet'),
          _subLabel('Primary Coil Loops'),
          _buildLoopsControl(
            value: _state.primaryCoil.turns,
            onChanged: (v) => setState(() => _state.primaryCoil.turns = v),
          ),
          const SizedBox(height: 8),
          _infoRow('V₁', '${_state.primaryCoil.voltage.toStringAsFixed(2)} V'),
          _infoRow('I₁', '${_state.primaryCoil.current.toStringAsFixed(3)} A'),
        ],
      ),
    );
  }

  // Right: Pickup Coil panel
  Widget _buildPickupCoilPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionLabel('Pickup Coil'),
          _subLabel('Loops'),
          _buildLoopsControl(
            value: _state.secondaryCoil.turns,
            onChanged: (v) => setState(() => _state.secondaryCoil.turns = v),
          ),
          const SizedBox(height: 10),
          _subLabel('Loop Area: ${(_state.pickupAreaFactor * 100).round()}%'),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: Colors.lightBlueAccent,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: _state.pickupAreaFactor,
              min: 0.2, max: 1.0,
              onChanged: (v) => setState(() => _state.pickupAreaFactor = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('20%', style: TextStyle(color: Colors.white54, fontSize: 9)),
              Text('100%', style: TextStyle(color: Colors.white54, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 10),
          _subLabel('Indicator'),
          _buildIndicatorToggle(),
          const SizedBox(height: 8),
          _infoRow('EMF', '${_state.induction.emf.toStringAsFixed(4)} V'),
          _infoRow('I₂', '${_state.induction.current.toStringAsFixed(4)} A'),
          _infoRow('Flux', '${_state.induction.flux.toStringAsFixed(6)} Wb'),
          if (_state.indicatorMode == IndicatorMode.bulb)
            _infoRow('Brightness', '${(_state.induction.brightness * 100).round()}%'),
        ],
      ),
    );
  }

  // Right: Tools panel
  Widget _buildToolsPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionLabel('Tools'),
          _buildCheckbox('Magnetic Field', _state.showField,
              (v) => setState(() => _state.showField = v ?? false)),
          _buildCheckbox('Electrons (Primary)', _state.showPrimaryElectrons,
              (v) => setState(() => _state.showPrimaryElectrons = v ?? false)),
          _buildCheckbox('Electrons (Pickup)', _state.showSecondaryElectrons,
              (v) => setState(() => _state.showSecondaryElectrons = v ?? false)),
          _buildCheckbox('Compass', _state.showCompass,
              (v) => setState(() => _state.showCompass = v ?? false)),
          _buildCheckbox('Field Meter', _state.showFieldMeter,
              (v) => setState(() => _state.showFieldMeter = v ?? false)),
          _buildCheckbox('Lock to Axis', _state.lockToAxis,
              (v) => setState(() => _state.lockToAxis = v ?? false)),
        ],
      ),
    );
  }

  // ── UI control builders ──

  Widget _buildModeToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _state.source.mode = PowerMode.dc),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: _state.source.mode == PowerMode.dc
                    ? Colors.lightBlue : Colors.white12,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
              ),
              child: const Text('DC', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _state.source.mode = PowerMode.ac),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: _state.source.mode == PowerMode.ac
                    ? Colors.amber : Colors.white12,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
              ),
              child: const Text('AC', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _state.indicatorMode = IndicatorMode.bulb),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
              decoration: BoxDecoration(
                color: _state.indicatorMode == IndicatorMode.bulb
                    ? Colors.amber : Colors.white12,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
              ),
              child: const Text('Bulb', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _state.indicatorMode = IndicatorMode.voltmeter),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
              decoration: BoxDecoration(
                color: _state.indicatorMode == IndicatorMode.voltmeter
                    ? Colors.lightGreen : Colors.white12,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
              ),
              child: const Text('Meter', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDcVoltageSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Battery Voltage', style: TextStyle(color: Colors.white70, fontSize: 11)),
            Text(
              '${_state.source.dcVoltage.toStringAsFixed(1)} V',
              style: TextStyle(
                color: _state.source.dcVoltage >= 0 ? Colors.red : Colors.blue,
                fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('-10V', style: TextStyle(color: Colors.white54, fontSize: 9)),
            Text('0V', style: TextStyle(color: Colors.white54, fontSize: 9)),
            Text('+10V', style: TextStyle(color: Colors.white54, fontSize: 9)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: _state.source.dcVoltage >= 0 ? Colors.red : Colors.blue,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: _state.source.dcVoltage,
            min: -10, max: 10, divisions: 200,
            onChanged: (v) => setState(() => _state.source.dcVoltage = v),
          ),
        ),
      ],
    );
  }

  Widget _buildLoopsControl({required int value, required ValueChanged<int> onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: value > 1 ? () => onChanged(value - 1) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: value > 1 ? Colors.red.withValues(alpha: 0.7) : Colors.grey.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
            ),
            child: const Icon(Icons.remove, color: Colors.white, size: 16),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.symmetric(horizontal: BorderSide(color: Colors.white24)),
          ),
          child: Text('$value',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        InkWell(
          onTap: value < 10 ? () => onChanged(value + 1) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: value < 10 ? Colors.green.withValues(alpha: 0.7) : Colors.grey.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required String label, required double value,
    required double min, required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text(value.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: Colors.lightBlueAccent,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.lightBlueAccent,
          checkColor: Colors.white,
          side: const BorderSide(color: Colors.white54),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildSimControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff16213e).withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => setState(() => _state.isPaused = !_state.isPaused),
            icon: Icon(_state.isPaused ? Icons.play_arrow : Icons.pause),
            label: Text(_state.isPaused ? 'Play' : 'Pause'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _state.isPaused ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
