/// Chart Intro Full Chart Dialog。静态 PNG，不改 chart state。
///
/// [已确认] `FullChartTextButton.ts`：`new Image(fullNuclideChart_png)` + sun `Dialog`
/// 无缩放、无拖动 listener。
library;

import 'package:flutter/material.dart';

import '../../ban_constants.dart';
import '../chart_intro_visuals.dart';

class FullChartDialog extends StatelessWidget {
  const FullChartDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.shortestSide < 400;
    return Dialog(
      key: const ValueKey('chart_intro_full_chart_dialog'),
      backgroundColor: const Color(BanConstants.infoDialogBackgroundValue),
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 24,
        vertical: compact ? 8 : 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: size.height - (compact ? 16 : 32),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            compact ? 12 : ChartIntroVisuals.fullChartDialogTopMargin,
            8,
            compact ? 16 : ChartIntroVisuals.fullChartDialogBottomMargin,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      ChartIntroVisuals.fullChartDialogTitle,
                      key: ValueKey('chart_intro_full_chart_title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ChartIntroVisuals.fullChartTitleFontSize,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('chart_intro_full_chart_close'),
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
              const SizedBox(height: ChartIntroVisuals.fullChartDialogContentSpacing),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: ChartIntroVisuals.fullChartInfoMaxWidth.clamp(
                          80.0,
                          MediaQuery.sizeOf(context).width - 48,
                        ),
                        child: Text(
                          ChartIntroVisuals.fullChartInfoText,
                          key: ValueKey('chart_intro_full_chart_info'),
                          style: TextStyle(
                            fontSize: ChartIntroVisuals.fullChartInfoFontSize,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: ChartIntroVisuals.fullChartDialogContentSpacing,
                      ),
                      Builder(
                        builder: (context) {
                          final maxW = MediaQuery.sizeOf(context).width - 48;
                          final w = maxW < ChartIntroVisuals.fullChartImageMaxWidth
                              ? maxW.clamp(80.0, ChartIntroVisuals.fullChartImageMaxWidth)
                              : ChartIntroVisuals.fullChartImageMaxWidth;
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            padding: const EdgeInsets.all(
                              ChartIntroVisuals.fullChartImageBorderPad,
                            ),
                            child: Image.asset(
                              ChartIntroVisuals.fullChartAsset,
                              key: const ValueKey(
                                'chart_intro_full_chart_image',
                              ),
                              width: w,
                              fit: BoxFit.fitWidth,
                            ),
                          );
                        },
                      ),
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

/// 「Full Chart」按钮。只 `showDialog`，不碰 selectedChart / focus / viewport。
class FullChartButton extends StatefulWidget {
  const FullChartButton({super.key});

  @override
  State<FullChartButton> createState() => _FullChartButtonState();
}

class _FullChartButtonState extends State<FullChartButton> {
  bool _open = false;
  NavigatorState? _navigator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigator = Navigator.of(context, rootNavigator: true);
  }

  Future<void> _openDialog() async {
    if (_open) return;
    _open = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const FullChartDialog(),
    );
    _open = false;
  }

  @override
  void dispose() {
    // [有意差异] 原版 Screen 常驻，Dialog 不随切屏 dispose。
    // 本工程 Tab 会拆掉 ChartIntroScreen，关 Dialog 以免泄漏。
    if (_open) {
      _navigator?.pop();
      _open = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: const ValueKey('chart_intro_full_chart'),
      onPressed: _openDialog,
      style: OutlinedButton.styleFrom(
        backgroundColor: ChartIntroVisuals.fullChartButtonFill,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black),
        minimumSize: const Size(88, 28),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(fontSize: ChartIntroVisuals.legendFontSize),
      ),
      child: const Text(ChartIntroVisuals.fullChartButtonLabel),
    );
  }
}
