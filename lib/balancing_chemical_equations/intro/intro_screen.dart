import 'package:flutter/material.dart';
import 'package:kratos/balancing_chemical_equations/bce_constants.dart';
import 'package:kratos/balancing_chemical_equations/intro/intro_feedback_node.dart';
import 'package:kratos/balancing_chemical_equations/intro/intro_model.dart';
import 'package:kratos/balancing_chemical_equations/model/view_mode.dart';
import 'package:kratos/balancing_chemical_equations/views/balance_scales_node.dart';
import 'package:kratos/balancing_chemical_equations/views/bar_charts_node.dart';
import 'package:kratos/balancing_chemical_equations/views/bce_equation_node.dart';
import 'package:kratos/balancing_chemical_equations/views/horizontal_aligner.dart';
import 'package:kratos/balancing_chemical_equations/views/particles_node.dart';
import 'package:kratos/balancing_chemical_equations/views/view_combo_box.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

/// PhET `IntroScreen` / `IntroScreenView` — layoutBounds 768×504.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, this.model});

  final IntroModel? model;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late final IntroModel _model;
  late final bool _ownsModel;

  static const _boxSize = Size(285, 145);
  static const _boxXSpacing = 110.0;
  static const _bg = Color(0xFFD9EBFF);
  static const _barColor = Color(0xFF3376C4);
  static const _barHeight = 50.0;

  @override
  void initState() {
    super.initState();
    _ownsModel = widget.model == null;
    _model = widget.model ?? IntroModel();
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
    final vizBottom = equationBottom - 90 - 20;

    return Stack(
      children: [
        // Visualization area
        Positioned(
          left: 0,
          right: 0,
          bottom: layoutH - vizBottom,
          child: SizedBox(
            height: _boxSize.height + 40,
            child: _buildVisualization(aligner),
          ),
        ),

        // Feedback top-left
        Positioned(
          left: aligner.reactantsBoxLeft,
          top: 10,
          child: IntroFeedbackNode(equation: equation),
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

        // Equation
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

        // Equation radios — source: left=50, spacing=30, font 16 white
        Positioned(
          left: 50,
          top: barTop,
          height: _barHeight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < _model.equations.length; i++) ...[
                if (i > 0) const SizedBox(width: 30),
                _EquationRadio(
                  label: _model.labelFor(_model.equations[i]),
                  selected: identical(_model.equations[i], equation),
                  onTap: () => _model.selectEquation(_model.equations[i]),
                ),
              ],
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
          coefficientsMax: IntroModel.coefficientsRange.max,
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

class _EquationRadio extends StatelessWidget {
  const _EquationRadio({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.white,
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2E6BB2),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
