import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/gas_simulation_controller.dart';
import '../gas_properties_colors.dart';
import '../model/hold_constant.dart';
import '../model/ideal_gas_law_model.dart';
import '../model/particle_type.dart';
import '../painters/ideal_instruments_painters.dart';

/// PhET AccordionBox-style dark panel.
class IdealPanelChrome extends StatelessWidget {
  const IdealPanelChrome({
    super.key,
    required this.title,
    required this.child,
    this.expanded = true,
    this.onToggle,
  });

  final String title;
  final Widget child;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(GasPropertiesColors.panelFill),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(GasPropertiesColors.panelStroke)),
        ),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: expanded
                          ? const Color(0xFFF97316)
                          : const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      expanded ? '−' : '+',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 10),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

/// FineCoarseSpinner row: ≪ < [n] > ≫
class IdealParticleSpinner extends StatelessWidget {
  const IdealParticleSpinner({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
    this.max = 1000,
  });

  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.35),
                    blurRadius: 2,
                    offset: const Offset(-1, -1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _spinBtn('≪', () => onChanged((value - 50).clamp(0, max))),
            const SizedBox(width: 2),
            _spinBtn('◀', () => onChanged((value - 1).clamp(0, max))),
            const SizedBox(width: 3),
            Container(
              width: 40,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF9CA3AF)),
              ),
              child: Text(
                '$value',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 3),
            _spinBtn('▶', () => onChanged((value + 1).clamp(0, max))),
            const SizedBox(width: 2),
            _spinBtn('≫', () => onChanged((value + 50).clamp(0, max))),
          ],
        ),
      ],
    );
  }

  Widget _spinBtn(String label, VoidCallback onFire) {
    return _HoldRepeatButton(label: label, onFire: onFire);
  }
}

/// PhET ArrowButton defaults: fireOnHoldDelay 400ms, interval 100ms.
class _HoldRepeatButton extends StatefulWidget {
  const _HoldRepeatButton({required this.label, required this.onFire});
  final String label;
  final VoidCallback onFire;

  @override
  State<_HoldRepeatButton> createState() => _HoldRepeatButtonState();
}

class _HoldRepeatButtonState extends State<_HoldRepeatButton> {
  Timer? _delay;
  Timer? _repeat;

  void _start() {
    widget.onFire();
    _delay?.cancel();
    _repeat?.cancel();
    _delay = Timer(const Duration(milliseconds: 400), () {
      _repeat = Timer.periodic(const Duration(milliseconds: 100), (_) {
        widget.onFire();
      });
    });
  }

  void _stop() {
    _delay?.cancel();
    _repeat?.cancel();
    _delay = null;
    _repeat = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF3F3F46),
      borderRadius: BorderRadius.circular(4),
      child: Listener(
        onPointerDown: (_) => _start(),
        onPointerUp: (_) => _stop(),
        onPointerCancel: (_) => _stop(),
        child: SizedBox(
          width: 24,
          height: 26,
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }
}

class IdealParticlesPanel extends StatelessWidget {
  const IdealParticlesPanel({super.key, required this.controller});
  final GasSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final h = controller.model.particleSystem.numberOfHeavy;
    final l = controller.model.particleSystem.numberOfLight;
    final energy = controller.profile == IdealGasProfile.energy;
    return IdealPanelChrome(
      title: 'Particles',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IdealParticleSpinner(
            label: 'Heavy',
            value: h,
            color: const Color(GasPropertiesColors.heavyParticle),
            onChanged: controller.setNumberHeavy,
          ),
          const SizedBox(height: 12),
          IdealParticleSpinner(
            label: 'Light',
            value: l,
            color: const Color(GasPropertiesColors.lightParticle),
            onChanged: controller.setNumberLight,
          ),
          if (energy) ...[
            const SizedBox(height: 10),
            IdealCheckRow(
              label: 'Collisions',
              value: controller.model.particleCollisionsEnabled,
              onChanged: controller.setParticleCollisionsEnabled,
            ),
          ],
        ],
      ),
    );
  }
}

class IdealHoldConstantPanel extends StatelessWidget {
  const IdealHoldConstantPanel({super.key, required this.controller});
  final GasSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final mode = controller.model.holdConstant;
    final n = controller.model.numberOfParticles;
    final open = controller.model.container.isOpen;
    final p = controller.model.pressureKpa;
    return IdealPanelChrome(
      title: 'Hold Constant',
      child: Column(
        children: [
          for (final e in HoldConstant.values)
            _radioRow(
              e,
              mode == e,
              _enabled(e, n, open, p),
              () => controller.setHoldConstant(e),
            ),
        ],
      ),
    );
  }

  Widget _radioRow(
    HoldConstant e,
    bool selected,
    bool enabled,
    VoidCallback onTap,
  ) {
    final color = !enabled
        ? Colors.white24
        : selected
            ? const Color(0xFF38BDF8)
            : Colors.white70;
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _label(e),
                style: TextStyle(color: color, fontSize: 12.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(HoldConstant e) => switch (e) {
        HoldConstant.nothing => 'Nothing',
        HoldConstant.volume => 'Volume (V)',
        HoldConstant.temperature => 'Temperature (T)',
        HoldConstant.pressureV => 'Pressure ↕V',
        HoldConstant.pressureT => 'Pressure ↕T',
      };

  bool _enabled(HoldConstant e, int n, bool open, double p) {
    if (e == HoldConstant.temperature) return n != 0 && !open;
    if (e == HoldConstant.pressureV || e == HoldConstant.pressureT) {
      return p != 0;
    }
    return true;
  }
}

class IdealToolsPanel extends StatelessWidget {
  const IdealToolsPanel({super.key, required this.controller});
  final GasSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final explore = controller.profile == IdealGasProfile.explore;
    final showCollision = controller.profile != IdealGasProfile.energy;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: const Color(GasPropertiesColors.panelFill),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(GasPropertiesColors.panelStroke)),
      ),
      child: Column(
        children: [
          IdealCheckRow(
            label: 'Width',
            value: controller.widthVisible,
            onChanged: controller.setWidthVisible,
            trailing: CustomPaint(
              size: const Size(28, 14),
              painter: _WidthToolIconPainter(),
            ),
          ),
          if (explore)
            IdealCheckRow(
              label: 'Wall Velocity',
              value: controller.wallVelocityVisible,
              onChanged: controller.setWallVelocityVisible,
            ),
          IdealCheckRow(
            label: 'Stopwatch',
            value: controller.stopwatchVisible,
            onChanged: controller.setStopwatchVisible,
            trailing: Container(
              width: 26,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(GasPropertiesColors.stopwatchBg),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.white54),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 12,
                height: 3,
                color: Colors.white70,
              ),
            ),
          ),
          if (showCollision)
            IdealCheckRow(
              label: 'Collision Counter',
              value: controller.collisionCounterVisible,
              onChanged: controller.setCollisionCounterVisible,
              trailing: Container(
                width: 22,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(GasPropertiesColors.collisionCounterBg),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          IdealCheckRow(
            label: 'Pressure Noise',
            value: controller.model.pressureSolver.pressureNoiseEnabled,
            onChanged: controller.setPressureNoiseEnabled,
          ),
        ],
      ),
    );
  }
}

class _WidthToolIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    // vertical bars
    canvas.drawLine(Offset(2, 1), Offset(2, size.height - 1), p);
    canvas.drawLine(
      Offset(size.width - 2, 1),
      Offset(size.width - 2, size.height - 1),
      p,
    );
    // dashed midline
    final y = size.height / 2;
    const dash = 3.0;
    var x = 5.0;
    while (x < size.width - 5) {
      canvas.drawLine(Offset(x, y), Offset(x + dash * 0.6, y), p);
      x += dash;
    }
    // arrow heads
    final midY = size.height / 2;
    canvas.drawLine(Offset(5, midY), Offset(8, midY - 3), p);
    canvas.drawLine(Offset(5, midY), Offset(8, midY + 3), p);
    canvas.drawLine(
      Offset(size.width - 5, midY),
      Offset(size.width - 8, midY - 3),
      p,
    );
    canvas.drawLine(
      Offset(size.width - 5, midY),
      Offset(size.width - 8, midY + 3),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IdealCheckRow extends StatelessWidget {
  const IdealCheckRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.trailing,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: value
                      ? const Color(GasPropertiesColors.accent)
                      : Colors.white54,
                  width: 1.5,
                ),
                color: value
                    ? const Color(GasPropertiesColors.accent)
                    : Colors.transparent,
              ),
              child: value
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12.5),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class IdealPhETCircleButton extends StatelessWidget {
  const IdealPhETCircleButton({
    super.key,
    required this.size,
    required this.color,
    required this.icon,
    required this.onTap,
    this.iconSize,
  });

  final double size;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: PhETCircleButtonPainter(fill: color, icon: icon),
            ),
            Icon(icon, color: Colors.white, size: iconSize ?? size * 0.48),
          ],
        ),
      ),
    );
  }
}

class IdealParticleTypeSelector extends StatelessWidget {
  const IdealParticleTypeSelector({super.key, required this.controller});
  final GasSimulationController controller;

  @override
  Widget build(BuildContext context) {
    final heavy = controller.model.particleType == ParticleType.heavy;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _square(true, heavy),
        const SizedBox(width: 6),
        _square(false, !heavy),
      ],
    );
  }

  Widget _square(bool heavy, bool selected) {
    return GestureDetector(
      onTap: () => controller.setParticleType(
        heavy ? ParticleType.heavy : ParticleType.light,
      ),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? const Color(0xFF7DD3FC)
                : const Color(0xFF6B7280),
            width: selected ? 2.5 : 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          width: heavy ? 16 : 12,
          height: heavy ? 16 : 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(
              heavy
                  ? GasPropertiesColors.heavyParticle
                  : GasPropertiesColors.lightParticle,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.35),
                blurRadius: 2,
                offset: const Offset(-1, -1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
