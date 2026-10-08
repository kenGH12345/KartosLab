import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../constants/baa_constants.dart';
import '../model/baa_model.dart';
import '../transform/baa_transform.dart';
import '../view/atom_view_state.dart';
import '../view/baa_page_shell.dart';
import '../widgets/atom_appearance_checkboxes.dart';
import '../widgets/baa_accordion_box.dart';
import '../widgets/baa_periodic_table.dart';
import '../widgets/baa_scaled_box.dart';
import '../widgets/charge_comparison_display.dart';
import '../widgets/charge_meter.dart';
import '../widgets/electron_model_control.dart';
import '../widgets/interactive_atom_play_area.dart';
import '../widgets/mass_number_display.dart';
import '../widgets/particle_count_panel.dart';
import 'package:kratos/chemistry/build_an_atom/baa_strings.dart';

/// Build an Atom — Atom Screen (PhET `AtomScreen` / `AtomScreenView`).
class BuildAnAtomAtomScreen extends StatefulWidget {
  const BuildAnAtomAtomScreen({super.key, this.model, this.embedded = false});

  /// Optional injected model (tests).
  final BAAModel? model;

  /// When true (Home tab), omit Scaffold AppBar — parent provides chrome.
  final bool embedded;

  static const title = 'Build an Atom';
  static const subtitle = 'Atom Screen';

  @override
  State<BuildAnAtomAtomScreen> createState() => BuildAnAtomAtomScreenState();
}

class BuildAnAtomAtomScreenState extends State<BuildAnAtomAtomScreen>
    with SingleTickerProviderStateMixin {
  /// Width of right accordion column (PhET PT @0.55 ≈ 247.5 + chrome).
  static const double _accordionPanelW = 260;

  /// VBox spacing — PhET `accordionBoxes` spacing: 7.
  static const double _accGap = 7;

  /// Accordion header row (button 18 + vertical pad 8).
  static const double _accHeaderH = 26;

  /// Expanded body bottom pad (`EdgeInsets.fromLTRB(8,0,8,8)`).
  static const double _accBodyPad = 8;

  /// `BaaPeriodicTable` @0.55: intrinsicH 202.5 × scale.
  static const double _ptBodyH = 202.5 * 0.55;

  /// Net Charge `BaaScaledBox` height 70 × 0.85.
  static const double _netBodyH = 70 * 0.85;

  /// Fixed seats = expanded height (collapse keeps blank, headers do not shift).
  static double get _ptSeatH => _accHeaderH + _ptBodyH + _accBodyPad;
  static double get _netSeatH => _accHeaderH + _netBodyH + _accBodyPad;

  late final BAAModel _model;
  late final bool _ownsModel;
  late final AtomViewState _viewState;
  late final BaaTransform _transform;
  late final Ticker _ticker;
  final GlobalKey _simKey = GlobalKey();
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    _ownsModel = widget.model == null;
    _model = widget.model ?? BAAModel();
    _viewState = AtomViewState(_model);
    _transform = BaaTransform.atomScreen();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final last = _lastTick;
    _lastTick = elapsed;
    if (last == null) return;
    final dt = (elapsed - last).inMicroseconds / 1e6;
    if (dt <= 0 || dt > 0.1) return;
    _model.step(dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _viewState.dispose();
    if (_ownsModel) {
      _model.dispose();
    }
    super.dispose();
  }

  void _resetAll() {
    _model.reset();
    _viewState.reset();
  }

  @override
  Widget build(BuildContext context) {
    final inset = BAAConstants.controlsInset.toDouble();
    final play = BaaPageShell(
      child: ColoredBox(
        color: Colors.white,
        child: KeyedSubtree(
          key: _simKey,
          // Z-order matches PhET BAAScreenView: electronModel → checkboxes →
          // counts → accordionBoxes → interactiveAtom → reset.
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Electron model (under accordions when they expand over it)
              ListenableBuilder(
                listenable: _model,
                builder: (context, _) {
                  final atomCenter = _transform.modelToView(0, 0);
                  return Positioned(
                    left: atomCenter.dx + 149,
                    top: atomCenter.dy + 62,
                    child: ElectronModelControl(
                      value: _model.electronModel.type,
                      onChanged: _viewState.setElectronModel,
                    ),
                  );
                },
              ),
              Positioned(
                left: inset,
                top: inset,
                child: ParticleCountPanel(model: _model),
              ),
              // Right accordion column — absolute seats at PhET expanded Y
              // (natural content size; collapse leaves blank, headers stay).
              ListenableBuilder(
                listenable: Listenable.merge([_model, _viewState]),
                builder: (context, _) {
                  final ptTop = inset;
                  final netTop = ptTop + _ptSeatH + _accGap;
                  final massTop = netTop + _netSeatH + _accGap;
                  return Stack(
                    children: [
                      Positioned(
                        right: inset,
                        top: ptTop,
                        width: _accordionPanelW,
                        child: BaaAccordionBox(
                          title: '元素周期表',
                          expanded: _viewState.periodicTableExpanded,
                          onToggle: () => _viewState.setPeriodicTableExpanded(
                              !_viewState.periodicTableExpanded),
                          minWidth: _accordionPanelW,
                          child: BaaPeriodicTable(
                            selectedZ: _model.protonCount,
                            scale: 0.55,
                          ),
                        ),
                      ),
                      Positioned(
                        right: inset,
                        top: netTop,
                        width: _accordionPanelW,
                        child: BaaAccordionBox(
                          title: '净电荷',
                          expanded: _viewState.netChargeExpanded,
                          onToggle: () => _viewState.setNetChargeExpanded(
                              !_viewState.netChargeExpanded),
                          minWidth: _accordionPanelW,
                          child: BaaScaledBox(
                            scale: 0.85,
                            intrinsicWidth: 250,
                            intrinsicHeight: 70,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ChargeMeter(charge: _model.charge),
                                const SizedBox(width: 5),
                                ChargeComparisonDisplay(
                                  protonCount: _model.protonCount,
                                  electronCount: _model.electronCount,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: inset,
                        top: massTop,
                        width: _accordionPanelW,
                        child: BaaAccordionBox(
                          title: BaaStrings.massNumber,
                          expanded: _viewState.massNumberExpanded,
                          onToggle: () => _viewState.setMassNumberExpanded(
                              !_viewState.massNumberExpanded),
                          minWidth: _accordionPanelW,
                          child: BaaScaledBox(
                            scale: 0.85,
                            intrinsicWidth: 122,
                            intrinsicHeight: 72,
                            child: MassNumberDisplay(
                              massNumber: _model.massNumber,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              // Checkboxes under Mass Number seat, left of Reset (PhET).
              Positioned(
                right: inset,
                bottom: inset * 2,
                width: _accordionPanelW,
                child: ListenableBuilder(
                  listenable: _viewState,
                  builder: (context, _) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: BAAConstants.resetButtonRadius * 2 + 8,
                      ),
                      child: AtomAppearanceCheckboxes(viewState: _viewState),
                    );
                  },
                ),
              ),
              // Atom / buckets on top of panels for drag (PhET interactiveAtomNode)
              InteractiveAtomPlayArea(
                model: _model,
                viewState: _viewState,
                transform: _transform,
                simKey: _simKey,
                rightReserved: inset + _accordionPanelW,
              ),
              Positioned(
                right: inset,
                bottom: inset,
                child: KratosResetAllButton(
                  onPressed: _resetAll,
                  radius: BAAConstants.resetButtonRadius,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (widget.embedded) return play;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(BaaStrings.atom),
        backgroundColor: const Color(0xFF1177AA),
        foregroundColor: Colors.white,
        actions: [
          if (Navigator.of(context).canPop())
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('返回', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: play,
    );
  }
}
