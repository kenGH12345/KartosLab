import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'beaker.dart';
import 'concentration_constants.dart';
import 'concentration_meter.dart';
import 'concentration_probe_jump.dart';
import 'concentration_solution.dart';
import 'dropper_model.dart';
import 'evaporator_model.dart';
import 'faucet_model.dart';
import 'probe_fluid_geometry.dart';
import 'probe_region.dart';
import 'shaker_model.dart';
import 'shaker_particles.dart';
import 'solute.dart';
import 'solute_definitions.dart';
import 'solute_form.dart';

/// Root model for Concentration — beers-law-lab `ConcentrationModel.ts`.
class ConcentrationModel extends ChangeNotifier {
  ConcentrationModel({math.Random? random})
      : solutes = List<Solute>.unmodifiable(SoluteDefinitions.all),
        beaker = Beaker(),
        shakerParticles = ShakerParticles(random: random),
        precipitateParticles = PrecipitateParticles(random: random) {
    _solute = solutes.first;
    solution = ConcentrationSolution(
      solute: _solute,
      soluteMoles: ConcentrationConstants.soluteAmountDefault,
      volume: ConcentrationConstants.solutionVolumeDefault,
    );
    shaker = ShakerModel();
    dropper = DropperModel();
    evaporator = EvaporatorModel();
    solventFaucet = FaucetModel(
      position: ConcentrationConstants.solventFaucetPosition,
      pipeMinX: ConcentrationConstants.solventFaucetPipeMinX,
    );
    drainFaucet = FaucetModel(
      position: ConcentrationConstants.drainFaucetPosition,
      pipeMinX: beaker.right,
    );
    meter = ConcentrationMeterModel();
    probeJump = ConcentrationProbeJumpController(
      beaker: beaker,
      solventFaucet: solventFaucet,
      dropper: dropper,
      drainFaucet: drainFaucet,
      initialOutside: ConcentrationConstants.probeInitialPosition,
    );
    _syncControlEnablement();
  }

  final List<Solute> solutes;
  final Beaker beaker;

  late Solute _solute;
  SoluteForm soluteForm = SoluteForm.solid;

  late final ConcentrationSolution solution;
  late final ShakerModel shaker;
  late final DropperModel dropper;
  late final EvaporatorModel evaporator;
  late final FaucetModel solventFaucet;
  late final FaucetModel drainFaucet;
  late final ConcentrationMeterModel meter;
  late final ConcentrationProbeJumpController probeJump;
  final ShakerParticles shakerParticles;
  final PrecipitateParticles precipitateParticles;

  Solute get solute => _solute;

  double get concentration => solution.concentration;
  double get precipitateMoles => solution.precipitateMoles;
  double get saturatedConcentration => solution.saturatedConcentration;
  bool get isSaturated => solution.isSaturated;
  double get solutionVolume => solution.volume;
  double get soluteMoles => solution.soluteMoles;
  bool get removeSoluteEnabled => solution.soluteMoles > 0;

  // ---------------------------------------------------------------------------
  // Solute / form
  // ---------------------------------------------------------------------------

  void setSolute(Solute value) {
    if (!solutes.contains(value) &&
        !solutes.any((s) => s.id == value.id)) {
      throw ArgumentError('Unknown solute: ${value.id}');
    }
    final resolved = solutes.firstWhere((s) => s.id == value.id);
    _solute = resolved;
    solution.setSolute(resolved);
    // Source: changing solute resets moles to 0
    solution.setSoluteMoles(0);
    shakerParticles.removeAllParticles();
    precipitateParticles.removeAllParticles();
    solution.updateIsSaturated();
    _syncControlEnablement();
    _refreshMeterIfNeeded();
    notifyListeners();
  }

  void setSoluteByIndex(int index) {
    setSolute(solutes[index]);
  }

  void setSoluteForm(SoluteForm form) {
    soluteForm = form;
    shaker.syncVisibility(form);
    dropper.syncEnabled(
      volume: solution.volume,
      soluteMoles: solution.soluteMoles,
      visible: dropper.isVisible(form),
    );
    if (!dropper.isVisible(form)) {
      dropper.setDispensing(false);
    }
    _refreshMeterIfNeeded();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Controls (input from View)
  // ---------------------------------------------------------------------------

  void setShakerPosition(Offset position) {
    shaker.setPosition(position);
    notifyListeners();
  }

  void setDropperDispensing(bool dispensing) {
    dropper.syncEnabled(
      volume: solution.volume,
      soluteMoles: solution.soluteMoles,
      visible: dropper.isVisible(soluteForm),
    );
    dropper.setDispensing(dispensing);
    _refreshMeterIfNeeded();
    notifyListeners();
  }

  void setSolventFlowRate(double rate) {
    solventFaucet.setFlowRate(rate);
    _refreshMeterIfNeeded();
    notifyListeners();
  }

  void setDrainFlowRate(double rate) {
    drainFaucet.setFlowRate(rate);
    _refreshMeterIfNeeded();
    notifyListeners();
  }

  void setEvaporationRate(double rate) {
    evaporator.syncEnabledFromVolume(solution.volume);
    evaporator.setEvaporationRate(rate);
    notifyListeners();
  }

  /// View endDrag / blur — source snaps evaporation to 0.
  void releaseEvaporation() {
    evaporator.release();
    notifyListeners();
  }

  void removeSolute() {
    if (solution.soluteMoles <= 0) return;
    solution.setSoluteMoles(0);
    shakerParticles.removeAllParticles();
    precipitateParticles.syncToSolution(solution, beaker);
    solution.updateIsSaturated();
    _syncControlEnablement();
    _refreshMeterIfNeeded();
    notifyListeners();
  }

  /// Direct solute addition for tests / future View shortcuts (still clamped).
  void addSoluteAmount(double moles) {
    _addSolute(moles);
    solution.updateIsSaturated();
    precipitateParticles.syncToSolution(solution, beaker);
    _syncControlEnablement();
    _refreshMeterIfNeeded();
    notifyListeners();
  }

  /// Direct volume set for tests (clamped).
  void setVolumeDirect(double volume) {
    solution.setVolume(volume);
    solution.updateIsSaturated();
    _syncControlEnablement();
    _refreshMeterIfNeeded();
    notifyListeners();
  }

  void setProbePosition(Offset position) {
    meter.setProbePosition(position);
    _detectAndApplyProbeRegion();
    notifyListeners();
  }

  /// View may still report a region; Model owns reading rules.
  void setProbeRegion(ProbeRegion region) {
    meter.updateValueFromRegion(
      region: region,
      solution: solution,
      selectedSolute: _solute,
    );
    notifyListeners();
  }

  void setMeterUnits(ConcentrationMeterUnits units) {
    meter.units = units;
    _detectAndApplyProbeRegion();
    notifyListeners();
  }

  Offset jumpProbeToNext() {
    final target = probeJump.jumpToNext(
      dropperVisible: dropper.isVisible(soluteForm),
    );
    meter.setProbePosition(target);
    _detectAndApplyProbeRegion();
    notifyListeners();
    return target;
  }

  void resetProbeJumpIndex() {
    probeJump.resetIndex();
  }

  /// Source-equivalent shape intersection → meter value.
  void _detectAndApplyProbeRegion() {
    final region = ProbeFluidGeometry.detect(
      probePosition: meter.probePosition,
      beaker: beaker,
      solution: solution,
      solventFaucet: solventFaucet,
      drainFaucet: drainFaucet,
      dropper: dropper,
      soluteForm: soluteForm,
    );
    meter.updateValueFromRegion(
      region: region,
      solution: solution,
      selectedSolute: _solute,
    );
  }

  void _refreshMeterIfNeeded() {
    // Fluids / concentration change every step — always re-detect.
    _detectAndApplyProbeRegion();
  }

  // ---------------------------------------------------------------------------
  // Clock
  // ---------------------------------------------------------------------------

  /// Source `step(dt)` order — do not reorder.
  void step(double dt) {
    if (dt < 0) return;

    _addSolventFromInputFaucet(dt);
    _drainSolutionFromOutputFaucet(dt);
    _addStockSolutionFromDropper(dt);
    _evaporateSolvent(dt);
    _propagateShakerParticles(dt);
    _createShakerParticles();

    // Determine saturation LAST — beers-law-lab#391
    solution.updateIsSaturated();

    precipitateParticles.syncToSolution(solution, beaker);
    _syncControlEnablement();
    _refreshMeterIfNeeded();
    notifyListeners();
  }

  void _addSolventFromInputFaucet(double dt) {
    _addSolvent(solventFaucet.flowRate * dt);
  }

  void _drainSolutionFromOutputFaucet(double dt) {
    final drainVolume = drainFaucet.flowRate * dt;
    if (drainVolume > 0) {
      final c = solution.concentration; // before changing volume
      final volumeRemoved = _removeSolvent(drainVolume);
      _removeSolute(c * volumeRemoved);
    }
  }

  void _addStockSolutionFromDropper(double dt) {
    final dropperVolume = dropper.flowRate * dt;
    if (dropperVolume > 0) {
      solution.updatePrecipitateAmount = false;
      final volumeAdded = _addSolvent(dropperVolume);
      solution.updatePrecipitateAmount = true;
      _addSolute(_solute.stockSolutionConcentration * volumeAdded);
    }
  }

  void _evaporateSolvent(double dt) {
    _removeSolvent(evaporator.evaporationRate * dt);
  }

  void _propagateShakerParticles(double dt) {
    shakerParticles.step(
      dt: dt,
      solution: solution,
      beaker: beaker,
      shaker: shaker,
    );
  }

  void _createShakerParticles() {
    shaker.syncVisibility(soluteForm);
    shaker.step();
  }

  double _addSolvent(double deltaVolume) {
    if (deltaVolume <= 0) return 0;
    final before = solution.volume;
    solution.setVolume(
      math.min(
        ConcentrationConstants.solutionVolumeMax,
        solution.volume + deltaVolume,
      ),
    );
    return solution.volume - before;
  }

  double _removeSolvent(double deltaVolume) {
    if (deltaVolume <= 0) return 0;
    final before = solution.volume;
    solution.setVolume(
      math.max(
        ConcentrationConstants.solutionVolumeMin,
        solution.volume - deltaVolume,
      ),
    );
    return before - solution.volume;
  }

  double _addSolute(double deltaAmount) {
    if (deltaAmount <= 0) return 0;
    final before = solution.soluteMoles;
    solution.setSoluteMoles(
      math.min(
        ConcentrationConstants.soluteAmountMax,
        solution.soluteMoles + deltaAmount,
      ),
    );
    return solution.soluteMoles - before;
  }

  double _removeSolute(double deltaAmount) {
    if (deltaAmount <= 0) return 0;
    final before = solution.soluteMoles;
    solution.setSoluteMoles(
      math.max(
        ConcentrationConstants.soluteAmountMin,
        solution.soluteMoles - deltaAmount,
      ),
    );
    return before - solution.soluteMoles;
  }

  void _syncControlEnablement() {
    final volume = solution.volume;
    final moles = solution.soluteMoles;

    solventFaucet.setEnabled(volume < ConcentrationConstants.solutionVolumeMax);
    drainFaucet.setEnabled(volume > ConcentrationConstants.solutionVolumeMin);

    shaker.syncEmpty(moles);
    shaker.syncVisibility(soluteForm);

    dropper.syncEnabled(
      volume: volume,
      soluteMoles: moles,
      visible: dropper.isVisible(soluteForm),
    );

    evaporator.syncEnabledFromVolume(volume);
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  void reset() {
    _solute = solutes.first;
    soluteForm = SoluteForm.solid;
    solution.reset(
      solute: _solute,
      soluteMoles: ConcentrationConstants.soluteAmountDefault,
      volume: ConcentrationConstants.solutionVolumeDefault,
    );
    shaker.reset();
    shakerParticles.reset();
    precipitateParticles.reset();
    dropper.reset();
    evaporator.reset();
    solventFaucet.reset();
    drainFaucet.reset();
    meter.reset();
    probeJump.reset();
    _syncControlEnablement();
    notifyListeners();
  }
}
