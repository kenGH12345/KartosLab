import 'package:flutter/material.dart';

import '../curve_fitting_colors.dart';
import '../curve_fitting_constants.dart';
import '../model/curve_fitting_model.dart';
import '../transform/math_coordinate_transform.dart';
import 'bucket_widget.dart';
import 'data_point_widget.dart';

/// Minimal harness for drag / hit-test tests (no side panels).
///
/// Uses the same gutter + graph MVT as production so the bucket stays on-screen.
class CfDragTestHarness extends StatefulWidget {
  const CfDragTestHarness({super.key, required this.model});

  final CurveFittingModel model;

  @override
  State<CfDragTestHarness> createState() => CfDragTestHarnessState();
}

class CfDragTestHarnessState extends State<CfDragTestHarness> {
  final GlobalKey interactionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_onStructural);
  }

  @override
  void didUpdateWidget(CfDragTestHarness oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) {
      oldWidget.model.removeListener(_onStructural);
      widget.model.addListener(_onStructural);
    }
  }

  @override
  void dispose() {
    widget.model.removeListener(_onStructural);
    super.dispose();
  }

  void _onStructural() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    return ColoredBox(
      color: CurveFittingColors.screenBackground,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final colW = CurveFittingConstants.columnOuterWidth;
          final graphW = (w - 2 * colW).clamp(1.0, w);
          final transform = MathCoordinateTransform.forGraphViewport(
            Size(graphW, h),
            viewOriginInParent: Offset(colW + graphW / 2, h / 2),
          );
          return Stack(
            key: interactionKey,
            clipBehavior: Clip.none,
            children: [
              BucketWidget(
                model: model,
                transform: transform,
                layoutKey: interactionKey,
              ),
              for (final p in model.points.points)
                DataPointWidget(
                  key: ObjectKey(p),
                  model: model,
                  point: p,
                  transform: transform,
                  layoutKey: interactionKey,
                ),
            ],
          );
        },
      ),
    );
  }
}
