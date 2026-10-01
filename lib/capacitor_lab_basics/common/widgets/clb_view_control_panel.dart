import 'package:flutter/material.dart';

import '../../clb_colors.dart';
import '../../clb_strings.dart';
import '../model/clb_model.dart';

/// View options — `CLBViewControlPanel.js`
///
/// Fill rgb(255,245,237); rightTop = (1024−10, 10).
class ClbViewControlPanel extends StatelessWidget {
  const ClbViewControlPanel({
    super.key,
    required this.model,
  });

  final ClbModel model;

  static const double minWidth = 175;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        return Material(
          color: ClbColors.meterPanelFill,
          elevation: 2,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            constraints: const BoxConstraints(minWidth: minWidth),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _check(
                  ClbStrings.plateCharges,
                  model.plateChargesVisible,
                  model.setPlateChargesVisible,
                ),
                _check(
                  ClbStrings.barGraphs,
                  model.barGraphsVisible,
                  model.setBarGraphsVisible,
                ),
                _check(
                  ClbStrings.electricField,
                  model.electricFieldVisible,
                  model.setElectricFieldVisible,
                ),
                _check(
                  ClbStrings.currentDirection,
                  model.currentVisible,
                  model.setCurrentVisible,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _radio(
                        ClbStrings.electrons,
                        selected: model.currentOrientation == 0,
                        enabled: model.currentVisible,
                        onTap: () => model.setCurrentOrientation(0),
                      ),
                      _radio(
                        ClbStrings.conventional,
                        selected: model.currentOrientation != 0,
                        enabled: model.currentVisible,
                        onTap: () => model.setCurrentOrientation(3.141592653589793),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _check(String label, bool value, void Function(bool) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87, width: 1.5),
                  color: value ? const Color(0xFF4A90D9) : Colors.white,
                ),
                child: value
                    ? const CustomPaint(painter: _CheckMarkPainter())
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _radio(
    String label, {
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black87, width: 1.5),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF4A90D9),
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckMarkPainter extends CustomPainter {
  const _CheckMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.55)
      ..lineTo(size.width * 0.42, size.height * 0.75)
      ..lineTo(size.width * 0.8, size.height * 0.28);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
