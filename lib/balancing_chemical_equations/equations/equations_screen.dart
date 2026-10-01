import 'package:flutter/material.dart';
import 'package:kratos/balancing_chemical_equations/bce_constants.dart';
import 'package:kratos/balancing_chemical_equations/equations/equations_combo_box.dart';
import 'package:kratos/balancing_chemical_equations/equations/equations_feedback_node.dart';
import 'package:kratos/balancing_chemical_equations/equations/equations_model.dart';
import 'package:kratos/balancing_chemical_equations/equations/reaction_type_radio_button_group.dart';
import 'package:kratos/balancing_chemical_equations/model/view_mode.dart';
import 'package:kratos/balancing_chemical_equations/views/balance_scales_node.dart';
import 'package:kratos/balancing_chemical_equations/views/bar_charts_node.dart';
import 'package:kratos/balancing_chemical_equations/views/bce_equation_node.dart';
import 'package:kratos/balancing_chemical_equations/views/horizontal_aligner.dart';
import 'package:kratos/balancing_chemical_equations/views/particles_node.dart';
import 'package:kratos/balancing_chemical_equations/views/view_combo_box.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

/// PhET `EquationsScreen` / `EquationsScreenView` — layoutBounds 768×504.
///
/// Source BOX_SIZE = 285×260 (taller than Intro 285×145).
class EquationsScreen extends StatefulWidget {
  const EquationsScreen({super.key, this.model});

  final EquationsModel? model;

  @override
  State<EquationsScreen> createState() => _EquationsScreenState();
}

class _EquationsScreenState extends State<EquationsScreen> {
  late final EquationsModel _model;
  late final bool _ownsModel;

  static const _boxSize = Size(285, 260);
  static const _boxXSpacing = 110.0;
  static const _bg = Color(0xFFD9EBFF);
  static const _barColor = Color(0xFF3376C4);
  static const _barHeight = 50.0;

  @override
  void initState() {
    super.initState();
    _ownsModel = widget.model == null;
    _model = widget.model ?? EquationsModel();
  }

  @override
  void dispose() {
    if (_ownsModel) {
      _model.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _bg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: BceConstants.layoutWidth,
              height: BceConstants.layoutHeight,
              child: ListenableBuilder(
                listenable: _model,
                builder: (context, _) => _buildPlayArea(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayArea() {
    const layoutW = BceConstants.layoutWidth;
    const layoutH = BceConstants.layoutHeight;
    final aligner = HorizontalAligner(
      screenWidth: layoutW,
      boxWidth: _boxSize.width,
      boxXSpacing: _boxXSpacing,
    );
    final equation = _model.selectedEquation;
    final barBottom = layoutH - 10;
    final barTop = barBottom - _barHeight;
    final equationBottom = barTop - 20;
    // particles.bottom = equationNodes.top - 20; equation height ~90
    final vizBottom = equationBottom - 90 - 20;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Visualization
        Positioned(
          left: 0,
          right: 0,
          bottom: layoutH - vizBottom,
          child: SizedBox(
            height: _boxSize.height + 40,
            child: _buildVisualization(aligner),
          ),
        ),

        // Feedback top-left (EquationsFeedbackNode)
        Positioned(
          left: aligner.reactantsBoxLeft,
          top: 10,
          child: EquationsFeedbackNode(equation: equation),
        ),

        // View combo top-right
        Positioned(
          right: 45,
          top: 15,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'View',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              ViewComboBox(
                value: _model.viewMode,
                onChanged: _model.setViewMode,
              ),
            ],
          ),
        ),

        // Equation node
        Positioned(
          left: 0,
          bottom: layoutH - equationBottom,
          child: BceEquationNode(
            equation: equation,
            aligner: aligner,
          ),
        ),

        // Bottom bar
        Positioned(
          left: 0,
          right: 0,
          top: barTop,
          height: _barHeight,
          child: const ColoredBox(color: _barColor),
        ),

        // Bottom chrome: radios + combo (source leftMargin 20, spacing 20)
        Positioned(
          left: 20,
          right: 70,
          top: barTop,
          height: _barHeight,
          child: Row(
            children: [
              ReactionTypeRadioButtonGroup(
                value: _model.reactionType,
                onChanged: _model.setReactionType,
              ),
              const SizedBox(width: 20),
              Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: EquationsComboBox(
                    equations: _model.equationsFor(_model.reactionType),
                    selected: equation,
                    onSelected: _model.selectEquation,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Reset All
        Positioned(
          right: 20,
          top: barTop + (_barHeight - 33) / 2,
          child: Transform.scale(
            scale: 0.8,
            child: KratosResetAllButton(
              onPressed: _model.reset,
              radius: 20.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualization(HorizontalAligner aligner) {
    switch (_model.viewMode) {
      case ViewMode.particles:
        return ParticlesNode(
          equation: _model.selectedEquation,
          aligner: aligner,
          boxSize: _boxSize,
          coefficientsMax: EquationsModel.coefficientsRange.max,
          reactantsExpanded: _model.reactantsExpanded,
          productsExpanded: _model.productsExpanded,
          onToggleReactants: _model.toggleReactants,
          onToggleProducts: _model.toggleProducts,
        );
      case ViewMode.balanceScales:
        return SizedBox(
          width: double.infinity,
          height: _boxSize.height + 20,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            child: BalanceScalesNode(equation: _model.selectedEquation),
          ),
        );
      case ViewMode.barCharts:
        return SizedBox(
          width: double.infinity,
          height: _boxSize.height + 20,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            child: BarChartsNode(equation: _model.selectedEquation),
          ),
        );
      case ViewMode.none:
        return const SizedBox.shrink();
    }
  }
}
