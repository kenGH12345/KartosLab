import '../audio/molarity_audio.dart';
import '../config/molarity_scenario_manager.dart';
import '../model/molarity_constants.dart';
import '../model/molarity_model.dart';
import '../model/molarity_state.dart';

/// Molarity controller — MVC orchestration (no UI · no physics Timer).
///
/// Interaction surface (source): solute amount slider · volume slider ·
/// solute combo · values checkbox · reset. No Shaker/Dropper/Probe/Faucet.
///
/// Audio cues fire from user-driven mutations (bin / rail rules), muted while
/// [MolarityModel.resetInProgress].
class MolarityController {
  MolarityController({required this.manager, this.audio});

  final MolarityScenarioManager manager;
  MolarityAudio? audio;

  /// Current state (built by [init] · rebuilt on scenario switch).
  MolarityState? currentState;

  bool _userDragging = false;

  /// Optional pointer-drag markers (precipitate audio no longer requires them;
  /// retained for future a11y / drag-type parity with PhET).
  void beginUserDrag() => _userDragging = true;
  void endUserDrag() => _userDragging = false;

  bool get isUserDragging => _userDragging;

  MolarityState get state {
    final s = currentState;
    if (s == null) {
      throw StateError(
        'MolarityController not initialized — call init() first',
      );
    }
    return s;
  }

  MolarityModel get model => state.model;

  Future<void> init({String? scenarioId}) async {
    // Home cold-start: PhET defaults must appear immediately. Scenario JSON is
    // optional (inquiry / KartosLab chrome) and must not block the play area.
    if (scenarioId != null) {
      try {
        if (manager.scenarios.isEmpty) {
          await manager.loadScenarios();
        }
      } catch (_) {}
    } else if (manager.scenarios.isEmpty) {
      // Fire-and-forget optional catalog; do not await for first paint.
      manager.loadScenarios().catchError((_) {});
    }

    if (manager.scenarios.isEmpty) {
      currentState = MolarityState.fromModel(
        scenarioId: scenarioId ?? 'default',
        model: MolarityModel.defaults(),
        initialSoluteIndex: 0,
        initialSoluteAmount: MolarityConstants.soluteAmountDefault,
        initialVolume: MolarityConstants.volumeDefault,
        initialValuesVisible: false,
      );
      return;
    }
    currentState = _load(scenarioId);
  }

  MolarityState _load(String? scenarioId) {
    final id =
        scenarioId ??
        (manager.scenarios.isNotEmpty
            ? manager.scenarios.first.scenarioId
            : 'default');
    try {
      return manager.loadScenario(id);
    } catch (_) {
      if (manager.scenarios.isNotEmpty) {
        return manager.loadScenario(manager.scenarios.first.scenarioId);
      }
      rethrow;
    }
  }

  MolarityState loadScenario(String scenarioId) {
    currentState = _load(scenarioId);
    return state;
  }

  void selectSolute(int index) {
    if (index < 0 || index >= model.solutes.length) return;
    if (index == model.selectedSoluteIndex) return;
    model.selectSolute(index);
    if (!model.resetInProgress) {
      // Fire-and-forget; audio must not block UI.
      audio?.onSoluteSelected(index);
    }
  }

  void setSoluteAmount(double v) {
    final solution = model.solution;
    final prevAmount = solution.soluteAmount;
    final prevC = solution.concentration;
    final prevP = solution.precipitateAmount;
    final next = MolarityConstants.constrainSoluteAmount(v);
    if (next == prevAmount) return;

    model.setSoluteAmount(next);

    _emitAfterAmountOrVolumeChange(
      previousAmount: prevAmount,
      previousVolume: solution.volume,
      amountChanged: true,
      previousConcentration: prevC,
      previousPrecipitate: prevP,
    );
  }

  void setVolume(double v) {
    final solution = model.solution;
    final prevVolume = solution.volume;
    final prevC = solution.concentration;
    final prevP = solution.precipitateAmount;
    final next = MolarityConstants.constrainVolume(v);
    if (next == prevVolume) return;

    model.setVolume(next);

    _emitAfterAmountOrVolumeChange(
      previousAmount: solution.soluteAmount,
      previousVolume: prevVolume,
      amountChanged: false,
      previousConcentration: prevC,
      previousPrecipitate: prevP,
    );
  }

  void toggleValues(bool v) => model.setValuesVisible(v);

  void reset() {
    state.reset();
    // Scenario reset also flips resetInProgress; mute is handled around model.reset
    // for PhET Reset All via [resetAllPhET].
  }

  /// PhET Reset All (Drink mix / 0.5 / 0.5 / values off).
  void resetAllPhET() {
    model.reset();
  }

  void _emitAfterAmountOrVolumeChange({
    required double previousAmount,
    required double previousVolume,
    required bool amountChanged,
    required double previousConcentration,
    required double previousPrecipitate,
  }) {
    if (model.resetInProgress) return;
    final a = audio;
    if (a == null) return;

    final solution = model.solution;
    final precipitate = solution.precipitateAmount;
    final saturated = precipitate != 0;

    // PrecipitateSoundGenerator — source requires slider drag (or PDOM).
    // Controller is the user surface; [beginUserDrag] marks pointer paths.
    // Keyboard / programmatic controller calls still emit (a11y-equivalent).
    final oldBin = MolarityAudioBins.precipitate.mapToBin(previousPrecipitate);
    final newBin = MolarityAudioBins.precipitate.mapToBin(precipitate);
    final rail =
        (precipitate > 0 && previousPrecipitate == 0) ||
        (precipitate == 0 && previousPrecipitate > 0);
    if (newBin != oldBin || rail) {
      a.onPrecipitateCue(
        precipitateAmount: precipitate,
        previousPrecipitateAmount: previousPrecipitate,
      );
    }

    // ConcentrationSoundGenerator: muted when precipitate > 0.
    if (!saturated) {
      final bool shouldPlay;
      if (amountChanged) {
        final oldBin = MolarityAudioBins.soluteAmount.mapToBin(previousAmount);
        final newBin = MolarityAudioBins.soluteAmount.mapToBin(
          solution.soluteAmount,
        );
        shouldPlay =
            oldBin != newBin ||
            solution.soluteAmount == MolarityConstants.soluteAmountMin ||
            solution.soluteAmount == MolarityConstants.soluteAmountMax;
      } else {
        final oldBin = MolarityAudioBins.volume.mapToBin(previousVolume);
        final newBin = MolarityAudioBins.volume.mapToBin(solution.volume);
        shouldPlay =
            oldBin != newBin ||
            solution.volume == MolarityConstants.volumeMin ||
            solution.volume == MolarityConstants.volumeMax;
      }
      if (shouldPlay) {
        a.onConcentrationCue(
          concentration: solution.concentration,
          previousConcentration: previousConcentration,
          saturated: saturated,
        );
      }
    }
  }

  Future<void> disposeAudio() async {
    await audio?.dispose();
    audio = null;
  }
}
