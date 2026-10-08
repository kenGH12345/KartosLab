import 'package:flutter/material.dart';

import '../../model/baa_model.dart';
import '../../model/baa_particle.dart';
import '../../model/charge_notation.dart';
import '../../model/game/answer_atom.dart';
import '../../model/game/challenge.dart';
import '../../model/game/challenge_type.dart';
import '../../model/game/challenge_type_view.dart';
import '../../model/game/game_model.dart';
import '../../model/game/game_state.dart';
import '../../view/baa_phet_font.dart';
import '../../view/game/game_audio_adapter.dart';
import '../phet_face_node.dart';
import 'baa_number_spinner.dart';
import 'game_interactive_periodic_table.dart';
import 'game_particle_counts_node.dart';
import 'interactive_symbol_view.dart';
import 'non_interactive_schematic.dart';
import 'package:kratos/chemistry/build_an_atom/baa_strings.dart';

/// PhET `ChallengeView` — presentation + answer input + action buttons.
class GameChallengeView extends StatefulWidget {
  const GameChallengeView({
    super.key,
    required this.game,
    required this.audio,
  });

  final GameModel game;
  final GameAudioAdapter audio;

  @override
  State<GameChallengeView> createState() => _GameChallengeViewState();
}

class _GameChallengeViewState extends State<GameChallengeView> {
  // Element answer
  int _selectedZ = 0;
  NeutralOrIon _neutralOrIon = NeutralOrIon.noSelection;

  // Charge / mass spinners
  int _chargeValue = 0;
  int _massValue = 0;

  // Interactive symbol
  int _symP = 0;
  int _symMass = 0;
  int _symCharge = 0;

  // Counts answer
  int _ansP = 0;
  int _ansN = 0;
  int _ansE = 0;

  // Schematic answer model
  BAAModel? _schematicModel;

  Challenge? _boundChallenge;
  GameState? _lastHandledState;

  GameModel get game => widget.game;
  Challenge? get challenge => game.challenge;

  @override
  void initState() {
    super.initState();
    game.addListener(_onGame);
    _resetInputs();
  }

  @override
  void dispose() {
    game.removeListener(_onGame);
    _schematicModel?.dispose();
    super.dispose();
  }

  void _onGame() {
    final ch = challenge;
    if (ch != _boundChallenge) {
      _boundChallenge = ch;
      _resetInputs();
      _lastHandledState = null;
    }
    final state = game.gameState;
    if (state != _lastHandledState) {
      _handleStateAudio(state);
      _lastHandledState = state;
      if (state == GameState.showingAnswer) {
        _applyCorrectAnswerDisplay();
      }
    }
    if (mounted) setState(() {});
  }

  void _handleStateAudio(GameState state) {
    switch (state) {
      case GameState.solvedCorrectly:
        widget.audio.correctAnswer();
      case GameState.tryAgain:
      case GameState.attemptsExhausted:
        widget.audio.wrongAnswer();
      default:
        break;
    }
  }

  void _resetInputs() {
    _selectedZ = 0;
    _neutralOrIon = NeutralOrIon.noSelection;
    _chargeValue = 0;
    _massValue = 0;
    _symP = 0;
    _symMass = 0;
    _symCharge = 0;
    _ansP = 0;
    _ansN = 0;
    _ansE = 0;
    _schematicModel?.dispose();
    _schematicModel = null;

    final ch = challenge;
    if (ch == null) return;
    final correct = ch.correctAnswerAtom;
    final t = ch.type;

    // Non-interactive fields seed from correct answer
    if (t.usesInteractiveSymbolAnswer) {
      _symP = t.isProtonCountConfigurable ? 0 : correct.protons;
      _symMass = t.isMassNumberConfigurable ? 0 : correct.massNumber;
      _symCharge = t.isChargeConfigurable ? 0 : correct.charge;
    } else if (t.showsSymbolPrompt) {
      _symP = correct.protons;
      _symMass = correct.massNumber;
      _symCharge = correct.charge;
    }

    if (t == ChallengeType.symbolToSchematic) {
      _schematicModel = BAAModel();
    }
  }

  void _applyCorrectAnswerDisplay() {
    final correct = game.correctAnswer;
    if (correct == null) return;
    final t = challenge!.type;
    if (t.isElementChallenge) {
      _selectedZ = correct.protons;
      _neutralOrIon =
          correct.charge == 0 ? NeutralOrIon.neutral : NeutralOrIon.ion;
    } else if (t.isChargeAnswer) {
      _chargeValue = correct.charge;
    } else if (t.isMassAnswer) {
      _massValue = correct.massNumber;
    } else if (t.usesInteractiveSymbolAnswer) {
      _symP = correct.protons;
      _symMass = correct.massNumber;
      _symCharge = correct.charge;
    } else if (t == ChallengeType.symbolToCounts) {
      _ansP = correct.protons;
      _ansN = correct.neutrons;
      _ansE = correct.electrons;
    } else if (t == ChallengeType.symbolToSchematic) {
      _schematicModel?.setAtomConfiguration(correct);
    }
  }

  bool get _answerInteractive =>
      game.gameState == GameState.presentingChallenge;

  bool get _canCheck {
    if (!_answerInteractive) return false;
    final t = challenge?.type;
    if (t == null) return false;
    if (t.isElementChallenge) {
      return _selectedZ > 0 && _neutralOrIon != NeutralOrIon.noSelection;
    }
    return true;
  }

  void _check() {
    if (!_canCheck) return;
    // Guard double-check
    if (game.gameState != GameState.presentingChallenge) return;
    final t = challenge!.type;
    final correct = challenge!.correctAnswerAtom;
    late AnswerAtom submitted;

    if (t.isElementChallenge) {
      game.checkElementAnswer(
        selectedProtons: _selectedZ,
        neutralOrIon: _neutralOrIon,
      );
      return;
    } else if (t.isChargeAnswer) {
      submitted = AnswerAtom(
        correct.protons,
        correct.neutrons,
        correct.protons - _chargeValue,
      );
    } else if (t.isMassAnswer) {
      submitted = AnswerAtom(
        correct.protons,
        _massValue - correct.protons,
        correct.electrons,
      );
    } else if (t.usesInteractiveSymbolAnswer) {
      submitted = AnswerAtom(
        _symP,
        _symMass - _symP,
        _symP - _symCharge,
      );
    } else if (t == ChallengeType.symbolToCounts) {
      submitted = AnswerAtom(_ansP, _ansN, _ansE);
    } else if (t == ChallengeType.symbolToSchematic) {
      final m = _schematicModel!;
      submitted = AnswerAtom(m.protonCount, m.neutronCount, m.electronCount);
    } else {
      submitted = AnswerAtom(correct.protons, correct.neutrons, correct.electrons);
    }
    game.check(submitted);
  }

  @override
  Widget build(BuildContext context) {
    final ch = challenge;
    if (ch == null) return const SizedBox.shrink();
    final state = game.gameState;
    final interactive = _answerInteractive;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 72),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(child: _buildPrompt(ch)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildAnswer(ch, interactive),
                ),
              ),
            ],
          ),
        ),
        // Feedback face
        if (state == GameState.solvedCorrectly ||
            state == GameState.tryAgain ||
            state == GameState.attemptsExhausted)
          Center(child: _FeedbackFace(state: state, points: game.pointsForCurrentChallenge)),
        // Action buttons
        Positioned(
          left: 0,
          right: 0,
          bottom: 12,
          child: Center(child: _buildActions(state)),
        ),
      ],
    );
  }

  Widget _buildPrompt(Challenge ch) {
    final t = ch.type;
    final atom = ch.correctAnswerAtom;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.challengeTitle,
          style: BaaPhetFont.of(26, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (t.showsSymbolPrompt)
          InteractiveSymbolView(
            protonCount: atom.protons,
            massNumber: atom.massNumber,
            charge: atom.charge,
            onProtonChanged: (_) {},
            onMassChanged: (_) {},
            onChargeChanged: (_) {},
            scale: 0.55,
            showAtomName: true,
          )
        else if (t.showsCountsPrompt)
          GameParticleCountsNode(atom: atom)
        else
          NonInteractiveSchematicAtom(atom: atom, size: 200),
      ],
    );
  }

  Widget _buildAnswer(Challenge ch, bool interactive) {
    final t = ch.type;
    if (t.isElementChallenge) {
      return Column(
        children: [
          GameInteractivePeriodicTable(
            selectedZ: _selectedZ,
            onSelected: (z) => setState(() {
              _selectedZ = z;
              if (z == 0) _neutralOrIon = NeutralOrIon.noSelection;
            }),
            enabled: interactive,
          ),
          if (_selectedZ > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _radio(
                  'Neutral Atom',
                  NeutralOrIon.neutral,
                  interactive,
                ),
                const SizedBox(width: 16),
                _radio('Ion', NeutralOrIon.ion, interactive),
              ],
            ),
          ],
        ],
      );
    }
    if (t.isChargeAnswer) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Flexible(
            child: Text(
              'What is the total charge?',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 10),
          BaaNumberSpinner(
            value: _chargeValue,
            onChanged: (v) => setState(() => _chargeValue = v),
            enabled: interactive,
            showPlusForPositive: true,
            textColor: Color(chargeTextColorValue(_chargeValue)),
          ),
        ],
      );
    }
    if (t.isMassAnswer) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Flexible(
            child: Text(
              'What is the mass number?',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 10),
          BaaNumberSpinner(
            value: _massValue,
            onChanged: (v) => setState(() => _massValue = v),
            enabled: interactive,
            minValue: 0,
          ),
        ],
      );
    }
    if (t.usesInteractiveSymbolAnswer) {
      return InteractiveSymbolView(
        protonCount: _symP,
        massNumber: _symMass,
        charge: _symCharge,
        onProtonChanged: (v) => setState(() => _symP = v),
        onMassChanged: (v) => setState(() => _symMass = v),
        onChargeChanged: (v) => setState(() => _symCharge = v),
        isProtonInteractive: t.isProtonCountConfigurable,
        isMassInteractive: t.isMassNumberConfigurable,
        isChargeInteractive: t.isChargeConfigurable,
        enabled: interactive,
        scale: 0.7,
      );
    }
    if (t == ChallengeType.symbolToCounts) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _countRow('Protons:', _ansP, (v) => setState(() => _ansP = v), interactive),
          _countRow('Neutrons:', _ansN, (v) => setState(() => _ansN = v), interactive),
          _countRow('Electrons:', _ansE, (v) => setState(() => _ansE = v), interactive),
        ],
      );
    }
    if (t == ChallengeType.symbolToSchematic) {
      return _SchematicAnswerArea(
        model: _schematicModel!,
        enabled: interactive,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _countRow(
    String label,
    int value,
    ValueChanged<int> onChanged,
    bool enabled,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 18)),
          ),
          BaaNumberSpinner(
            value: value,
            onChanged: onChanged,
            enabled: enabled,
            minValue: 0,
            maxValue: 20,
          ),
        ],
      ),
    );
  }

  Widget _radio(String label, NeutralOrIon value, bool enabled) {
    return InkWell(
      onTap: enabled ? () => setState(() => _neutralOrIon = value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(16, 16),
            painter: _AquaRadioPainter(selected: _neutralOrIon == value),
          ),
          const SizedBox(width: 6),
          Text(label, style: BaaPhetFont.of(16)),
        ],
      ),
    );
  }

  Widget _buildActions(GameState state) {
    Widget? btn;
    switch (state) {
      case GameState.presentingChallenge:
        btn = _gameButton(BaaStrings.check, _canCheck ? _check : null);
      case GameState.solvedCorrectly:
      case GameState.showingAnswer:
        btn = _gameButton(BaaStrings.next, () {
          if (game.gameState == GameState.solvedCorrectly ||
              game.gameState == GameState.showingAnswer) {
            game.next();
          }
        });
      case GameState.tryAgain:
        btn = _gameButton(BaaStrings.tryAgain, () {
          if (game.gameState == GameState.tryAgain) game.tryAgain();
        });
      case GameState.attemptsExhausted:
        btn = _gameButton(BaaStrings.showAnswer, () {
          if (game.gameState == GameState.attemptsExhausted) {
            game.displayCorrectAnswer();
          }
        });
      default:
        btn = null;
    }
    return btn ?? const SizedBox.shrink();
  }

  Widget _gameButton(String label, VoidCallback? onPressed) {
    // vegas CheckButton / NextButton chrome — baseColor #00FF99
    final enabled = onPressed != null;
    return Material(
      color: enabled ? const Color(0xFF00FF99) : const Color(0xFFB0B0B0),
      elevation: enabled ? 2 : 0,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: Text(
            label,
            style: BaaPhetFont.of(20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _FeedbackFace extends StatelessWidget {
  const _FeedbackFace({required this.state, required this.points});
  final GameState state;
  final int points;

  @override
  Widget build(BuildContext context) {
    final smile = state == GameState.solvedCorrectly;
    // ChallengeView: FaceNode(layoutBounds.width * 0.4) ≈ 307 → scale down for fit
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PhetFaceNode(
          headDiameter: 140,
          smiling: smile,
          opacity: 0.75,
        ),
        if (smile && points > 0)
          Text(
            '+$points',
            style: BaaPhetFont.of(20, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}

/// Compact schematic answer: particle count buttons (+/−) syncing a BAAModel.
class _SchematicAnswerArea extends StatelessWidget {
  const _SchematicAnswerArea({required this.model, required this.enabled});
  final BAAModel model;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final atom = model.numberAtom;
        return Column(
          children: [
            NonInteractiveSchematicAtom(atom: atom, size: 180),
            const SizedBox(height: 8),
            _adjustRow('Protons', atom.protons, enabled, () {
              model.addFromBucket(BaaParticleType.proton);
            }, () {
              if (model.atom.protons.isNotEmpty) {
                model.removeToBucket(model.atom.protons.last);
              }
            }),
            _adjustRow('Neutrons', atom.neutrons, enabled, () {
              model.addFromBucket(BaaParticleType.neutron);
            }, () {
              if (model.atom.neutrons.isNotEmpty) {
                model.removeToBucket(model.atom.neutrons.last);
              }
            }),
            _adjustRow('Electrons', atom.electrons, enabled, () {
              model.addFromBucket(BaaParticleType.electron);
            }, () {
              if (model.atom.electrons.isNotEmpty) {
                model.removeToBucket(model.atom.electrons.last);
              }
            }),
          ],
        );
      },
    );
  }

  Widget _adjustRow(
    String label,
    int count,
    bool enabled,
    VoidCallback add,
    VoidCallback remove,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: BaaPhetFont.of(16)),
          ),
          BaaNumberSpinner(
            value: count,
            onChanged: (v) {
              if (v > count) {
                add();
              } else if (v < count) {
                remove();
              }
            },
            enabled: enabled,
            minValue: 0,
            maxValue: 20,
            width: 100,
          ),
        ],
      ),
    );
  }
}

class _AquaRadioPainter extends CustomPainter {
  _AquaRadioPainter({required this.selected});
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 0.5;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF1177AA),
    );
    if (selected) {
      canvas.drawCircle(c, r * 0.55, Paint()..color = const Color(0xFF1177AA));
    }
  }

  @override
  bool shouldRepaint(covariant _AquaRadioPainter oldDelegate) =>
      oldDelegate.selected != selected;
}
