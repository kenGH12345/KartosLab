import 'package:flutter/material.dart';

import '../controller/masb_controller.dart';
import '../masb_constants.dart';
import '../model/masb_model.dart';

/// Bounce right stack: Spring Constant + Gravity + LineOptions.
class BounceRightPanel extends StatelessWidget {
  const BounceRightPanel({super.key, required this.controller});

  final MasbController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final m = controller.model;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (m.scene != MasbScene.stretch) ...[
              _GravityPanel(controller: controller, model: m),
              const SizedBox(height: 8),
            ],
            if (m.scene == MasbScene.lab) ...[
              _MassValuePanel(controller: controller, model: m),
              const SizedBox(height: 8),
              _VectorOptionsPanel(controller: controller, model: m),
              const SizedBox(height: 8),
            ],
            _LineOptionsPanel(controller: controller, model: m),
          ],
        );
      },
    );
  }
}

class _GravityPanel extends StatelessWidget {
  const _GravityPanel({required this.controller, required this.model});
  final MasbController controller;
  final MasbModel model;

  @override
  Widget build(BuildContext context) {
    final g = model.gravity;
    return Material(
      color: const Color(0xFFEEEEEE),
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Gravity',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            Text('${g.toStringAsFixed(1)} m/s²',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
            DropdownButton<MasbBody>(
              isExpanded: true,
              value: model.body == MasbBody.custom ? MasbBody.custom : model.body,
              items: const [
                DropdownMenuItem(value: MasbBody.earth, child: Text('Earth')),
                DropdownMenuItem(value: MasbBody.moon, child: Text('Moon')),
                DropdownMenuItem(value: MasbBody.jupiter, child: Text('Jupiter')),
                DropdownMenuItem(value: MasbBody.planetX, child: Text('Planet X')),
                DropdownMenuItem(value: MasbBody.custom, child: Text('Custom')),
              ],
              onChanged: (b) {
                if (b != null) controller.setBody(b);
              },
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                activeTrackColor: const Color(0xFF00C4DF),
                inactiveTrackColor: Colors.grey.shade400,
                thumbColor: const Color(0xFF00C4DF),
              ),
              child: Slider(
                value: g.clamp(MasbConstants.gravityMin, MasbConstants.gravityMax),
                min: MasbConstants.gravityMin,
                max: MasbConstants.gravityMax,
                onChanged: controller.setGravity,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('None', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                Text('Lots', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LineOptionsPanel extends StatelessWidget {
  const _LineOptionsPanel({required this.controller, required this.model});
  final MasbController controller;
  final MasbModel model;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEEEEE),
      borderRadius: BorderRadius.circular(5),
      child: Column(
        children: [
          CheckboxListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text('Unstretched Length', style: TextStyle(fontSize: 12)),
            secondary: const _LineSwatch(Color(0xFF4142E8)),
            value: model.naturalLengthVisible,
            onChanged: (v) => controller.setNaturalLengthVisible(v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text('Resting Position', style: TextStyle(fontSize: 12)),
            secondary: const _LineSwatch(Color(0xFF00B400)),
            value: model.equilibriumPositionVisible,
            onChanged: (v) =>
                controller.setEquilibriumPositionVisible(v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text('Movable Line', style: TextStyle(fontSize: 12)),
            secondary: const _LineSwatch(Color(0xFFFF0000)),
            value: model.movableLineVisible,
            onChanged: (v) => controller.setMovableLineVisible(v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}

class _MassValuePanel extends StatelessWidget {
  const _MassValuePanel({required this.controller, required this.model});
  final MasbController controller;
  final MasbModel model;

  @override
  Widget build(BuildContext context) {
    final attached = model.spring.massAttached;
    final enabled = attached != null && attached.adjustable;
    final kg = enabled ? attached.massKg : 0.100;
    return Material(
      color: const Color(0xFFEEEEEE),
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              enabled
                  ? 'Mass ${(kg * 1000).round()} g'
                  : 'Mass (attach adjustable)',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                activeTrackColor: const Color(0xFF00C4DF),
                inactiveTrackColor: Colors.grey.shade400,
                thumbColor: const Color(0xFF00C4DF),
              ),
              child: Slider(
                value: kg.clamp(0.05, 0.30),
                min: 0.05,
                max: 0.30,
                onChanged: enabled ? controller.setAttachedMassKg : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VectorOptionsPanel extends StatelessWidget {
  const _VectorOptionsPanel({required this.controller, required this.model});
  final MasbController controller;
  final MasbModel model;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEEEEE),
      borderRadius: BorderRadius.circular(5),
      child: Column(
        children: [
          CheckboxListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text('Period Trace', style: TextStyle(fontSize: 12)),
            value: model.spring.periodTraceVisible,
            onChanged: (v) => controller.setPeriodTraceVisible(v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text('Velocity', style: TextStyle(fontSize: 12)),
            value: model.velocityVectorVisible,
            onChanged: (v) => controller.setVelocityVectorVisible(v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: const Text('Acceleration', style: TextStyle(fontSize: 12)),
            value: model.accelerationVectorVisible,
            onChanged: (v) =>
                controller.setAccelerationVectorVisible(v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}

class _LineSwatch extends StatelessWidget {
  const _LineSwatch(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      child: CustomPaint(
        painter: _DashPainter(color),
        size: const Size(22, 2),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2;
    const dash = 4.0;
    const gap = 2.5;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2),
          Offset(mathMin(x + dash, size.width), size.height / 2), p);
      x += dash + gap;
    }
  }

  double mathMin(double a, double b) => a < b ? a : b;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
