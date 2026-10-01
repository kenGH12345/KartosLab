import 'package:flutter/material.dart';

import '../model/real_molecules/real_molecules_model.dart';
import '../mp_colors.dart';
import '../mp_constants.dart';
import '../mp_strings.dart';
import '../painters/mp_scene_painters.dart';

class MpPanel extends StatelessWidget {
  const MpPanel({
    super.key,
    required this.child,
    this.width,
    this.fill,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final double? width;
  final Color? fill;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: fill ?? MpColors.panelFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBBBBBB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 3,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MpCheckbox extends StatelessWidget {
  const MpCheckbox({
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
            CustomPaint(
              size: const Size(18, 18),
              painter: _PhetCheckboxPainter(checked: value),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 18, fontFamily: 'Arial'),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10), // MPConstants.CONTROL_ICON_X_SPACING
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// PhET sun Checkbox look: white fill, black border, black check (no Material).
class _PhetCheckboxPainter extends CustomPainter {
  _PhetCheckboxPainter({required this.checked});

  final bool checked;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      const Radius.circular(2),
    );
    canvas.drawRRect(r, Paint()..color = Colors.white);
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    if (checked) {
      final p = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final path = Path()
        ..moveTo(size.width * 0.18, size.height * 0.52)
        ..lineTo(size.width * 0.40, size.height * 0.74)
        ..lineTo(size.width * 0.82, size.height * 0.22);
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _PhetCheckboxPainter oldDelegate) =>
      oldDelegate.checked != checked;
}

/// `HSeparator` between MPControlPanel sub-panels (stroke black).
class MpHSeparator extends StatelessWidget {
  const MpHSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MpConstants.controlPanelYSpacing / 2,
      ),
      child: Container(height: 1, color: Colors.black),
    );
  }
}

/// Electronegativity panel — `ElectronegativityPanel.ts` + `ElectronegativitySlider.ts`.
class MpElectronegativityPanel extends StatelessWidget {
  const MpElectronegativityPanel({
    super.key,
    required this.atomLabel,
    required this.color,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String atomLabel;
  final Color color;
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    // Panel: fill=atom.color, stroke black, xMargin 15, yMargin 6
    // Content VBox: titleVBox + slider, spacing 8
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10), // sun Panel default cornerRadius
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // titleVBox spacing: 0
          Text(
            'Atom $atomLabel',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Arial',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Text(
            MpStrings.electronegativity,
            style: TextStyle(fontSize: 18, fontFamily: 'Arial'),
          ),
          const SizedBox(height: 8),
          // trackSize 150×5; major tick labels less/more (PhET places at ends)
          SizedBox(
            width: 150,
            child: Column(
              children: [
                const SizedBox(
                  width: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'less',
                        style: TextStyle(fontSize: 16, fontFamily: 'Arial'),
                      ),
                      Text(
                        'more',
                        style: TextStyle(fontSize: 16, fontFamily: 'Arial'),
                      ),
                    ],
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 5,
                    thumbShape: const _PointyThumb(),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white,
                    tickMarkShape:
                        const RoundSliderTickMarkShape(tickMarkRadius: 0),
                    activeTickMarkColor: Colors.transparent,
                    inactiveTickMarkColor: Colors.transparent,
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Tick marks (major at ends + center, minors every 0.2)
                      CustomPaint(
                        size: const Size(150, 28),
                        painter: _EnTickPainter(),
                      ),
                      Slider(
                        min: 2,
                        max: 4,
                        divisions: 10,
                        value: value.clamp(2, 4),
                        onChanged: onChanged,
                        onChangeEnd: onChangeEnd,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `PointySliderThumb.ts` — points up, origin at top-center tip, 30×35.
class _PointyThumb extends SliderComponentShape {
  const _PointyThumb();

  static const double w = 30;
  static const double h = 35;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(w, h);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    // Flutter places [center] on the track; PhET tip sits above track (thumbYOffset 10).
    // Draw with tip at (center.dx, center.dy - 10) approximating tip above track.
    final tip = Offset(center.dx, center.dy - 10);
    final radius = 0.15 * w;
    final heightOffset = radius * 0.45;

    final path = Path()
      ..moveTo(tip.dx, tip.dy) // tip
      ..lineTo(tip.dx + 0.5 * w - radius, tip.dy + 0.3 * h + heightOffset)
      ..lineTo(tip.dx + 0.5 * w, tip.dy + 0.3 * h + heightOffset)
      ..lineTo(tip.dx + 0.5 * w, tip.dy + h - radius)
      ..arcToPoint(
        Offset(tip.dx + 0.5 * w - radius, tip.dy + h),
        radius: Radius.circular(radius),
      )
      ..lineTo(tip.dx - 0.5 * w + radius, tip.dy + h)
      ..arcToPoint(
        Offset(tip.dx - 0.5 * w, tip.dy + h - radius),
        radius: Radius.circular(radius),
      )
      ..lineTo(tip.dx - 0.5 * w, tip.dy + 0.3 * h + heightOffset)
      ..lineTo(tip.dx - 0.5 * w + radius, tip.dy + 0.3 * h + heightOffset)
      ..close();

    final canvas = context.canvas;
    canvas.drawPath(
      path,
      Paint()..color = const Color.fromRGBO(50, 145, 184, 1),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}

/// EN slider tick marks — major at ends + center, minor every 0.2.
class _EnTickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    final cy = size.height / 2;
    final trackTop = cy - 2.5;
    final trackBot = cy + 2.5;
    canvas.drawRRect(
      RRect.fromLTRBR(
          0, trackTop, size.width, trackBot, const Radius.circular(1)),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
          0, trackTop, size.width, trackBot, const Radius.circular(1)),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    for (var i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      final major = i == 0 || i == 5 || i == 10;
      final len = major ? 10.0 : 5.0;
      canvas.drawLine(Offset(x, trackBot), Offset(x, trackBot + len), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MpSectionTitle extends StatelessWidget {
  const MpSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
      ),
    );
  }
}

class MpRadioColumn<T> extends StatelessWidget {
  const MpRadioColumn({
    super.key,
    required this.items,
    required this.labels,
    required this.value,
    required this.onChanged,
  });

  final List<T> items;
  final List<String> labels;
  final T value;
  final ValueChanged<T> onChanged;

  /// `MPConstants.AQUA_RADIO_BUTTON_OPTIONS.radius` + sun AquaRadioButton defaults.
  static const double aquaRadius = 9;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++)
          InkWell(
            onTap: () => onChanged(items[i]),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomPaint(
                    size: const Size(aquaRadius * 2, aquaRadius * 2),
                    painter: _AquaRadioPainter(selected: value == items[i]),
                  ),
                  const SizedBox(width: 8), // AquaRadioButton xSpacing default
                  Expanded(
                    child: Text(
                      labels[i],
                      style: const TextStyle(fontSize: 18, fontFamily: 'Arial'),
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

/// Port of sun `AquaRadioButton.ts` defaults (MP uses radius: 9).
class _AquaRadioPainter extends CustomPainter {
  _AquaRadioPainter({required this.selected});

  final bool selected;

  /// `selectedColor: 'rgb( 143, 197, 250 )'`
  static const Color selectedColor = Color.fromRGBO(143, 197, 250, 1);

  /// `centerColor: 'black'`
  static const Color centerColor = Colors.black;

  /// `deselectedColor: 'white'`
  static const Color deselectedColor = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    // Outer circle fill + stroke
    canvas.drawCircle(
      c,
      r - 0.5,
      Paint()..color = selected ? selectedColor : deselectedColor,
    );
    canvas.drawCircle(
      c,
      r - 0.5,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    if (selected) {
      // Inner dot radius = options.radius / 3
      canvas.drawCircle(c, r / 3, Paint()..color = centerColor);
    }
  }

  @override
  bool shouldRepaint(covariant _AquaRadioPainter oldDelegate) =>
      oldDelegate.selected != selected;
}

/// PhET `RealMoleculesControl` ComboBox — white fill, black stroke, cornerRadius 8,
/// square arrow button; list opens above (`listPosition: 'above'`).
class MpMoleculeComboBox extends StatelessWidget {
  const MpMoleculeComboBox({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final RealMoleculeDef value;
  final List<RealMoleculeDef> items;
  final ValueChanged<RealMoleculeDef> onChanged;

  static String itemLabel(RealMoleculeDef m) => '${m.symbol} (${m.name})';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final box = context.findRenderObject()! as RenderBox;
        final overlay =
            Overlay.of(context).context.findRenderObject()! as RenderBox;
        final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
        final size = box.size;
        // Prefer menu above the button (ComboBox listPosition: 'above').
        final selected = await showMenu<RealMoleculeDef>(
          context: context,
          position: RelativeRect.fromLTRB(
            topLeft.dx,
            0,
            overlay.size.width - topLeft.dx - size.width,
            overlay.size.height - topLeft.dy,
          ),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          items: [
            for (final m in items)
              PopupMenuItem<RealMoleculeDef>(
                value: m,
                height: 32,
                child: Container(
                  color: m == value
                      ? const Color.fromRGBO(218, 255, 255, 1) // highlightFill
                      : null,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    itemLabel(m),
                    style: const TextStyle(fontSize: 18, fontFamily: 'Arial'),
                  ),
                ),
              ),
          ],
        );
        if (selected != null) onChanged(selected);
      },
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                itemLabel(value),
                style: const TextStyle(fontSize: 18, fontFamily: 'Arial'),
              ),
            ),
            Container(
              width: 34,
              height: 36,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.black)),
              ),
              child: CustomPaint(painter: _ComboUpTrianglePainter()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComboUpTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.62)
      ..lineTo(size.width * 0.72, size.height * 0.62)
      ..lineTo(size.width * 0.5, size.height * 0.32)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// `BondDipoleNode.createIcon` / `MolecularDipoleNode.createIcon`.
class MpDipoleIcon extends StatelessWidget {
  const MpDipoleIcon.bond({super.key}) : color = MpColors.bondDipole;
  const MpDipoleIcon.molecular({super.key})
      : color = MpColors.molecularDipole;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: DipolePainter.iconSize,
      painter: _DipoleIconPainter(color: color),
    );
  }
}

class _DipoleIconPainter extends CustomPainter {
  _DipoleIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    DipolePainter.paintIcon(
      canvas,
      color: color,
      origin: Offset(1, size.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _DipoleIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Port of sun `ToggleSwitch` used by `EFieldControl.ts`.
/// Defaults: size 60×30; MP overrides trackFillLeft/Right.
class MpToggleSwitch extends StatelessWidget {
  const MpToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.trackFillLeft = const Color.fromRGBO(180, 180, 180, 1),
    this.trackFillRight = const Color.fromRGBO(0, 180, 0, 1),
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// `EFieldControl` trackFillLeft
  final Color trackFillLeft;

  /// `EFieldControl` trackFillRight
  final Color trackFillRight;

  static const double width = 60;
  static const double height = 30;

  @override
  Widget build(BuildContext context) {
    final radius = height / 2;
    final thumbW = width * 0.5;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _ToggleSwitchPainter(
            on: value,
            trackFillLeft: trackFillLeft,
            trackFillRight: trackFillRight,
            radius: radius,
            thumbW: thumbW,
          ),
        ),
      ),
    );
  }
}

class _ToggleSwitchPainter extends CustomPainter {
  _ToggleSwitchPainter({
    required this.on,
    required this.trackFillLeft,
    required this.trackFillRight,
    required this.radius,
    required this.thumbW,
  });

  final bool on;
  final Color trackFillLeft;
  final Color trackFillRight;
  final double radius;
  final double thumbW;

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    // Left (off) track
    canvas.drawRRect(track, Paint()..color = trackFillLeft);
    canvas.drawRRect(
      track,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Right fill covers from left edge through thumb right (ToggleSwitch logic)
    final thumbLeft = on ? size.width - thumbW : 0.0;
    final thumbRight = thumbLeft + thumbW;
    if (on) {
      final rightFill = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, thumbRight, size.height),
        Radius.circular(radius),
      );
      canvas.drawRRect(rightFill, Paint()..color = trackFillRight);
      canvas.drawRRect(
        track,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    // Thumb: white→gray vertical gradient (ToggleSwitch default thumbFill)
    final thumbRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(thumbLeft, 0, thumbW, size.height),
      Radius.circular(radius),
    );
    final thumbPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Color.fromRGBO(200, 200, 200, 1)],
      ).createShader(Rect.fromLTWH(thumbLeft, 0, thumbW, size.height));
    canvas.drawRRect(thumbRect, thumbPaint);
    canvas.drawRRect(
      thumbRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _ToggleSwitchPainter oldDelegate) =>
      oldDelegate.on != on ||
      oldDelegate.trackFillLeft != trackFillLeft ||
      oldDelegate.trackFillRight != trackFillRight;
}
