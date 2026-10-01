import 'package:flutter/material.dart';

import '../som_strings.dart';

/// Heat/Cool — same interaction chrome as Gases Intro `HeaterCoolerWidget`.
///
/// Stove bowl + flame/ice assets + vertical slider (Heat top / Cool bottom).
/// Factor ∈ [−1, 1]; release snaps to 0.
class HeaterCoolerControl extends StatefulWidget {
  const HeaterCoolerControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.snapToZero = true,
    this.stoveWidth = 120,
    this.scale = 0.79,
  });

  /// Heat/cool amount in [−1, 1].
  final double value;
  final ValueChanged<double> onChanged;
  final bool enabled;
  final bool snapToZero;
  final double stoveWidth;
  final double scale;

  static const Color baseColor = Color.fromARGB(255, 159, 182, 205);
  static const Color coolTrack = Color(0xFF0A00F0);
  static const Color heatTrack = Color(0xFFEF000F);
  static const Color thumbColor = Color(0xFF71EDFF);

  /// Shared with Gases Intro (already in pubspec).
  static const String flameAsset = 'assets/gases_intro/flame.png';
  static const String iceAsset = 'assets/gases_intro/iceCubeStack.png';

  @override
  State<HeaterCoolerControl> createState() => _HeaterCoolerControlState();
}

class _HeaterCoolerControlState extends State<HeaterCoolerControl> {
  late double _live;

  @override
  void initState() {
    super.initState();
    _live = widget.value;
  }

  @override
  void didUpdateWidget(covariant HeaterCoolerControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _live = widget.value;
    }
  }

  double get _s => widget.scale;
  double get _stoveW => widget.stoveWidth * _s;
  double get _stoveH => 140 * _s;
  double get _sliderColW => 40 * _s;

  @override
  Widget build(BuildContext context) {
    final factor = _live;
    const labelStyle = TextStyle(color: Colors.white54, fontSize: 10);

    return Opacity(
      opacity: widget.enabled ? 1 : 0.45,
      child: SizedBox(
        width: _stoveW + _sliderColW,
        height: _stoveH,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: _stoveW,
              height: _stoveH,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  if (factor > 0.02)
                    Positioned(
                      top: -factor * 55 * _s,
                      left: 10 * _s,
                      right: 10 * _s,
                      child: Image.asset(
                        HeaterCoolerControl.flameAsset,
                        height: 70 * _s,
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (factor < -0.02)
                    Positioned(
                      top: factor.abs() * -40 * _s,
                      left: 16 * _s,
                      right: 16 * _s,
                      child: Image.asset(
                        HeaterCoolerControl.iceAsset,
                        height: 55 * _s,
                        fit: BoxFit.contain,
                      ),
                    ),
                  CustomPaint(
                    size: Size(_stoveW, 100 * _s),
                    painter: _StovePainter(
                      baseColor: HeaterCoolerControl.baseColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: _sliderColW,
              height: 110 * _s,
              child: Column(
                children: [
                  const Text(SomStrings.heat, style: labelStyle),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final trackLen = c.maxHeight;
                        if (trackLen < 32) return const SizedBox.shrink();
                        return RotatedBox(
                          quarterTurns: 3,
                          child: SizedBox(
                            width: trackLen,
                            height: _sliderColW,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: (10 * _s).clamp(6.0, 10.0),
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: (9 * _s).clamp(6.0, 9.0),
                                ),
                                overlayShape: RoundSliderOverlayShape(
                                  overlayRadius: (16 * _s).clamp(10.0, 16.0),
                                ),
                                activeTrackColor: HeaterCoolerControl.coolTrack,
                                inactiveTrackColor:
                                    HeaterCoolerControl.heatTrack,
                                thumbColor: HeaterCoolerControl.thumbColor,
                              ),
                              child: Slider(
                                value: factor.clamp(-1.0, 1.0),
                                min: -1,
                                max: 1,
                                onChanged: widget.enabled
                                    ? (v) {
                                        setState(() => _live = v);
                                        widget.onChanged(v);
                                      }
                                    : null,
                                onChangeEnd: widget.enabled
                                    ? (_) {
                                        if (widget.snapToZero) {
                                          setState(() => _live = 0);
                                          widget.onChanged(0);
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Text(SomStrings.cool, style: labelStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stove bowl / body — same geometry as Gases Intro `_StovePainter`.
class _StovePainter extends CustomPainter {
  _StovePainter({required this.baseColor});
  final Color baseColor;

  static const double openingScale = 0.1;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final openingH = w * openingScale;
    final bodyH = w * 0.75;
    final bottomW = w * 0.80;

    final interior = Rect.fromCenter(
      center: Offset(w / 2, openingH / 4),
      width: w,
      height: openingH,
    );
    canvas.drawOval(
      interior,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.lerp(baseColor, Colors.black, 0.5)!,
            Color.lerp(baseColor, Colors.white, 0.5)!,
          ],
        ).createShader(interior),
    );
    canvas.drawOval(
      interior,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final bodyPath = Path()
      ..moveTo(0, openingH / 2)
      ..lineTo((w - bottomW) / 2, bodyH + openingH / 2)
      ..arcToPoint(
        Offset((w + bottomW) / 2, bodyH + openingH / 2),
        radius: Radius.elliptical(bottomW / 2, openingH),
        clockwise: false,
      )
      ..lineTo(w, openingH / 2)
      ..arcToPoint(
        Offset(0, openingH / 2),
        radius: Radius.elliptical(w / 2, openingH / 2),
        clockwise: false,
      )
      ..close();

    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.lerp(baseColor, Colors.white, 0.5)!,
            Color.lerp(baseColor, Colors.black, 0.5)!,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, bodyH + openingH)),
    );
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _StovePainter oldDelegate) =>
      oldDelegate.baseColor != baseColor;
}
