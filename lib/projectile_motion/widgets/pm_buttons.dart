import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../pm_assets.dart';
import '../pm_colors.dart';
import '../pm_constants.dart';

/// FireButton.ts：红底 RectangularPushButton + fireButton.png，minWidth 75。
class PmFireButton extends StatelessWidget {
  const PmFireButton({
    super.key,
    required this.enabled,
    required this.onFire,
    this.icon,
  });

  final bool enabled;
  final VoidCallback onFire;
  final ui.Image? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onFire : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          width: 75,
          height: 42,
          decoration: BoxDecoration(
            color: PmColors.fireButtonBase,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black54),
            boxShadow: const [
              BoxShadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 2),
            ],
          ),
          child: Center(
            child: icon != null
                ? RawImage(
                    image: icon,
                    width: 35,
                    filterQuality: FilterQuality.medium,
                  )
                : Image.asset(
                    PmAssets.fireButton,
                    width: 35,
                    filterQuality: FilterQuality.medium,
                  ),
          ),
        ),
      ),
    );
  }
}

/// scenery-phet PlayPauseButton + StepButton（自绘 PhET chrome，禁 Material 图标）
class PmPlayPauseButton extends StatelessWidget {
  const PmPlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onToggle,
  });

  final bool isPlaying;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Transform.scale(
        scale: isPlaying ? 1.0 : 1.25,
        child: CustomPaint(
          size: const Size(36, 36),
          painter: _PlayPausePainter(isPlaying: isPlaying),
        ),
      ),
    );
  }
}

class _PlayPausePainter extends CustomPainter {
  _PlayPausePainter({required this.isPlaying});

  final bool isPlaying;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 1;
    // 外圈
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFF0F0F0));
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke);
    if (isPlaying) {
      // 暂停：双竖条
      final barPaint = Paint()..color = Colors.black;
      canvas.drawRect(
          Rect.fromLTWH(center.dx - 7, center.dy - 8, 5, 16), barPaint);
      canvas.drawRect(
          Rect.fromLTWH(center.dx + 2, center.dy - 8, 5, 16), barPaint);
    } else {
      // 播放：三角
      final path = Path()
        ..moveTo(center.dx - 5, center.dy - 9)
        ..lineTo(center.dx + 9, center.dy)
        ..lineTo(center.dx - 5, center.dy + 9)
        ..close();
      canvas.drawPath(path, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(_PlayPausePainter oldDelegate) =>
      oldDelegate.isPlaying != isPlaying;
}

class PmStepButton extends StatelessWidget {
  const PmStepButton({super.key, required this.enabled, required this.onStep});

  final bool enabled;
  final VoidCallback onStep;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onStep : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: CustomPaint(
          size: const Size(32, 32),
          painter: _StepPainter(),
        ),
      ),
    );
  }
}

class _StepPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 1;
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFF0F0F0));
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke);
    final paint = Paint()..color = const Color(0xFF005566);
    final path = Path()
      ..moveTo(center.dx - 6, center.dy - 7)
      ..lineTo(center.dx + 3, center.dy)
      ..lineTo(center.dx - 6, center.dy + 7)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawRect(
        Rect.fromLTWH(center.dx + 4, center.dy - 7, 3, 14), paint);
  }

  @override
  bool shouldRepaint(_StepPainter oldDelegate) => false;
}

/// scenery-phet `ResetAllButton` / `RoundPushButton.ThreeDAppearanceStrategy`。
/// 球面高光 + ResetShape 白箭头；按下缩小，松开弹性回弹。
class PmResetAllButton extends StatefulWidget {
  const PmResetAllButton({super.key, required this.onReset});

  final VoidCallback onReset;

  /// `PhetColorScheme.RESET_ALL_BUTTON_BASE_COLOR`
  static const Color baseColor = Color.fromRGBO(247, 151, 34, 1);

  /// `SceneryPhetConstants.DEFAULT_BUTTON_RADIUS`
  static const double radius = 20.8;

  @override
  State<PmResetAllButton> createState() => _PmResetAllButtonState();
}

class _PmResetAllButtonState extends State<PmResetAllButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
      reverseDuration: const Duration(milliseconds: 520),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _down() {
    _press.animateTo(1, curve: Curves.easeIn);
  }

  void _up({required bool fire}) {
    _press.animateBack(0, curve: Curves.elasticOut);
    if (fire) widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    const r = PmResetAllButton.radius;
    const d = r * 2 + 8; // 阴影余量
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _down(),
      onTapUp: (_) => _up(fire: true),
      onTapCancel: () => _up(fire: false),
      child: SizedBox(
        width: d,
        height: d,
        child: AnimatedBuilder(
          animation: _press,
          builder: (context, _) {
            final t = _press.value;
            final scale = 1.0 - 0.12 * t;
            return Transform.scale(
              scale: scale,
              child: CustomPaint(
                size: const Size(d, d),
                painter: _ResetAllPainter(press: t.clamp(0.0, 1.0)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResetAllPainter extends CustomPainter {
  _ResetAllPainter({required this.press});

  /// 0 = 抬起，1 = 按下（RoundButton 3D 高光随按下内收变暗）
  final double press;

  @override
  void paint(Canvas canvas, Size size) {
    const r = PmResetAllButton.radius;
    final center = Offset(size.width / 2, size.height / 2 - 1 + 1.5 * press);

    // 底部接触阴影（按下时收短）
    final shadow = Paint()
      ..color = Color.fromRGBO(0, 0, 0, 0.28 - 0.14 * press)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.2 - 1.4 * press);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + r * (0.55 - 0.2 * press)),
        width: r * (1.55 - 0.25 * press),
        height: r * (0.42 - 0.12 * press),
      ),
      shadow,
    );

    // 球面：高光在左上（ThreeDAppearanceStrategy）
    final hx = -0.42 + 0.28 * press;
    final hy = -0.48 + 0.28 * press;
    final highlight = center + Offset(r * hx, r * hy);
    final sphere = Paint()
      ..shader = ui.Gradient.radial(
        highlight,
        r * 1.55,
        [
          Color.lerp(const Color(0xFFFFE7B0), const Color(0xFFFFC56A), press)!,
          Color.lerp(PmResetAllButton.baseColor, const Color(0xFFE07A12), press)!,
          Color.lerp(const Color(0xFFB85A0C), const Color(0xFF8F4308), press)!,
        ],
        const [0.0, 0.42, 1.0],
      );
    canvas.drawCircle(center, r, sphere);

    // 顶部镜面高光
    final specCenter = center + Offset(-r * 0.38, -r * 0.42);
    final spec = Paint()
      ..shader = ui.Gradient.radial(
        specCenter,
        r * 0.55,
        [
          Color.fromRGBO(255, 255, 255, 0.55 - 0.25 * press),
          const Color(0x00FFFFFF),
        ],
      );
    canvas.drawCircle(center, r, spec);

    // 边缘
    canvas.drawCircle(
      center,
      r - 0.4,
      Paint()
        ..color = const Color.fromRGBO(140, 75, 12, 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    // ResetShape.ts（adjustShapeForStroke: true）+ yContentOffset
    canvas.save();
    canvas.translate(center.dx, center.dy - 0.0125 * r);
    final arrow = _resetShapePath(r);
    canvas.drawPath(arrow, Paint()..color = Colors.white);
    canvas.drawPath(
      arrow,
      Paint()
        ..color = const Color.fromRGBO(80, 80, 80, 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  /// `scenery-phet/js/ResetShape.ts`
  static Path _resetShapePath(double radius) {
    const adj = 0.8;
    final innerR = radius * 0.4 - adj;
    final outerR = radius * 0.625 + adj;
    final headWidth = 2.0 * (outerR - innerR);
    const startAngle = -math.pi * 0.35;
    const endToNeck = -2 * math.pi * 0.85;
    const arrowHeadSpan = -math.pi * 0.18;
    final neckAngle = startAngle + endToNeck;
    final extrusion = (headWidth - (outerR - innerR)) / 2;
    final path = Path()
      ..moveTo(innerR * math.cos(startAngle), innerR * math.sin(startAngle))
      ..lineTo(outerR * math.cos(startAngle), outerR * math.sin(startAngle));
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: outerR),
      startAngle,
      endToNeck,
      false,
    );
    path
      ..lineTo(
        (outerR + extrusion) * math.cos(neckAngle),
        (outerR + extrusion) * math.sin(neckAngle),
      )
      ..lineTo(
        ((outerR + innerR) * 0.55) * math.cos(neckAngle + arrowHeadSpan),
        ((outerR + innerR) * 0.55) * math.sin(neckAngle + arrowHeadSpan),
      )
      ..lineTo(
        (innerR - extrusion) * math.cos(neckAngle),
        (innerR - extrusion) * math.sin(neckAngle),
      )
      ..lineTo(innerR * math.cos(neckAngle), innerR * math.sin(neckAngle));
    path.arcTo(
      Rect.fromCircle(center: Offset.zero, radius: innerR),
      neckAngle,
      -endToNeck,
      false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_ResetAllPainter oldDelegate) =>
      oldDelegate.press != press;
}

/// scenery-phet EraserButton（自绘橡皮）
class PmEraserButton extends StatelessWidget {
  const PmEraserButton({super.key, required this.onErase});

  final VoidCallback onErase;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onErase,
      child: Container(
        width: 50,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black54),
        ),
        child: Center(
          child: CustomPaint(
              size: const Size(28, 22), painter: _EraserPainter()),
        ),
      ),
    );
  }
}

class _EraserPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.5);
    // 粉色橡皮体 + 蓝色纸套
    canvas.drawRect(
        Rect.fromLTWH(-12, -7, 24, 14),
        Paint()..color = const Color(0xFFF2A7C3));
    canvas.drawRect(
        Rect.fromLTWH(-4, -7, 12, 14),
        Paint()..color = const Color(0xFF7FB3D5));
    canvas.drawRect(
        Rect.fromLTWH(-12, -7, 24, 14),
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EraserPainter oldDelegate) => false;
}

/// MagnifyingGlassZoomButtonGroup（自绘放大镜 ±）
class PmZoomButtons extends StatelessWidget {
  const PmZoomButtons({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.canZoomIn,
    required this.canZoomOut,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final bool canZoomIn;
  final bool canZoomOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ZoomButton(sign: 1, enabled: canZoomIn, onTap: onZoomIn),
        const SizedBox(width: 10),
        _ZoomButton(sign: -1, enabled: canZoomOut, onTap: onZoomOut),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton(
      {required this.sign, required this.enabled, required this.onTap});

  final int sign;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE7E8E9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black54),
          ),
          child: CustomPaint(painter: _MagnifierPainter(sign: sign)),
        ),
      ),
    );
  }
}

class _MagnifierPainter extends CustomPainter {
  _MagnifierPainter({required this.sign});

  final int sign;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero) - const Offset(2, 2);
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 7, paint);
    canvas.drawLine(center + const Offset(5, 5), center + const Offset(11, 11),
        paint..strokeWidth = 3);
    // ± 号
    final signPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2;
    canvas.drawLine(center + const Offset(-4, 0), center + const Offset(4, 0),
        signPaint);
    if (sign > 0) {
      canvas.drawLine(center + const Offset(0, -4), center + const Offset(0, 4),
          signPaint);
    }
  }

  @override
  bool shouldRepaint(_MagnifierPainter oldDelegate) => false;
}

/// TimeControlNode 的 Normal/Slow 单选（绿字）
class PmTimeSpeedRadio extends StatelessWidget {
  const PmTimeSpeedRadio({
    super.key,
    required this.slowMotion,
    required this.onChanged,
  });

  final bool slowMotion;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF2E7D32);
    Widget option(String label, bool slow) {
      final selected = slowMotion == slow;
      return GestureDetector(
        onTap: () => onChanged(slow),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black54),
                color: Colors.white,
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: green),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 4),
            Text(label, style: PmConstants.uiText.copyWith(color: green)),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        option('Normal', false),
        const SizedBox(height: 2),
        option('Slow', true),
      ],
    );
  }
}
