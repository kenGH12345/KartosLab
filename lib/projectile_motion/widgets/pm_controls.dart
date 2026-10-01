import 'package:flutter/material.dart';

import '../pm_colors.dart';
import '../pm_constants.dart';

/// PhET Panel 容器（Constants:143-158）
class PmPanel extends StatelessWidget {
  const PmPanel({
    super.key,
    required this.child,
    this.fill = PmColors.rightSidePanelFill,
    this.minWidth = 260,
    this.padding = const EdgeInsets.all(10),
  });

  final Widget child;
  final Color fill;
  final double minWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

/// PhET NumberControl：标题 + [左箭头][slider+数值框][右箭头]。
class PmNumberControl extends StatelessWidget {
  const PmNumberControl({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.delta,
    required this.decimals,
    required this.unit,
    required this.onChanged,
    this.enabled = true,
    this.trailing,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final double delta;
  final int decimals;
  final String unit;
  final ValueChanged<double> onChanged;
  final bool enabled;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final effectiveValue = value.clamp(min, max);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row1：[title] [valueDisplay]（PhET NumberControl 默认布局，
            // 自然宽度，避免测试环境 Ahem 字体下过宽溢出）
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: PmConstants.uiText
                        .copyWith(fontWeight: FontWeight.bold)),
                if (trailing != null) ...[
                  const SizedBox(width: 4),
                  trailing!,
                ],
                const SizedBox(width: 8),
                PmNumberDisplay(
                    value: effectiveValue, decimals: decimals, unit: unit),
              ],
            ),
            const SizedBox(height: 2),
            // Row2：[◀][slider 120×0.5][▶]（ScreenView:186-192）
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TweakerButton(
                    up: false,
                    onTap: () => onChanged(effectiveValue - delta)),
                SizedBox(
                  width: 120,
                  height: 22,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 0.5,
                      activeTrackColor: Colors.black,
                      inactiveTrackColor: Colors.black,
                      overlayColor: Colors.transparent,
                      thumbShape: const _PhetThumbShape(),
                    ),
                    child: Slider(
                      value: effectiveValue,
                      min: min,
                      max: max,
                      onChanged: onChanged,
                    ),
                  ),
                ),
                _TweakerButton(
                    up: true, onTap: () => onChanged(effectiveValue + delta)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 原版 slider thumb：13×22 白底黑边竖向圆角矩形（thumbSize Dimension2(13,22)）
class _PhetThumbShape extends SliderComponentShape {
  const _PhetThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(13, 22);

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final rect = Rect.fromCenter(center: center, width: 13, height: 22);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    context.canvas.drawRRect(rrect, Paint()..color = const Color(0xFFF0F0F0));
    context.canvas.drawRRect(
        rrect,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }
}

/// PhET NumberDisplay：白底灰边右对齐（Constants:173-179）
class PmNumberDisplay extends StatelessWidget {
  const PmNumberDisplay({
    super.key,
    required this.value,
    required this.decimals,
    required this.unit,
  });

  final double value;
  final int decimals;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 60),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: PmColors.numberDisplayBackground,
        border: Border.all(color: PmColors.numberDisplayStroke),
      ),
      child: Text(
        '${value.toStringAsFixed(decimals)} $unit',
        textAlign: TextAlign.right,
        style: PmConstants.uiText,
      ),
    );
  }
}

class _TweakerButton extends StatelessWidget {
  const _TweakerButton({required this.up, required this.onTap});

  final bool up;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 16,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(3),
        ),
        child: CustomPaint(
          painter: _TrianglePainter(up: up),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.up});

  final bool up;

  @override
  void paint(Canvas canvas, Size size) {
    final path = up
        ? (Path()
          ..moveTo(size.width / 2, 4)
          ..lineTo(size.width - 4, size.height - 5)
          ..lineTo(4, size.height - 5)
          ..close())
        : (Path()
          ..moveTo(4, 5)
          ..lineTo(size.width - 4, 5)
          ..lineTo(size.width / 2, size.height - 4)
          ..close());
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => false;
}

/// PhET checkbox 勾（自绘，禁用 Material 图标冒充）
class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
        Path()
          ..moveTo(size.width * 0.15, size.height * 0.55)
          ..lineTo(size.width * 0.4, size.height * 0.8)
          ..lineTo(size.width * 0.85, size.height * 0.2),
        paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => false;
}

class _DownTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
        Path()
          ..moveTo(1, 1)
          ..lineTo(size.width - 1, 1)
          ..lineTo(size.width / 2, size.height - 1)
          ..close(),
        Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(_DownTrianglePainter oldDelegate) => false;
}

/// PhET Checkbox：白底黑框黑勾 + 标签
class PmCheckbox extends StatelessWidget {
  const PmCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(2),
            ),
            child: value
                ? CustomPaint(painter: _CheckPainter())
                : null,
          ),
          const SizedBox(width: 6),
          Text(label, style: PmConstants.uiText),
          if (icon != null) ...[const SizedBox(width: 4), icon!],
        ],
      ),
    );
  }
}

/// PhET AquaRadioButton 风格单选
class PmRadioRow<T> extends StatelessWidget {
  const PmRadioRow({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black54),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8F4FF), Color(0xFF9CC8E8)],
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFF2266AA)),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(label, style: PmConstants.uiText),
        ],
      ),
    );
  }
}

/// PhET ComboBox：白底黑边按钮 + 自绘下三角 + Overlay 列表
///（不用 Material DropdownButton —— 其 ink splash/chrome 非原版观感）
class PmComboBox<T> extends StatelessWidget {
  const PmComboBox({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final box = context.findRenderObject()! as RenderBox;
        final overlay =
            Overlay.of(context).context.findRenderObject()! as RenderBox;
        final rect = Rect.fromPoints(
          box.localToGlobal(Offset.zero, ancestor: overlay),
          box.localToGlobal(box.size.bottomRight(Offset.zero),
              ancestor: overlay),
        );
        final selected = await showMenu<T>(
          context: context,
          position: RelativeRect.fromRect(rect, Offset.zero & overlay.size),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(2),
          ),
          items: [
            for (final item in items)
              PopupMenuItem<T>(
                value: item,
                height: 28,
                child: Text(itemLabel(item), style: PmConstants.uiText),
              ),
          ],
        );
        if (selected != null) onChanged(selected);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(4),
        ),
      child: SizedBox(
        width: 220,
        child: Row(
          children: [
            Expanded(
              child: Text(itemLabel(value),
                  style: PmConstants.uiText,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            CustomPaint(
                size: const Size(12, 8), painter: _DownTrianglePainter()),
          ],
        ),
      ),
      ),
    );
  }
}
