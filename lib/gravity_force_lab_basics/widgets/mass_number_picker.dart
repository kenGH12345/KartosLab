import 'package:flutter/material.dart';

import '../gflb_colors.dart';
import '../gflb_constants.dart';
import '../gflb_strings.dart';
import '../model/gravity_model.dart';

/// NumberPicker-style mass control (billion kg).
class MassNumberPicker extends StatelessWidget {
  const MassNumberPicker({
    super.key,
    required this.model,
    required this.which,
    required this.title,
    required this.accent,
  });

  final GravityModel model;
  final int which;
  final String title;
  final Color accent;

  double get _value => which == 1 ? model.mass1.value : model.mass2.value;

  int get _billions => (_value / GflbConstants.billionMultiplier).round();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: GflbColors.panelFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  _ArrowButton(
                    icon: Icons.arrow_drop_up,
                    color: accent,
                    onPressed: _value < GflbConstants.massMax
                        ? () => model.setMassValue(
                              which,
                              _value + GflbConstants.massStep,
                            )
                        : null,
                  ),
                  Text(
                    '$_billions',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                  _ArrowButton(
                    icon: Icons.arrow_drop_down,
                    color: accent,
                    onPressed: _value > GflbConstants.massMin
                        ? () => model.setMassValue(
                              which,
                              _value - GflbConstants.massStep,
                            )
                        : null,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              const Text(
                GflbStrings.billionKg,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      width: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 28,
        color: color,
        disabledColor: color.withValues(alpha: 0.3),
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}
