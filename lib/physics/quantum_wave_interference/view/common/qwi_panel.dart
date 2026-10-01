import 'package:flutter/material.dart';

import 'qwi_colors.dart';

/// PhET `Panel` chrome — fill `#f4f4f4`, stroke `#c1c1c1`, cornerRadius 6.
class QwiPanel extends StatelessWidget {
  const QwiPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsets padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: QwiColors.panelFill,
        border: Border.all(color: QwiColors.panelStroke),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

/// Rectangular push button approximating Sun `RectangularPushButton`.
class QwiPushButton extends StatelessWidget {
  const QwiPushButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.baseColor = QwiColors.snapshotButtonBase,
    this.minWidth = 72,
    this.minHeight = 28,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final Color baseColor;
  final double minWidth;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onPressed != null;
    return Semantics(
      button: true,
      enabled: active,
      label: label,
      child: Material(
        color: active ? baseColor : const Color(0xFFDDDDDD),
        borderRadius: BorderRadius.circular(4),
        elevation: active ? 1 : 0,
        child: InkWell(
          onTap: active ? onPressed : null,
          borderRadius: BorderRadius.circular(4),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.black87 : Colors.black38,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
