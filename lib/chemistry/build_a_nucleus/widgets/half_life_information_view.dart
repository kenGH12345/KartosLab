/// Decay 屏半衰期信息区：info 按钮 + 数轴/读数 + less/more stable。
///
/// 对标 `HalfLifeInformationNode.ts`。只读 Reading（+ dialog 用的元素名）。
library;

import 'package:flutter/material.dart';

import '../ban_constants.dart';
import '../model/half_life_number_line.dart';
import '../painters/half_life_number_line_painter.dart';
import 'half_life_info_dialog.dart';
import 'half_life_number_line_view.dart';
import 'half_life_stability_legend.dart';

class HalfLifeInformationView extends StatefulWidget {
  const HalfLifeInformationView({
    super.key,
    required this.reading,
    this.elementName = '',
    this.readoutLeftInset = true,
  });

  final HalfLifeNumberLineReading reading;

  /// Dialog 在 `isHalfLifeLabelFixed: false` 时显示的元素名。
  /// 主屏数轴不显示。[已确认] 仅 InfoDialog 传入 elementNameStringProperty
  final String elementName;

  /// Decay 屏为 info 按钮留出缩进。[已确认]
  final bool readoutLeftInset;

  static const double legendHeight = 28;

  static double get height =>
      HalfLifeNumberLineView.height + legendHeight;

  @override
  State<HalfLifeInformationView> createState() =>
      _HalfLifeInformationViewState();
}

class _HalfLifeInformationViewState extends State<HalfLifeInformationView> {
  late final ValueNotifier<HalfLifeInfoDialogData> _dialogData;
  bool _dialogOpen = false;
  NavigatorState? _navigator;

  @override
  void initState() {
    super.initState();
    _dialogData = ValueNotifier(_snapshot());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigator = Navigator.of(context, rootNavigator: true);
  }

  @override
  void didUpdateWidget(covariant HalfLifeInformationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reading != widget.reading ||
        oldWidget.elementName != widget.elementName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _dialogData.value = _snapshot();
      });
    }
  }

  HalfLifeInfoDialogData _snapshot() => HalfLifeInfoDialogData(
        reading: widget.reading,
        elementName: widget.elementName,
      );

  Future<void> _openDialog() async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ValueListenableBuilder<HalfLifeInfoDialogData>(
        valueListenable: _dialogData,
        builder: (_, data, child) => HalfLifeInfoDialog(data: data),
      ),
    );
    _dialogOpen = false;
  }

  @override
  void dispose() {
    if (_dialogOpen) {
      _navigator?.pop();
      _dialogOpen = false;
    }
    _dialogData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = widget.readoutLeftInset
        ? BanConstants.halfLifeReadoutLeftInset
        : 0.0;
    return Column(
      key: const ValueKey('ban_half_life_information'),
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: HalfLifeNumberLineView.height,
          child: Stack(
            children: [
              HalfLifeNumberLineView(
                reading: widget.reading,
                readoutLeftInset: inset,
              ),
              if (widget.readoutLeftInset)
                Positioned(
                  left: BanConstants.infoButtonIndentDistance,
                  top: (HalfLifeNumberLineMetrics.readoutBandHeight -
                          BanConstants.infoButtonMaxHeight) /
                      2,
                  child: _InfoButton(onPressed: _openDialog),
                ),
            ],
          ),
        ),
        const SizedBox(
          height: HalfLifeInformationView.legendHeight,
          child: HalfLifeStabilityLegend(),
        ),
      ],
    );
  }
}

/// [已确认] scenery-phet InfoButton：圆钮、iconFill black、maxHeight 30、
/// baseColor 粉。图标路径用 Material `Icons.info` 代替 infoCircleSolidShape
/// [推测 visual]。
class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const size = BanConstants.infoButtonMaxHeight;
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: const Color(BanConstants.infoButtonColorValue),
        shape: const CircleBorder(),
        child: InkWell(
          key: const ValueKey('ban_half_life_info_button'),
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Icon(Icons.info, color: Colors.black, size: 22),
        ),
      ),
    );
  }
}
