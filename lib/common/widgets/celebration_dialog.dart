import 'dart:math';
import 'package:flutter/material.dart';

/// 通用喜庆达成弹框——用于"目标完成/挑战成功/关卡通关"等正反馈场景。
///
/// 与 [GameOverDialog] 的区别：GameOverDialog 侧重"结算展示"（星级+得分+按钮），
/// 本 dialog 侧重"庆祝瞬间"（彩带纸屑动画+大标题+可选目标展示）。
///
/// 用法：
/// ```dart
/// showCelebrationDialog(
///   context,
///   title: '挑战成功！',
///   subtitle: '完美匹配 100%',
///   accentColor: Colors.pink,
///   showcaseColor: Colors.orange,  // 可选: 展示"达成的目标色"
///   primaryLabel: '下一关',
///   onPrimary: () => nextLevel(),
/// );
/// ```
///
/// L1 候选组件（3-Time Rule）· 使用者：
/// 1. color_vision 挑战模式（100% 精确匹配）
/// 2. TBD
/// 3. TBD
Future<T?> showCelebrationDialog<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  Color accentColor = const Color(0xFFF59E0B),
  Color? showcaseColor,
  String primaryLabel = '继续',
  String? secondaryLabel,
  VoidCallback? onPrimary,
  VoidCallback? onSecondary,
  String emoji = '🎉',
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withAlpha(120),
    builder: (_) => CelebrationDialog(
      title: title,
      subtitle: subtitle,
      accentColor: accentColor,
      showcaseColor: showcaseColor,
      primaryLabel: primaryLabel,
      secondaryLabel: secondaryLabel,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      emoji: emoji,
    ),
  );
}

class CelebrationDialog extends StatefulWidget {
  const CelebrationDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.accentColor = const Color(0xFFF59E0B),
    this.showcaseColor,
    this.primaryLabel = '继续',
    this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
    this.emoji = '🎉',
  });

  final String title;
  final String? subtitle;
  final Color accentColor;
  final Color? showcaseColor;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final String emoji;

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with TickerProviderStateMixin {
  late final AnimationController _confettiCtrl;
  late final AnimationController _popCtrl;
  late final List<_Confetti> _confetti;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _confetti = List.generate(60, (_) => _Confetti.random(rng));
    _confettiCtrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _popCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _popCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiCtrl,
                builder: (_, _) => CustomPaint(
                  painter: _ConfettiPainter(_confetti, _confettiCtrl.value),
                ),
              ),
            ),
          ),
          ScaleTransition(
            scale: CurvedAnimation(parent: _popCtrl, curve: Curves.elasticOut),
            child: _buildCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, widget.accentColor.withAlpha(30)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: widget.accentColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withAlpha(80),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: widget.accentColor,
              shadows: [
                Shadow(color: widget.accentColor.withAlpha(100), blurRadius: 8),
              ],
            ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ],
          if (widget.showcaseColor != null) ...[
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.showcaseColor,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: widget.showcaseColor!.withAlpha(140),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.secondaryLabel != null)
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onSecondary?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    side: BorderSide(color: widget.accentColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    widget.secondaryLabel!,
                    style: TextStyle(color: widget.accentColor, fontWeight: FontWeight.w600),
                  ),
                ),
              if (widget.secondaryLabel != null) const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onPrimary?.call();
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(widget.primaryLabel,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 4,
                  shadowColor: widget.accentColor.withAlpha(120),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Confetti {
  final double xSeed;
  final double delay;
  final double speed;
  final double rotSpeed;
  final double size;
  final Color color;
  final bool isCircle;

  _Confetti({
    required this.xSeed,
    required this.delay,
    required this.speed,
    required this.rotSpeed,
    required this.size,
    required this.color,
    required this.isCircle,
  });

  factory _Confetti.random(Random rng) {
    const palette = [
      Color(0xFFEF4444), Color(0xFFF97316), Color(0xFFF59E0B),
      Color(0xFF10B981), Color(0xFF3B82F6), Color(0xFF8B5CF6),
      Color(0xFFEC4899), Color(0xFF06B6D4),
    ];
    return _Confetti(
      xSeed: rng.nextDouble(),
      delay: rng.nextDouble(),
      speed: 0.7 + rng.nextDouble() * 0.8,
      rotSpeed: (rng.nextDouble() - 0.5) * 12,
      size: 6 + rng.nextDouble() * 8,
      color: palette[rng.nextInt(palette.length)],
      isCircle: rng.nextBool(),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> pieces;
  final double t;

  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in pieces) {
      final phase = (t + c.delay) % 1.0;
      final progress = phase * c.speed;
      final y = -20 + progress * (size.height + 40);
      final swayX = sin((phase * 2 + c.xSeed) * pi * 2) * 20;
      final x = c.xSeed * size.width + swayX;
      final rot = phase * c.rotSpeed;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      final paint = Paint()..color = c.color;
      if (c.isCircle) {
        canvas.drawCircle(Offset.zero, c.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.5),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.t != t;
}
