import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/substance.dart';
import '../phet_font.dart';
import '../screens/stage_scale.dart';
import '../physics/visible_color.dart';

/// Round arrow button matching `MediumControlPanel` `ArrowButton` options.
///
/// Index buttons: scale 0.7, arrow 15×15, margins 5. Wavelength buttons: scale 0.6.
/// No Material splash. `sun/js/buttons/ArrowButton.ts` is not in the local tree;
/// the circle and triangle are the call-site geometry, not a guessed 3D bevel.
class PhetArrowButton extends StatelessWidget {
  const PhetArrowButton({
    super.key,
    required this.pointRight,
    required this.onPressed,
    this.enabled = true,
    this.scale = 0.7,
    this.arrowExtent = 15,
    this.margin = 5,
  });

  final bool pointRight;
  final VoidCallback onPressed;
  final bool enabled;
  final double scale;
  final double arrowExtent;
  final double margin;

  double get _side => (arrowExtent + margin * 2) * scale;

  @override
  Widget build(BuildContext context) {
    final side = _side * StageScale.of(context);
    return Semantics(
      button: true,
      enabled: enabled,
      label: pointRight ? 'increase' : 'decrease',
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: CustomPaint(
            size: Size(side, side),
            painter: _ArrowPainter(pointRight: pointRight),
          ),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.pointRight});

  final bool pointRight;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawOval(
      rect.deflate(0.5),
      Paint()
        ..color = const Color(0xFFE6E6E6)
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(
      rect.deflate(0.5),
      Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final w = size.width;
    final h = size.height;
    final path = Path();
    if (pointRight) {
      path
        ..moveTo(w * 0.32, h * 0.28)
        ..lineTo(w * 0.68, h * 0.5)
        ..lineTo(w * 0.32, h * 0.72)
        ..close();
    } else {
      path
        ..moveTo(w * 0.68, h * 0.28)
        ..lineTo(w * 0.32, h * 0.5)
        ..lineTo(w * 0.68, h * 0.72)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = const Color(0xFF000000));
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.pointRight != pointRight;
}

/// `HSlider` track from `MediumControlPanel`: white track 210×1, thumb 10×20.
///
/// `sun/js/HSlider.ts` is not in the local tree, so the thumb is the documented
/// size, not `knob.png` (that image is the laser/prism knob).
class PhetHSlider extends StatelessWidget {
  const PhetHSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.trackWidth = 210,
    this.thumbWidth = 10,
    this.thumbHeight = 20,
    this.trackHeight = 1,
    this.ticks = const [],
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final double trackWidth;
  final double thumbWidth;
  final double thumbHeight;
  final double trackHeight;
  final List<PhetSliderTick> ticks;

  void _emit(double localDx, double thumb) {
    final span = math.max(1.0, trackWidth - thumb);
    final t = ((localDx - thumb / 2) / span).clamp(0.0, 1.0);
    onChanged(min + t * (max - min));
  }

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    return Semantics(
      slider: true,
      value: value.toStringAsFixed(3),
      child: SizedBox(
        width: trackWidth,
        height: thumbHeight * view + 18 * view,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (d) => _emit(d.localPosition.dx, thumbWidth * view),
          onPanUpdate: (d) => _emit(d.localPosition.dx, thumbWidth * view),
          child: CustomPaint(
            painter: _HSliderPainter(
              value: value.clamp(min, max),
              min: min,
              max: max,
              thumbWidth: thumbWidth * view,
              thumbHeight: thumbHeight * view,
              trackHeight: trackHeight * view,
              ticks: ticks,
            ),
          ),
        ),
      ),
    );
  }
}

class PhetSliderTick {
  const PhetSliderTick(this.value, this.label);
  final double value;
  final String label;
}

class _HSliderPainter extends CustomPainter {
  _HSliderPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.thumbWidth,
    required this.thumbHeight,
    required this.trackHeight,
    required this.ticks,
  });

  final double value;
  final double min;
  final double max;
  final double thumbWidth;
  final double thumbHeight;
  final double trackHeight;
  final List<PhetSliderTick> ticks;

  double _t(double v) => ((v - min) / (max - min)).clamp(0.0, 1.0);

  double _x(double v, Size size) {
    final span = size.width - thumbWidth;
    return _t(v) * span + thumbWidth / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final trackY = thumbHeight / 2;
    final track = Rect.fromCenter(
      center: Offset(size.width / 2, trackY),
      width: size.width,
      height: trackHeight,
    );
    canvas.drawRect(track, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawRect(
      track,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF000000),
    );

    for (final tick in ticks) {
      final x = _x(tick.value, size);
      canvas.drawLine(
        Offset(x, trackY + 2),
        Offset(x, trackY + 13),
        Paint()
          ..color = const Color(0xFF000000)
          ..strokeWidth = 1,
      );
    }

    final thumb = Rect.fromCenter(
      center: Offset(_x(value, size), trackY),
      width: thumbWidth,
      height: thumbHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(thumb, const Radius.circular(2)),
      Paint()..color = const Color(0xFFF2F2F2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(thumb, const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF000000),
    );
  }

  @override
  bool shouldRepaint(covariant _HSliderPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.min != min || oldDelegate.max != max;
}

/// `WavelengthSlider` / `SpectrumSlider`: track height 20, thumb 20×20,
/// `cursorStroke: white`. Tweakers are the separate arrow buttons.
class PhetSpectrumSlider extends StatelessWidget {
  const PhetSpectrumSlider({
    super.key,
    required this.nm,
    required this.minNm,
    required this.maxNm,
    required this.onChangedNm,
    this.trackWidth = 120,
    this.trackHeight = 20,
    this.thumbExtent = 20,
  });

  final double nm;
  final double minNm;
  final double maxNm;
  final ValueChanged<double> onChangedNm;
  final double trackWidth;
  final double trackHeight;
  final double thumbExtent;

  void _emit(double localDx, double thumb) {
    final span = math.max(1.0, trackWidth - thumb);
    final t = ((localDx - thumb / 2) / span).clamp(0.0, 1.0);
    onChangedNm(minNm + t * (maxNm - minNm));
  }

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    return Semantics(
      slider: true,
      value: nm.round().toString(),
      child: SizedBox(
        width: trackWidth,
        height: math.max(trackHeight, thumbExtent) * view,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (d) => _emit(d.localPosition.dx, thumbExtent * view),
          onPanUpdate: (d) => _emit(d.localPosition.dx, thumbExtent * view),
          child: CustomPaint(
            painter: _SpectrumPainter(
              nm: nm.clamp(minNm, maxNm),
              minNm: minNm,
              maxNm: maxNm,
              trackHeight: trackHeight * view,
              thumbExtent: thumbExtent * view,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpectrumPainter extends CustomPainter {
  _SpectrumPainter({
    required this.nm,
    required this.minNm,
    required this.maxNm,
    required this.trackHeight,
    required this.thumbExtent,
  });

  final double nm;
  final double minNm;
  final double maxNm;
  final double trackHeight;
  final double thumbExtent;

  @override
  void paint(Canvas canvas, Size size) {
    final track = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: trackHeight,
    );
    final colors = <Color>[];
    final stops = <double>[];
    const samples = 16;
    for (var i = 0; i <= samples; i++) {
      final t = i / samples;
      final sample = minNm + t * (maxNm - minNm);
      final argb = visibleColorArgb(sample);
      colors.add(argb == null ? const Color(0xFF808080) : Color(argb));
      stops.add(t);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(track, const Radius.circular(2)),
      Paint()
        ..shader = LinearGradient(colors: colors, stops: stops).createShader(track),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(track, const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF000000),
    );
    final t = ((nm - minNm) / (maxNm - minNm)).clamp(0.0, 1.0);
    final span = size.width - thumbExtent;
    final thumb = Rect.fromCenter(
      center: Offset(t * span + thumbExtent / 2, size.height / 2),
      width: thumbExtent,
      height: thumbExtent,
    );
    final fill = visibleColorArgb(nm);
    canvas.drawRect(
      thumb,
      Paint()..color = fill == null ? const Color(0xFF808080) : Color(fill),
    );
    canvas.drawRect(
      thumb,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant _SpectrumPainter oldDelegate) => oldDelegate.nm != nm;
}

/// Closed `ComboBox` from the `MediumControlPanel` call site:
/// xMargin 7, yMargin 4, cornerRadius 3.
///
/// `sun/js/ComboBox.ts` is not in the local tree, so the list highlight is a
/// neutral selected row, not a guessed sun default color.
class PhetComboBox extends StatefulWidget {
  const PhetComboBox({
    super.key,
    required this.value,
    required this.items,
    required this.onSelected,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onSelected;

  @override
  State<PhetComboBox> createState() => _PhetComboBoxState();
}

class _PhetComboBoxState extends State<PhetComboBox> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _entry;

  @override
  void didUpdateWidget(covariant PhetComboBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _close();
    }
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  void _toggle() {
    if (_entry != null) {
      _close();
      return;
    }
    final view = StageScale.of(context);
    final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.maybeOf(context);
    if (box == null || overlay == null) return;
    final origin = box.localToGlobal(Offset.zero);
    final width = math.max(box.size.width, 96.0 * view);
    _entry = OverlayEntry(
      builder: (overlayContext) => MediaQuery(
        data: MediaQuery.of(overlayContext).copyWith(
          textScaler: TextScaler.linear(view),
        ),
        child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          Positioned(
            left: origin.dx,
            top: origin.dy + box.size.height,
            width: width,
            child: _ComboList(
              items: widget.items,
              selected: widget.value,
              onSelected: (name) {
                widget.onSelected(name);
                _close();
              },
            ),
          ),
        ],
        ),
      ),
    );
    overlay.insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    final view = StageScale.of(context);
    return GestureDetector(
      key: _buttonKey,
      onTap: _toggle,
      child: Container(
        padding: EdgeInsets.fromLTRB(7 * view, 4 * view, 6 * view, 4 * view),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: const Color(0xFF000000)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.value, style: PhetFont.of(10)),
            SizedBox(width: 8 * view),
            CustomPaint(
              size: Size(8 * view, 6 * view),
              painter: _DownTriangle(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComboList extends StatelessWidget {
  const _ComboList({
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final view = MediaQuery.textScalerOf(context).scale(1);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF000000)),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), offset: Offset(1, 1), blurRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items)
            GestureDetector(
              onTap: () => onSelected(item),
              child: Container(
                color: item == selected ? const Color(0xFFE6E6E6) : const Color(0xFFFFFFFF),
                padding: EdgeInsets.symmetric(horizontal: 7 * view, vertical: 4 * view),
                child: Text(item, style: PhetFont.of(10)),
              ),
            ),
        ],
      ),
    );
  }
}

class _DownTriangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF000000));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Index slider ticks at Air, Water, Glass, and 1.6 (`MediumControlPanel`).
List<PhetSliderTick> indexOfRefractionTicks() => [
      PhetSliderTick(Substance.air.indexForRed, 'Air'),
      PhetSliderTick(Substance.water.indexForRed, 'Water'),
      PhetSliderTick(Substance.glass.indexForRed, 'Glass'),
      const PhetSliderTick(1.6, '1.6'),
    ];
