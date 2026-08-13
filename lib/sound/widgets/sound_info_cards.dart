import 'package:flutter/material.dart';

/// Sound sim 屏幕右上角的响度 + 波长标尺卡片。
class SoundStatCard extends StatelessWidget {
  const SoundStatCard({
    super.key,
    required this.loudnessPercent,
    required this.wavelengthMeters,
  });

  final double loudnessPercent; // 0-100
  final double wavelengthMeters;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bar(
          label: '响度',
          valueText: '${loudnessPercent.round()}%',
          value: (loudnessPercent / 100).clamp(0.0, 1.0),
          fillColor: const Color(0xFFEF4444),
        ),
        const SizedBox(height: 8),
        _bar(
          label: '波长标尺',
          valueText: '${wavelengthMeters.toStringAsFixed(2)} m',
          // 以 λ=1m 作满刻度参考（约 340 Hz），大于则 clamp 到 1
          value: (wavelengthMeters / 1.0).clamp(0.0, 1.0),
          fillColor: const Color(0xFF60A5FA),
        ),
      ],
    );
  }

  Widget _bar({
    required String label,
    required String valueText,
    required double value,
    required Color fillColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xEE0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF94A3B8), fontSize: 11, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          SizedBox(
            width: 160,
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(valueText,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Sound sim 屏幕左上角四行信息卡：频率 / 波长 / 波速 / 响度。
class SoundInfoCard extends StatelessWidget {
  const SoundInfoCard({
    super.key,
    required this.frequencyHz,
    required this.wavelengthMeters,
    required this.speedMetersPerSecond,
    required this.loudnessPercent,
  });

  final double frequencyHz;
  final double wavelengthMeters;
  final double speedMetersPerSecond;
  final double loudnessPercent; // 0-100

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pill('频率', '${frequencyHz.round()} Hz'),
        const SizedBox(height: 6),
        _pill('波长', '${wavelengthMeters.toStringAsFixed(2)} m'),
        const SizedBox(height: 6),
        _pill('波速', '${speedMetersPerSecond.round()} m/s'),
        const SizedBox(height: 6),
        _loudnessBar('响度', '${loudnessPercent.round()}%', loudnessPercent / 100.0),
      ],
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xEE0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          children: [
            TextSpan(text: '$label  '),
            TextSpan(
              text: value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loudnessBar(String label, String valueText, double fraction) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xEE0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF94A3B8), fontSize: 12)),
          const SizedBox(width: 8),
          SizedBox(
            width: 62,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(valueText,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// 球面视图底部灰度色标图例。
class SphericalLegend extends StatelessWidget {
  const SphericalLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xEE0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      // 渐变条 Expanded 自适应：固定 100 在窄容器（320 屏 w<=241.7）溢出 9.3px
      child: Row(
        children: [
          const Text('稀疏 (暗)',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [Colors.black, Color(0xFF808080), Colors.white],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text('压缩 (亮)',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
        ],
      ),
    );
  }
}

/// 剖面图底部图例：红点=压缩区 · 蓝点=稀疏区。
class ProfileLegend extends StatelessWidget {
  const ProfileLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xEE0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(const Color(0xFF3B82F6)),
          const SizedBox(width: 6),
          const Text('稀疏区 (负压/波谷)',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          const SizedBox(width: 16),
          _dot(const Color(0xFFE11D48)),
          const SizedBox(width: 6),
          const Text('压缩区 (正压/波峰)',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}
