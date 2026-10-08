/// Make Isotopes (Isotopes screen) — PhET IsotopesScreenView.
library;

import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../controller/make_isotopes_controller.dart';
import '../iaam_constants.dart';
import '../transform/iaam_transform.dart';
import '../painters/electron_cloud_painter.dart';
import '../widgets/atom_scale_widget.dart';
import '../widgets/expanded_periodic_table.dart';
import '../widgets/iaam_page_shell.dart';
import '../widgets/make_isotope_play_area.dart';
import '../widgets/particle_count_display.dart';
import '../widgets/sim_coord_scope.dart';
import '../widgets/symbol_abundance_panels.dart';

class MakeIsotopesScreen extends StatefulWidget {
  const MakeIsotopesScreen({
    super.key,
    this.controller,
    this.embedded = false,
    this.tickOnClock,
  });

  final MakeIsotopesController? controller;
  final bool embedded;

  /// When null, ticks iff this screen owns the controller.
  final bool? tickOnClock;

  @override
  State<MakeIsotopesScreen> createState() => _MakeIsotopesScreenState();
}

class _MakeIsotopesScreenState extends State<MakeIsotopesScreen>
    with TickerProviderStateMixin {
  late final MakeIsotopesController _controller;
  late final bool _ownsController;
  late final bool _tickOnClock;
  final GlobalKey _simKey = GlobalKey();
  final IaamTransform _transform = IaamTransform.makeScreen();
  int _placedForElectrons = -1;

  /// ExpandedPeriodicTable intrinsic for Make Z≤10 (2 rows).
  static const double _ptUnscaledW = 9 * 50.0; // 450
  static const double _ptUnscaledH = 28 + 5 + 36 + 20 + 2 * 50.0; // ~189

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _tickOnClock = widget.tickOnClock ?? _ownsController;
    _controller = widget.controller ?? MakeIsotopesController();
    if (_tickOnClock) {
      _controller.attach(this);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncAtomOnScale());
  }

  /// Keep the cloud sitting on the pan so nucleons/cloud do not cover
  /// Mass Number / Atomic Mass (PhET live electron-cloud bounds).
  void _syncAtomOnScale() {
    if (!mounted) return;
    final electrons = _controller.model.electronCount;
    final scaleBottom =
        IaamConstants.layoutHeight - IaamConstants.scaleBottomOffset;
    final scaleTop = scaleBottom - IaamConstants.scaleImageHeight;
    final bottomOfAtomY = scaleTop + IaamConstants.atomBottomOnScaleOffset;
    final cloudR = electronCloudRadiusFor(electrons);
    final atomViewY = bottomOfAtomY - cloudR;
    final model = _transform.viewToModel(IaamConstants.mvtViewX, atomViewY);
    if (_placedForElectrons == electrons &&
        (model.dx - _controller.model.atomX).abs() < 0.5 &&
        (model.dy - _controller.model.atomY).abs() < 0.5) {
      return;
    }
    _placedForElectrons = electrons;
    _controller.setAtomPosition(model.dx, model.dy);
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
            if (_placedForElectrons != _controller.model.electronCount) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _syncAtomOnScale());
            }
            // PhET: PT scale 0.65; symbolBox.top = PT.bottom + 10
            const scale = IaamConstants.periodicTableScale;
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
                    Positioned(
                      left: IaamConstants.mvtViewX -
                          IaamConstants.scaleImageWidth / 2,
                      bottom: IaamConstants.scaleBottomOffset,
                      child: AtomScaleWidget(
                        controller: _controller,
                        showImage: true,
                        showReadout: false,
                      ),
                    ),
                    Positioned.fill(
                      child: MakeIsotopePlayArea(
                        controller: _controller,
                        transform: _transform,
                      ),
                    ),
                    Positioned(
                      left: IaamConstants.mvtViewX -
                          IaamConstants.scaleImageWidth / 2,
                      bottom: IaamConstants.scaleBottomOffset,
                      child: AtomScaleWidget(
                        controller: _controller,
                        showImage: false,
                        showReadout: true,
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 10,
                      child: ParticleCountDisplay(controller: _controller),
                    ),

                    // Right column — PhET AccordionBox: sibling tops are fixed
                    // from expanded heights, so collapse does not shift panels below
                    // (gap appears like published Mix when Percent is collapsed).
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
                                  selectedZ: _controller.model.protonCount,
                                  interactiveMax: 10,
                                  onSelect: _controller.selectElement,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: ptH + 10,
                            left: 0,
                            width: panelW,
                            child: SymbolAccordion(
                              controller: _controller,
                              width: panelW,
                            ),
                          ),
                          Positioned(
                            top: ptH +
                                10 +
                                IaamConstants.makeSymbolExpandedH +
                                10,
                            left: 0,
                            width: panelW,
                            child: AbundanceAccordion(
                              controller: _controller,
                              width: panelW,
                            ),
                          ),
                        ],
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
      appBar: AppBar(title: const Text('同位素')),
      body: body,
    );
  }
}
