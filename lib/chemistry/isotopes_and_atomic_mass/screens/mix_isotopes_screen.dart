/// Mix Isotopes (Mixtures screen) — PhET MixturesScreenView layout.
library;

import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../controller/mixtures_controller.dart';
import '../iaam_constants.dart';
import '../iaam_strings.dart';
import '../model/mixtures_constants.dart';
import '../transform/iaam_transform.dart';
import '../widgets/expanded_periodic_table.dart';
import '../widgets/iaam_page_shell.dart';
import '../widgets/mix_play_area.dart';
import '../widgets/mix_selection_controls.dart';
import '../widgets/mix_statistics_panels.dart';
import '../widgets/sim_coord_scope.dart';

class MixIsotopesScreen extends StatefulWidget {
  const MixIsotopesScreen({
    super.key,
    this.controller,
    this.embedded = false,
    this.tickOnClock,
  });

  final MixturesController? controller;
  final bool embedded;
  final bool? tickOnClock;

  @override
  State<MixIsotopesScreen> createState() => _MixIsotopesScreenState();
}

class _MixIsotopesScreenState extends State<MixIsotopesScreen>
    with TickerProviderStateMixin {
  late final MixturesController _controller;
  late final bool _ownsController;
  late final bool _tickOnClock;
  final GlobalKey _simKey = GlobalKey();
  final IaamTransform _transform = IaamTransform.mixScreen();

  /// ExpandedPeriodicTable intrinsic (unscaled) for Mix Z≤18 (3 rows).
  static const double _ptUnscaledW = 9 * 50.0; // 450
  static const double _ptUnscaledH = 28 + 5 + 36 + 20 + 3 * 50.0; // ~239

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _tickOnClock = widget.tickOnClock ?? _ownsController;
    _controller = widget.controller ?? MixturesController();
    if (_tickOnClock) {
      _controller.attach(this);
    }
  }

  @override
  void dispose() {
    if (_tickOnClock) {
      _controller.clock.pause();
    }
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Material(
      color: const Color(0xFFF0F0F0),
      child: IaamPageShell(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final m = _controller.model;
            final chamberTL =
                _transform.modelToView(kTestChamberMinX, kTestChamberMaxY);
            final chamberBR =
                _transform.modelToView(kTestChamberMaxX, kTestChamberMinY);
            final chamberBottom = chamberBR.dy;
            final chamberLeft = chamberTL.dx;
            final chamberRight = chamberBR.dx;

            // PhET: PT scale 0.55; panels match visual PT width.
            const scale = IaamConstants.mixPeriodicTableScale;
            final panelW = _ptUnscaledW * scale;
            final ptH = _ptUnscaledH * scale;

            return SimCoordScope(
              simKey: _simKey,
              child: SizedBox(
                key: _simKey,
                width: IaamConstants.layoutWidth,
                height: IaamConstants.layoutHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Right column first so Mix play (with drag Listener) sits
                    // on top of the left/bottom, like Build an Atom.
                    Positioned(
                      right: IaamConstants.periodicTableRightInset,
                      top: IaamConstants.periodicTableTop,
                      width: panelW,
                      height: IaamConstants.layoutHeight -
                          IaamConstants.periodicTableTop -
                          8,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            width: panelW,
                            height: ptH,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              alignment: Alignment.topRight,
                              child: SizedBox(
                                width: _ptUnscaledW,
                                height: _ptUnscaledH,
                                child: ExpandedPeriodicTable(
                                  selectedZ: m.selectedAtomicNumber,
                                  interactiveMax: kMixMaxAtomicNumber,
                                  onSelect: _controller.selectElement,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: ptH + 15,
                            left: 0,
                            width: panelW,
                            child: MixAccordionShell(
                              title: '百分组成',
                              width: panelW,
                              expanded: _controller.compositionExpanded,
                              onToggle: () =>
                                  _controller.setCompositionExpanded(
                                !_controller.compositionExpanded,
                              ),
                              child: IsotopeProportionsPieChart(
                                controller: _controller,
                              ),
                            ),
                          ),
                          Positioned(
                            top: ptH +
                                15 +
                                IaamConstants.mixCompositionExpandedH +
                                10,
                            left: 0,
                            width: panelW,
                            child: MixAccordionShell(
                              title: IaamStrings.averageAtomicMass,
                              width: panelW,
                              expanded: _controller.averageMassExpanded,
                              onToggle: () =>
                                  _controller.setAverageMassExpanded(
                                !_controller.averageMassExpanded,
                              ),
                              child: AverageAtomicMassIndicator(
                                controller: _controller,
                              ),
                            ),
                          ),
                          Positioned(
                            top: ptH +
                                15 +
                                IaamConstants.mixCompositionExpandedH +
                                10 +
                                IaamConstants.mixAverageExpandedH +
                                10,
                            left: 0,
                            width: panelW,
                            child: IsotopeMixtureSelection(
                              controller: _controller,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      left: 0,
                      top: 0,
                      right: panelW + IaamConstants.periodicTableRightInset,
                      bottom: 0,
                      child: MixPlayArea(
                        controller: _controller,
                        transform: _transform,
                      ),
                    ),

                    // Eraser: chamber.bottom+5, chamber.left
                    if (!m.showingNaturesMix)
                      Positioned(
                        left: chamberLeft,
                        top: chamberBottom + 5,
                        child: MixEraserButton(onPressed: _controller.clear),
                      ),

                    // Mode radios: right=chamber.right, top=chamber.bottom+5
                    if (!m.showingNaturesMix)
                      Positioned(
                        left: chamberRight - 98,
                        top: chamberBottom + 5,
                        child: InteractivityModeSelection(
                          controller: _controller,
                        ),
                      ),

                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: KratosResetAllButton(
                        onPressed: _controller.reset,
                        radius: IaamConstants.resetRadius,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('混合物')),
      body: body,
    );
  }
}
