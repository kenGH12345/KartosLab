/// Vertical zoom: + / slider / −  in top-left. Range 0.5–1.3.
library;

import 'package:flutter/material.dart';

import '../controller/gao_controller.dart';
import '../gao_colors.dart';

class ZoomControl extends StatelessWidget {
  const ZoomControl({super.key, required this.controller});

  final GaoController controller;

  @override
  Widget build(BuildContext context) {
    final zoom = controller.model.scene.zoomLevel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _roundBtn(
          label: '+',
          onPressed: zoom < GaoConstants.zoomMax
              ? () => controller.setZoomLevel(zoom + GaoConstants.zoomStep)
              : null,
        ),
        SizedBox(
          height: 120,
          child: RotatedBox(
            quarterTurns: -1,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.white,
                inactiveTrackColor: const Color(0xFF555555),
                thumbColor: Colors.white,
                trackHeight: 3,
              ),
              child: Slider(
                value: zoom.clamp(GaoConstants.zoomMin, GaoConstants.zoomMax),
                min: GaoConstants.zoomMin,
                max: GaoConstants.zoomMax,
                onChanged: controller.setZoomLevel,
              ),
            ),
          ),
        ),
        _roundBtn(
          label: '−',
          onPressed: zoom > GaoConstants.zoomMin
              ? () => controller.setZoomLevel(zoom - GaoConstants.zoomStep)
              : null,
        ),
      ],
    );
  }

  Widget _roundBtn({required String label, required VoidCallback? onPressed}) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: const Color(0xFF2A2A2A),
        shape: const CircleBorder(
          side: BorderSide(color: GaoColors.controlPanelStroke),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: onPressed != null
                    ? GaoColors.foreground
                    : GaoColors.foreground.withValues(alpha: 0.35),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
