import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../constants/baa_constants.dart';
import '../model/baa_model.dart';
import '../transform/baa_transform.dart';
import '../view/atom_view_state.dart';
import '../view/baa_page_shell.dart';
import '../view/symbol_view_state.dart';
import '../widgets/atom_appearance_checkboxes.dart';
import '../widgets/baa_accordion_box.dart';
import '../widgets/baa_periodic_table.dart';
import '../widgets/baa_symbol_node.dart';
import '../widgets/electron_model_control.dart';
import '../widgets/interactive_atom_play_area.dart';
import '../widgets/particle_count_panel.dart';

/// Build an Atom — Symbol Screen (PhET `SymbolScreen` / `SymbolScreenView`).
///
/// Shares [BAAModel] semantics with Atom Screen; Symbol-specific accordion
/// composition (Periodic Table + Symbol; no Net Charge / Mass Number panels).
class BuildAnAtomSymbolScreen extends StatefulWidget {
  const BuildAnAtomSymbolScreen({
    super.key,
    this.model,
    this.embedded = false,
  });

  final BAAModel? model;
  final bool embedded;

  static const title = 'Build an Atom — Symbol';
  static const backgroundColor = Color(0xFFF9FFE5);

  @override
  State<BuildAnAtomSymbolScreen> createState() =>
      BuildAnAtomSymbolScreenState();
}

class BuildAnAtomSymbolScreenState extends State<BuildAnAtomSymbolScreen>
    with SingleTickerProviderStateMixin {
  static const double _accordionPanelW = 260;
  static const double _accGap = 7;
  static const double _accHeaderH = 26;
  static const double _accBodyPad = 8;
  static const double _ptBodyH = 202.5 * 0.55;
  static double get _ptSeatH => _accHeaderH + _ptBodyH + _accBodyPad;

  late final BAAModel _model;
  late final bool _ownsModel;
  late final AtomViewState _appearance;
  late final SymbolViewState _symbolView;
  late final BaaTransform _transform;
  late final Ticker _ticker;
  final GlobalKey _simKey = GlobalKey();
  Duration? _lastTick;

  @override
  void initState() {
    super.initState();
    _ownsModel = widget.model == null;
    _model = widget.model ?? BAAModel();
    _appearance = AtomViewState(_model);
    _symbolView = SymbolViewState(_model);
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
    _appearance.dispose();
    _symbolView.dispose();
    if (_ownsModel) {
      _model.dispose();
    }
    super.dispose();
  }

  void _resetAll() {
    _model.reset();
    _appearance.reset();
    _symbolView.reset();
  }

  @override
  Widget build(BuildContext context) {
    final inset = BAAConstants.controlsInset.toDouble();
    final play = BaaPageShell(
      child: ColoredBox(
        color: BuildAnAtomSymbolScreen.backgroundColor,
        child: KeyedSubtree(
          key: _simKey,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ListenableBuilder(
                listenable: _model,
                builder: (context, _) {
                  final atomCenter = _transform.modelToView(0, 0);
                  return Positioned(
                    left: atomCenter.dx + 149,
                    top: atomCenter.dy + 62,
                    child: ElectronModelControl(
                      value: _model.electronModel.type,
                      onChanged: _appearance.setElectronModel,
                    ),
                  );
                },
              ),
              Positioned(
                left: inset,
                top: inset,
                child: ParticleCountPanel(model: _model),
              ),
              ListenableBuilder(
                listenable:
                    Listenable.merge([_model, _appearance, _symbolView]),
                builder: (context, _) {
                  final ptTop = inset;
                  final symbolTop = ptTop + _ptSeatH + _accGap;
                  return Stack(
                    children: [
                      Positioned(
                        right: inset,
                        top: ptTop,
                        width: _accordionPanelW,
                        child: BaaAccordionBox(
                          title: 'Periodic Table',
                          expanded: _appearance.periodicTableExpanded,
                          onToggle: () =>
                              _appearance.setPeriodicTableExpanded(
                                  !_appearance.periodicTableExpanded),
                          minWidth: _accordionPanelW,
                          child: BaaPeriodicTable(
                            selectedZ: _model.protonCount,
                            scale: 0.55,
                          ),
                        ),
                      ),
                      Positioned(
                        right: inset,
                        top: symbolTop,
                        width: _accordionPanelW,
                        child: BaaAccordionBox(
                          key: const Key('baaSymbolAccordion'),
                          title: 'Symbol',
                          expanded: _symbolView.symbolExpanded,
                          onToggle: () => _symbolView.setSymbolExpanded(
                              !_symbolView.symbolExpanded),
                          minWidth: _accordionPanelW,
                          child: Center(
                            child: BaaSymbolNode(
                              atom: _model.numberAtom,
                              scale: 0.41,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Positioned(
                right: inset,
                bottom: inset * 2,
                width: _accordionPanelW,
                child: ListenableBuilder(
                  listenable: _appearance,
                  builder: (context, _) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: BAAConstants.resetButtonRadius * 2 + 8,
                      ),
                      child:
                          AtomAppearanceCheckboxes(viewState: _appearance),
                    );
                  },
                ),
              ),
              InteractiveAtomPlayArea(
                model: _model,
                viewState: _appearance,
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
      backgroundColor: BuildAnAtomSymbolScreen.backgroundColor,
      appBar: AppBar(
        title: const Text('Symbol'),
        backgroundColor: const Color(0xFF1177AA),
        foregroundColor: Colors.white,
        actions: [
          if (Navigator.of(context).canPop())
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Back', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: play,
    );
  }
}
