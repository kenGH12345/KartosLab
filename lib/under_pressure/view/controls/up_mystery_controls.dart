import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';
import 'package:kratos/under_pressure/under_pressure_strings.dart';

/// Source: `MysteryPoolView` choice panel + sun `ComboBox`.
class UpMysteryControls extends StatelessWidget {
  const UpMysteryControls({
    super.key,
    required this.controller,
    required this.panelLeft,
    required this.panelTop,
    required this.panelWidth,
    required this.comboRight,
    required this.comboTop,
  });

  final UnderPressureController controller;
  final double panelLeft;
  final double panelTop;
  final double panelWidth;
  final double comboRight;
  final double comboTop;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final mystery = m.mystery;
    final choice = m.mysteryChoice;

    return Stack(
      children: [
        Positioned(
          left: panelLeft,
          top: panelTop,
          width: panelWidth,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2FA6A),
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Radio(
                  selected: choice == 'fluidDensity',
                  label: UnderPressureStrings.mysteryFluid,
                  onTap: () => controller.setMysteryChoice('fluidDensity'),
                ),
                const SizedBox(height: 5),
                _Radio(
                  selected: choice == 'gravity',
                  label: UnderPressureStrings.mysteryPlanet,
                  onTap: () => controller.setMysteryChoice('gravity'),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: UpMvt.layoutWidth - comboRight,
          top: comboTop,
          child: choice == 'fluidDensity'
              ? _MysteryCombo(
                  value: mystery.customFluidDensityIndex,
                  items: const [UnderPressureStrings.fluidA, UnderPressureStrings.fluidB, UnderPressureStrings.fluidC],
                  onChanged: controller.setMysteryFluidIndex,
                )
              : _MysteryCombo(
                  value: mystery.customGravityIndex,
                  items: const [UnderPressureStrings.planetA, UnderPressureStrings.planetB, UnderPressureStrings.planetC],
                  onChanged: controller.setMysteryGravityIndex,
                ),
        ),
      ],
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 1.5),
              color: selected ? const Color(0xFF2196F3) : Colors.white,
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

/// Source sun ComboBox — button + open list with highlightFill rgb(218,255,255).
class _MysteryCombo extends StatefulWidget {
  const _MysteryCombo({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final int value;
  final List<String> items;
  final ValueChanged<int> onChanged;

  @override
  State<_MysteryCombo> createState() => _MysteryComboState();
}

class _MysteryComboState extends State<_MysteryCombo> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final idx = widget.value.clamp(0, widget.items.length - 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          elevation: _open ? 2 : 0,
          child: InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(minWidth: 100),
              padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.items[idx],
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  CustomPaint(
                    size: const Size(10, 6),
                    painter: _CaretPainter(up: _open),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_open)
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < widget.items.length; i++)
                    InkWell(
                      onTap: () {
                        widget.onChanged(i);
                        setState(() => _open = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        color: i == idx
                            ? const Color.fromRGBO(218, 255, 255, 1)
                            : null,
                        child: Text(
                          widget.items[i],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CaretPainter extends CustomPainter {
  _CaretPainter({this.up = false});

  final bool up;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (up) {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width / 2, 0)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(covariant _CaretPainter old) => old.up != up;
}
