import 'package:flutter/material.dart';

/// 游戏计分板——显示关卡/星级/得分/计时。
class GameScoreboard extends StatelessWidget {
  const GameScoreboard({
    super.key,
    required this.level,
    required this.maxLevel,
    required this.score,
    this.stars = 0,
    this.maxStars = 3,
    this.elapsedMs,
    this.title = '得分',
  });

  final int level;
  final int maxLevel;
  final int score;
  final int stars;
  final int maxStars;
  final int? elapsedMs;
  final String title;

  static const _activeColor = Color(0xFFF59E0B);
  static const _inactiveColor = Color(0xFFE2E8F0);

  static String _fmtMs(int ms) {
    final totalSec = ms ~/ 1000;
    final min = totalSec ~/ 60;
    final sec = totalSec % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat('关卡', '$level / $maxLevel'),
          _buildStars(),
          _stat(title, score.toString()),
          if (elapsedMs != null) _stat('时间', _fmtMs(elapsedMs!)),
        ],
      ),
    );
  }

  Widget _buildStars() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxStars, (i) {
            return Icon(
              i < stars ? Icons.star : Icons.star_border,
              size: 20,
              color: i < stars ? _activeColor : _inactiveColor,
            );
          }),
        ),
        const SizedBox(height: 2),
        const Text('星级', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ],
    );
  }
}