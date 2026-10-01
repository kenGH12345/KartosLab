import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'beaker.dart';
import 'beaker_solution.dart';
import 'dropper.dart';
import 'faucet.dart';
import 'solute.dart';

/// Macro / Micro shared model — PhET `PHModel.ts`.
class PhModel extends ChangeNotifier {
  PhModel({
    this.autofillVolume = 0.5,
    this.autoFillEnabled = true,
    BeakerSolution? solution,
  }) {
    beaker = Beaker();
    final yDropper = beaker.position.dy - beaker.size.height - 15;
    dropper = Dropper(
      solute: Solute.water,
      position: Offset(beaker.position.dx - 50, yDropper),
    );
    this.solution = solution ??
        BeakerSolution(solute: dropper.solute, maxVolume: beaker.volume);

    waterFaucet = Faucet(
      position: Offset(
        beaker.right - 50,
        beaker.position.dy - beaker.size.height - 45,
      ),
      pipeMinX: beaker.right + 400,
      enabled: this.solution.totalVolume < beaker.volume,
    );

    drainFaucet = Faucet(
      position: Offset(beaker.left - 75, beaker.position.dy + 43),
      pipeMinX: beaker.left,
      enabled: this.solution.totalVolume > 0,
    );

    this.solution.addListener(_onSolutionChanged);
    dropper.addListener(_onDropperChanged);

    // Initial autofill like PhET preferences link / solute link at start.
    startAutofill();
  }

  late final Beaker beaker;
  late final Dropper dropper;
  late final BeakerSolution solution;
  late final Faucet waterFaucet;
  late final Faucet drainFaucet;

  final double autofillVolume;
  bool autoFillEnabled;
  bool isAutofilling = false;

  List<Solute> get solutes => Solute.allAlphabetical;

  void _onSolutionChanged() {
    updateFaucetsAndDropper();
    notifyListeners();
  }

  void _onDropperChanged() {
    // Solute change triggers autofill (volumes already cleared by setSolute).
    notifyListeners();
  }

  /// Select solute: clears beaker then autofills (PhET behavior).
  void selectSolute(Solute solute) {
    waterFaucet.enabled = false;
    drainFaucet.enabled = false;
    dropper.solute = solute;
    solution.setSolute(solute, resetVolumes: true);
    startAutofill();
    notifyListeners();
  }

  void updateFaucetsAndDropper() {
    final volume = solution.totalVolume;
    waterFaucet.enabled = volume < beaker.volume;
    drainFaucet.enabled = volume > 0;
    dropper.enabled = volume < beaker.volume;
  }

  void step(double dt) {
    if (isAutofilling) {
      stepAutofill(dt);
    } else {
      solution.addSolute(dropper.flowRate * dt);
      solution.addWater(waterFaucet.flowRate * dt);
      solution.drainSolution(drainFaucet.flowRate * dt);
    }
  }

  void startAutofill() {
    if (autoFillEnabled && autofillVolume > 0) {
      isAutofilling = true;
      dropper.isDispensing = true;
      dropper.setFlowRateDirect(0.45);
      notifyListeners();
    } else {
      updateFaucetsAndDropper();
    }
  }

  void stepAutofill(double dt) {
    final remaining = autofillVolume - solution.totalVolume;
    solution.addSolute(
      remaining < dropper.flowRate * dt
          ? remaining.clamp(0, double.infinity)
          : dropper.flowRate * dt,
    );
    if (solution.totalVolume >= autofillVolume) {
      stopAutofill();
    }
  }

  void stopAutofill() {
    isAutofilling = false;
    dropper.isDispensing = false;
    updateFaucetsAndDropper();
    notifyListeners();
  }

  /// Instant fill for tests (skip animation).
  void completeAutofillNow() {
    if (!autoFillEnabled || autofillVolume <= 0) return;
    final need = autofillVolume - solution.totalVolume;
    if (need > 0) solution.addSolute(need);
    stopAutofill();
  }

  void reset() {
    dropper.reset();
    solution.setSolute(Solute.water, resetVolumes: false);
    solution.reset();
    waterFaucet.reset();
    drainFaucet.reset();
    startAutofill();
    notifyListeners();
  }

  @override
  void dispose() {
    solution.removeListener(_onSolutionChanged);
    dropper.removeListener(_onDropperChanged);
    solution.dispose();
    dropper.dispose();
    waterFaucet.dispose();
    drainFaucet.dispose();
    super.dispose();
  }
}
