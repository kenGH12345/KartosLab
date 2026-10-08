/// Half-Life Timescale info dialog。
///
/// 对标 `HalfLifeInfoDialog.ts`：标题、A–J 图例、展开数轴。
/// 内容只读传入的 Reading + 元素名，不查表。
library;

import 'package:flutter/material.dart';

import '../ban_constants.dart';
import '../model/ban_timescale_points.dart';
import '../model/half_life_number_line.dart';
import '../painters/half_life_number_line_painter.dart';
import 'half_life_number_line_view.dart';
import 'package:kratos/chemistry/build_a_nucleus/ban_strings.dart';

class HalfLifeInfoDialogData {
  const HalfLifeInfoDialogData({
    required this.reading,
    required this.elementName,
  });

  final HalfLifeNumberLineReading reading;
  final String elementName;
}

class HalfLifeInfoDialog extends StatelessWidget {
  const HalfLifeInfoDialog({super.key, required this.data});

  final HalfLifeInfoDialogData data;

  /// [已确认] halfLifeTimescale = "Half-Life Timescale"
  static const String title = BanStrings.halfLifeTimescale;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const ValueKey('ban_half_life_info_dialog'),
      backgroundColor: const Color(BanConstants.infoDialogBackgroundValue),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      title,
                      key: ValueKey('ban_half_life_info_title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('ban_half_life_info_close'),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: BanConstants.closeIconSize,
                    ),
                    tooltip: '关闭',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const _TimescaleLegend(),
                      const SizedBox(height: 30),
                      if (data.elementName.isNotEmpty)
                        Text(
                          data.elementName,
                          key: const ValueKey('ban_half_life_info_element'),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Color(0xFFFF0000),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      _DialogNumberLine(reading: data.reading),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimescaleLegend extends StatelessWidget {
  const _TimescaleLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('ban_half_life_info_legend'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _LegendColumn(points: BanTimescalePoints.leftColumn)),
        const SizedBox(width: 24),
        Expanded(child: _LegendColumn(points: BanTimescalePoints.rightColumn)),
      ],
    );
  }
}

class _LegendColumn extends StatelessWidget {
  const _LegendColumn({required this.points});

  final List<BanTimescalePoint> points;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in points)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    p.marker,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text('- ', style: TextStyle(fontSize: 20)),
                Expanded(
                  child: Text(
                    p.description,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Dialog 内数轴：复用 [HalfLifeNumberLineView]，叠加 A–J 标记。
class _DialogNumberLine extends StatelessWidget {
  const _DialogNumberLine({required this.reading});

  final HalfLifeNumberLineReading reading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : HalfLifeChartTransform.originalViewWidth;
        const axisTop = HalfLifeNumberLineMetrics.readoutBandHeight;
        const axisY = axisTop + HalfLifeNumberLineMetrics.axisY;
        return SizedBox(
          width: w,
          height: HalfLifeNumberLineView.height + 20,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              HalfLifeNumberLineView(reading: reading),
              for (final p in BanTimescalePoints.all)
                Positioned(
                  key: ValueKey('ban_half_life_timescale_${p.marker}'),
                  left: HalfLifeChartTransform.modelToViewX(
                    p.pointerExponent,
                    w,
                  ),
                  top: axisY - 18,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -1),
                    child: Text(
                      p.marker,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(BanConstants.legendArrowColorValue),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
