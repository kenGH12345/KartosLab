import 'package:flutter/material.dart';

import '../controller/one_dimension_controller.dart';
import '../normal_modes_constants.dart';
import '../normal_modes_strings.dart';
import '../painters/mode_graph_painter.dart';
import '../render/nm_render_data.dart';
import 'nm_accordion.dart';

class ModesAccordion extends StatelessWidget {
  const ModesAccordion({
    super.key,
    required this.controller,
    required this.data,
  });

  final OneDimensionController controller;
  final NmRenderData data;

  @override
  Widget build(BuildContext context) {
    return NmAccordion(
      title: NormalModesStrings.title,
      expanded: controller.modesExpanded,
      onExpandedChanged: controller.setModesExpanded,
      titleAlign: Alignment.center,
      expandButtonSize: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < data.numberOfMasses; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: NormalModesConstants.modeNumberFontSize,
                    ),
                  ),
                  const SizedBox(width: 7),
                  AnimatedModeGraph(graph: data.modeGraphs[i]),
                ],
              ),
            ),
          const SizedBox(
            width: NormalModesConstants.modeGraphWidth + 24,
            height: 1,
          ),
        ],
      ),
    );
  }
}
