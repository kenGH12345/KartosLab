import 'package:flutter/material.dart';

/// 游戏结算弹窗——对应 Java GameOverNode。
///
/// 用法：
/// ```dart
/// showDialog(context: context, builder: (_) => GameOverDialog(
///   score: 1250, stars: 3, maxStars: 3,
///   elapsedMs: 45230,
///   onReplay: () { /* restart */ },
///   onNextLevel: () { /* next */ },
/// ));
/// ```
class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    super.key,
    required this.score,
    this.stars = 0,
    this.maxStars = 3,
    this.elapsedMs,
    this.title = '关卡完成！',
    this.onReplay,
    this.onNextLevel,
    this.showNextLevel = false,
  });

  final int score;
  final int stars;
  final int maxStars;
  final int? elapsedMs;
  final String title;
  final VoidCallback? onReplay;
  final VoidCallback? onNextLevel;
  final bool showNextLevel;

  static const _activeColor = Color(0xFFF59E0B);
  static const _inactiveColor = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            // 星级
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(maxStars, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    size: 40,
                    color: i < stars ? _activeColor : _inactiveColor,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            // 得分
            Text('$score 分', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1177AA))),
            const SizedBox(height: 4),
            if (elapsedMs != null)
              Text('用时 ${_fmtMs(elapsedMs!)}', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            // 按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onReplay != null) _btn('重新挑战', Icons.replay, onReplay!),
                if (onReplay != null && showNextLevel && onNextLevel != null) const SizedBox(width: 12),
                if (showNextLevel && onNextLevel != null) _btn('下一关', Icons.arrow_forward, onNextLevel!, primary: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, IconData icon, VoidCallback onTap, {bool primary = false}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? const Color(0xFF1177AA) : null,
        foregroundColor: primary ? Colors.white : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static String _fmtMs(int ms) {
    final totalSec = ms ~/ 1000;
    final min = totalSec ~/ 60;
    final sec = totalSec % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
