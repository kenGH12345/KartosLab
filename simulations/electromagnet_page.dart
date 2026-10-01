// Electromagnet Simulation Page
// Reuses CompassPainter from the migrated Magnet & Compass target.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'electromagnet_model.dart';
import 'electromagnet_painter.dart';
// Reuse compass painter from migrated magnet simulation
import 'package:kratos/magnetism/magnet_and_compass/painters/compass_painter.dart' show CompassPainter;

class ElectromagnetPage extends StatefulWidget {
  const ElectromagnetPage({super.key});

  @override
  State<ElectromagnetPage> createState() => _ElectromagnetPageState();
}

class _ElectromagnetPageState extends State<ElectromagnetPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ElectromagnetState _state;
  late ElectronModel _electrons;

  // Geometry
  static const double _coilW = 200.0;
  static const double _coilH = 160.0;
  static const double _coilAxisAngle = 0.0; // horizontal axis
  static const double _halfLen = 80.0;

  // Coil center in simulation canvas coordinates (set at layout)
  Offset _coilCenter = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(_tick);

    _state = ElectromagnetState(
      voltage: 1.0,
      sourceType: CurrentSourceType.dc,
      loops: 4,
      showField: true,
      showElectrons: true,
      showCompass: true,
      showFieldMeter: false,
      compassPos: const Offset(300, 400),
      compassAngle: 0.0,
      fieldMeterPos: const Offset(200, 300),
      electromagnetPos: Offset.zero,
      isPaused: false,
      simulationTime: 0.0,
    );

    _electrons = ElectronModel(positions: List.generate(12, (i) => i / 12));
  }

  void _tick() {
    if (_state.isPaused) return;
    final dt = _controller.lastElapsedDuration != null
        ? (_controller.lastElapsedDuration!.inMilliseconds / 1000.0)
        : 0.016;
    final simDt = dt.clamp(0.001, 0.05);

    final current = CurrentCalculator.compute(
      voltage: _state.voltage,
      sourceType: _state.sourceType,
      simulationTime: _state.simulationTime,
    );

    _electrons.tick(current, simDt);

    // Update compass angle based on field at compass position
    if (_state.showCompass) {
      final b = ElectromagnetField.compute(
        p: _state.compassPos,
        coilCenter: _coilCenter,
        coilAxisAngle: _coilAxisAngle,
        halfLen: _halfLen,
        current: current,
        loops: _state.loops,
      );
      final targetAngle = ElectromagnetField.fieldAngle(b);
      // Smooth rotation
      final diff = _angleDiff(_state.compassAngle, targetAngle);
      _state = _state.copyWith(
        compassAngle: _state.compassAngle + diff * 0.15,
      );
    }

    _state = _state.copyWith(
      simulationTime: _state.simulationTime + simDt,
    );
  }

  double _angleDiff(double a, double b) {
    var d = (b - a) % (2 * pi);
    if (d > pi) d -= 2 * pi;
    if (d < -pi) d += 2 * pi;
    return d;
  }

  void _reset() {
    setState(() {
      _state = ElectromagnetState(
        voltage: 1.0,
        sourceType: CurrentSourceType.dc,
        loops: 4,
        showField: true,
        showElectrons: true,
        showCompass: true,
        showFieldMeter: false,
        compassPos: Offset(_coilCenter.dx + 180, _coilCenter.dy),
        compassAngle: 0.0,
        fieldMeterPos: Offset(_coilCenter.dx - 200, _coilCenter.dy),
        electromagnetPos: _coilCenter,
        isPaused: false,
        simulationTime: 0.0,
      );
      _electrons.reset(12);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          // Place coil center in the simulation area
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          _coilCenter = Offset(w * 0.5, h * 0.55);

          // Update compass default position relative to coil
          if (_state.compassPos == const Offset(300, 400)) {
            _state = _state.copyWith(
              compassPos: Offset(_coilCenter.dx + 180, _coilCenter.dy),
              fieldMeterPos: Offset(_coilCenter.dx - 200, _coilCenter.dy),
              electromagnetPos: _coilCenter,
            );
          }

          return Stack(
            children: [
              // ── Simulation Canvas ──
              _buildSimulationCanvas(),

              // ── DC Power Supply panel (left) ──
              Positioned(
                top: 16,
                left: 16,
                child: _buildPowerSupplyPanel(),
              ),

              // ── Control Panel (right) ──
              Positioned(
                top: 16,
                right: 16,
                child: _buildControlPanel(),
              ),

              // ── Compass (draggable) ──
              if (_state.showCompass) _buildCompass(),

              // ── Field Meter (draggable) ──
              if (_state.showFieldMeter) _buildFieldMeter(),

              // ── Bottom controls: Pause/Play + Reset ──
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPlayPauseButton(),
                    const SizedBox(width: 24),
                    _buildResetButton(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Simulation Canvas
  // ─────────────────────────────────────────────
  Widget _buildSimulationCanvas() {
    final current = CurrentCalculator.compute(
      voltage: _state.voltage,
      sourceType: _state.sourceType,
      simulationTime: _state.simulationTime,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (ctx, _) {
        return RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _SimulationBackgroundPainter(
              coilCenter: _coilCenter,
              coilW: _coilW,
              coilH: _coilH,
              showField: _state.showField,
              coilAxisAngle: _coilAxisAngle,
              halfLen: _halfLen,
              current: current,
              loops: _state.loops,
              electromagnetPos: _coilCenter,
              voltage: _state.voltage,
              showElectrons: _state.showElectrons,
              electronPositions: _electrons.positions,
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  DC Power Supply Panel
  // ─────────────────────────────────────────────
  Widget _buildPowerSupplyPanel() {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffe8f0fe).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'DC Power Supply',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          // Battery Voltage display
          Row(
            children: [
              const Text('Battery Voltage:', style: TextStyle(fontSize: 12, color: Colors.black87)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  '${_state.voltage.toStringAsFixed(1)} V',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Slider with labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('-10V', style: TextStyle(fontSize: 10, color: Colors.black54)),
              Text('0V', style: TextStyle(fontSize: 10, color: Colors.black54)),
              Text('+10V', style: TextStyle(fontSize: 10, color: Colors.black54)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xff1a237e),
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: const Color(0xff311b92),
              overlayColor: const Color(0xff311b92).withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 3,
              showValueIndicator: ShowValueIndicator.onDrag,
            ),
            child: Slider(
              value: _state.voltage,
              min: -10,
              max: 10,
              divisions: 200,
              label: '${_state.voltage.toStringAsFixed(1)}V',
              onChanged: (v) => setState(() => _state = _state.copyWith(voltage: v)),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Control Panel (right)
  // ─────────────────────────────────────────────
  Widget _buildControlPanel() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffe8f0fe).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Electromagnet',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          // Current Source: DC / AC
          const Text('Current Source', style: TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildSourceButton('DC', CurrentSourceType.dc),
              const SizedBox(width: 8),
              _buildSourceButton('AC', CurrentSourceType.ac),
            ],
          ),
          const SizedBox(height: 12),
          // Loops control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Loops:', style: TextStyle(fontSize: 12, color: Colors.black87)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: _state.loops > 1
                        ? () => setState(() => _state = _state.copyWith(loops: _state.loops - 1))
                        : null,
                    iconSize: 20,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '${_state.loops}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: _state.loops < 10
                        ? () => setState(() => _state = _state.copyWith(loops: _state.loops + 1))
                        : null,
                    iconSize: 20,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 8),
          // Checkboxes
          _buildCheckbox('Magnetic Field (B)', _state.showField,
              (v) => setState(() => _state = _state.copyWith(showField: v ?? false))),
          _buildCheckbox('Electrons', _state.showElectrons,
              (v) => setState(() => _state = _state.copyWith(showElectrons: v ?? false))),
          _buildCheckbox('Compass', _state.showCompass,
              (v) => setState(() => _state = _state.copyWith(showCompass: v ?? false))),
          _buildCheckbox('Field Meter', _state.showFieldMeter,
              (v) => setState(() => _state = _state.copyWith(showFieldMeter: v ?? false))),
        ],
      ),
    );
  }

  Widget _buildSourceButton(String label, CurrentSourceType type) {
    final selected = _state.sourceType == type;
    return GestureDetector(
      onTap: () => setState(() => _state = _state.copyWith(sourceType: type)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff1a237e) : Colors.white,
          border: Border.all(color: selected ? const Color(0xff1a237e) : Colors.grey),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xff1a237e),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Compass
  // ─────────────────────────────────────────────
  Widget _buildCompass() {
    return Positioned(
      left: _state.compassPos.dx - 45,
      top: _state.compassPos.dy - 45,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            _state = _state.copyWith(
              compassPos: _state.compassPos + d.delta,
            );
          });
        },
        child: SizedBox(
          width: 90,
          height: 90,
          child: CustomPaint(
            painter: CompassPainter(
              needleAngle: _state.compassAngle,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Field Meter
  // ─────────────────────────────────────────────
  Widget _buildFieldMeter() {
    final current = CurrentCalculator.compute(
      voltage: _state.voltage,
      sourceType: _state.sourceType,
      simulationTime: _state.simulationTime,
    );
    final b = ElectromagnetField.compute(
      p: _state.fieldMeterPos,
      coilCenter: _coilCenter,
      coilAxisAngle: _coilAxisAngle,
      halfLen: _halfLen,
      current: current,
      loops: _state.loops,
    );
    final mag = ElectromagnetField.magnitude(b);
    final angle = ElectromagnetField.fieldAngle(b) * 180 / pi;

    return Positioned(
      left: _state.fieldMeterPos.dx - 70,
      top: _state.fieldMeterPos.dy - 50,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            _state = _state.copyWith(
              fieldMeterPos: _state.fieldMeterPos + d.delta,
            );
          });
        },
        child: SizedBox(
          width: 140,
          height: 100,
          child: CustomPaint(
            painter: FieldMeterPainter(
              magnitude: mag,
              angleDeg: angle,
              bx: b.dx,
              by: b.dy,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Play/Pause and Reset buttons
  // ─────────────────────────────────────────────
  Widget _buildPlayPauseButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffe8f0fe).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_state.isPaused ? Icons.play_arrow : Icons.pause, size: 28),
            color: const Color(0xff1a237e),
            onPressed: () => setState(() => _state = _state.copyWith(isPaused: !_state.isPaused)),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffe8f0fe).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2))],
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh, size: 24),
        color: const Color(0xff1a237e),
        onPressed: _reset,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Unified Simulation Background Painter
//  Combines: field arrows + electromagnet + electrons
// ─────────────────────────────────────────────
class _SimulationBackgroundPainter extends CustomPainter {
  final Offset coilCenter;
  final double coilW;
  final double coilH;
  final bool showField;
  final double coilAxisAngle;
  final double halfLen;
  final double current;
  final int loops;
  final Offset electromagnetPos;
  final double voltage;
  final bool showElectrons;
  final List<double> electronPositions;

  const _SimulationBackgroundPainter({
    required this.coilCenter,
    required this.coilW,
    required this.coilH,
    required this.showField,
    required this.coilAxisAngle,
    required this.halfLen,
    required this.current,
    required this.loops,
    required this.electromagnetPos,
    required this.voltage,
    required this.showElectrons,
    required this.electronPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Background field arrows
    if (showField) {
      _drawFieldArrows(canvas, size);
    }

    // 2. Electromagnet (battery + wires + coil)
    _drawElectromagnet(canvas);

    // 3. Electrons
    if (showElectrons) {
      _drawElectrons(canvas);
    }
  }

  void _drawFieldArrows(Canvas canvas, Size size) {
    final cols = 34;
    final rows = 19;
    final cw = size.width / cols;
    final ch = size.height / rows;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final px = (col + 0.5) * cw;
        final py = (row + 0.5) * ch;
        final p = Offset(px, py);

        // Skip inside coil area
        final d = p - coilCenter;
        if (d.dx.abs() < coilW / 2 + 10 && d.dy.abs() < coilH / 2 + 10) continue;

        final b = ElectromagnetField.compute(
          p: p,
          coilCenter: coilCenter,
          coilAxisAngle: coilAxisAngle,
          halfLen: halfLen,
          current: current,
          loops: loops,
        );
        final mag = ElectromagnetField.magnitude(b);
        if (mag < 1e-6) continue;

        final angle = ElectromagnetField.fieldAngle(b);
        final len = (log(1 + mag * 0.28) * 100).clamp(8.0, 36.0).toDouble();
        _drawNeedle(canvas, p, angle, len);
      }
    }
  }

  void _drawNeedle(Canvas canvas, Offset c, double angle, double len) {
    final half = len / 2;
    final hw = (len / 18.0 * 5.6).clamp(3.0, 5.6);
    final ca = cos(angle);
    final sa = sin(angle);
    final cp = cos(angle + pi / 2);
    final sp = sin(angle + pi / 2);

    final head = Offset(c.dx + ca * half, c.dy + sa * half);
    final tail = Offset(c.dx - ca * half, c.dy - sa * half);
    final left = Offset(c.dx + cp * hw, c.dy + sp * hw);
    final right = Offset(c.dx - cp * hw, c.dy - sp * hw);

    canvas.drawPath(
      Path()..moveTo(tail.dx, tail.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = const Color(0xffcccccc)..style = PaintingStyle.fill);
    canvas.drawPath(
      Path()..moveTo(head.dx, head.dy)..lineTo(left.dx, left.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = const Color(0xffcc2222)..style = PaintingStyle.fill);
    canvas.drawPath(
      Path()..moveTo(head.dx, head.dy)..lineTo(left.dx, left.dy)..lineTo(tail.dx, tail.dy)..lineTo(right.dx, right.dy)..close(),
      Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 0.3);
  }

  void _drawElectromagnet(Canvas canvas) {
    // Use the dedicated painter for battery + wires + coil
    final painter = ElectromagnetPainter(
      center: coilCenter,
      voltage: voltage,
      loops: loops,
      current: current,
    );
    painter.paint(canvas, Size.infinite);
  }

  void _drawElectrons(Canvas canvas) {
    final painter = ElectronPainter(
      center: coilCenter,
      positions: electronPositions,
      current: current,
      loops: loops,
    );
    painter.paint(canvas, Size.infinite);
  }

  @override
  bool shouldRepaint(_SimulationBackgroundPainter old) => true;
}
