/// 周期表静态视图。无点击 / hover / tooltip。
library;

import 'package:flutter/material.dart';

import '../model/periodic_table_reading.dart';
import '../painters/periodic_table_painter.dart';
import '../render/periodic_table_render.dart';

class PeriodicTableView extends StatelessWidget {
  const PeriodicTableView({super.key, required this.render});

  factory PeriodicTableView.fromReading(
    PeriodicTableReading reading, {
    Key? key,
  }) =>
      PeriodicTableView(
        key: key,
        render: PeriodicTableRender.from(reading),
      );

  final PeriodicTableRender render;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: render.paintedSize,
        painter: PeriodicTablePainter(render: render),
      ),
    );
  }
}
