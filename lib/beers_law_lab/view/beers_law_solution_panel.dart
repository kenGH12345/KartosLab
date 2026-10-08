import 'package:flutter/material.dart';

import '../bll_strings.dart';
import '../model/beers_law_model.dart';
import '../model/beers_law_solution.dart';
import '../model/concentration_transform.dart';
import 'beers_law_layout.dart';

/// PhET `SolutionPanel` — solution combo + concentration NumberControl.
class BeersLawSolutionPanel extends StatelessWidget {
  const BeersLawSolutionPanel({
    super.key,
    required this.model,
    required this.left,
    required this.top,
  });

  final BeersLawModel model;
  final double left;
  final double top;

  @override
  Widget build(BuildContext context) {
    final s = model.solution;
    final unit = s.concentrationTransform.unitLabel;
    final display = s.displayConcentration.round();

    return Positioned(
      left: left,
      top: top,
      child: Container(
        key: const Key('beers_law_solution_panel'),
        width: 420,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: BeersLawLayout.panelFill,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('${BllStrings.solution}：', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: _SolutionSelector(model: model),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Text('${BllStrings.concentration}：', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Text(
                    '$display $unit',
                    key: const Key('beers_law_concentration_value'),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '0',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 10,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                      ),
                    ),
                    child: Slider(
                      key: const Key('beers_law_concentration_slider'),
                      min: s.displayConcentrationMin,
                      max: s.displayConcentrationMax,
                      value: s.displayConcentration.clamp(
                        s.displayConcentrationMin,
                        s.displayConcentrationMax,
                      ),
                      activeColor: s.colorRange.max,
                      inactiveColor: s.colorRange.min,
                      onChanged: (v) {
                        final snapped = (v / 5).round() * 5.0;
                        model.setDisplayConcentration(
                          snapped.clamp(
                            s.displayConcentrationMin,
                            s.displayConcentrationMax,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Text(
                  s.displayConcentrationMax.round().toString(),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
            Text(
              s.concentrationTransform.unit == ConcentrationUnit.micromolar
                  ? 'µM'
                  : 'mM',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolutionSelector extends StatelessWidget {
  const _SolutionSelector({required this.model});

  final BeersLawModel model;

  @override
  Widget build(BuildContext context) {
    final s = model.solution;
    return PopupMenuButton<BeersLawSolution>(
      key: const Key('beers_law_solution_selector'),
      initialValue: s,
      onSelected: model.setSolution,
      itemBuilder: (context) => model.solutions
          .map(
            (sol) => PopupMenuItem(
              value: sol,
              child: Row(
                children: [
                  Container(width: 16, height: 16, color: sol.colorRange.max),
                  const SizedBox(width: 8),
                  Text(sol.formula ?? sol.name),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black45),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(width: 16, height: 16, color: s.colorRange.max),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                s.formula ?? s.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20), // combo chrome, not PhET asset sub
          ],
        ),
      ),
    );
  }
}
