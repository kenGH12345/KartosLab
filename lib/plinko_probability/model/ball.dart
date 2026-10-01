import 'dart:ui';

import '../plinko_constants.dart';
import 'ball_phase.dart';
import 'galton_board.dart';
import 'histogram.dart';
import 'peg.dart';
import 'plinko_random.dart';

/// Common ball — `Ball.js`.
///
/// Path is **precomputed** with Bernoulli(p); motion is parabolic interpolation.
class Ball {
  Ball({
    required this.probability,
    required this.numberOfRows,
    required List<BinInfo> bins,
    required PlinkoRandom random,
  }) {
    pegSeparation = GaltonBoard.getPegSpacing(numberOfRows);
    ballRadius = pegSeparation * PlinkoConstants.ballSizeFraction;

    var columnNumber = 0;
    for (var rowNumber = 0; rowNumber <= numberOfRows; rowNumber++) {
      final direction = (random.nextDouble() > probability)
          ? PegDirection.left
          : PegDirection.right;
      final pos =
          GaltonBoard.pegPosition(rowNumber, columnNumber, numberOfRows);
      pegHistory.add(PegHop(
        rowNumber: rowNumber,
        positionX: pos.dx,
        positionY: pos.dy,
        direction: direction,
      ));
      if (rowNumber < numberOfRows) {
        columnNumber += (direction == PegDirection.left) ? 0 : 1;
      }
    }

    pathHops = List<PegHop>.unmodifiable(pegHistory);

    binIndex = columnNumber;
    binCount = bins[columnNumber].binCount + 1;
  }

  final double probability;
  final int numberOfRows;

  late final double pegSeparation;
  late final double ballRadius;
  late final int binIndex;

  /// binCount after this ball is reserved into the bin (including in-flight).
  late final int binCount;

  /// -1 left, 0 center, 1 right — Intro sets; Lab unused for stacking.
  int binOrientation = 0;

  Offset position = Offset.zero;
  BallPhase phase = BallPhase.initial;
  PegDirection direction = PegDirection.left;

  final List<PegHop> pegHistory = [];

  /// Immutable copy of peg hops at construction — used by TrajectoryPath
  /// after `pegHistory` is consumed during stepping.
  late final List<PegHop> pathHops;

  double finalBinHorizontalOffset = 0;
  double finalBinVerticalOffset = 0;

  int row = 0;
  double fallenRatio = 0;
  double pegPositionX = 0;
  double pegPositionY = 0;

  /// Fired with direction when ball reaches a peg.
  void Function(PegDirection direction)? onHittingPeg;

  /// Fired when ball leaves last peg (enter statistics).
  void Function()? onOutOfPegs;

  /// Fired when ball reaches collected phase.
  void Function()? onCollected;

  /// @returns true if the ball moved.
  bool step(double df) => ballStep(df);

  bool ballStep(double df) {
    if (phase == BallPhase.collected) {
      return false;
    } else if (phase == BallPhase.initial) {
      if (df + fallenRatio < 1) {
        initializePegPosition();
        fallenRatio += df;
      } else {
        phase = BallPhase.falling;
        fallenRatio = 0;
        updatePegPosition();
        onHittingPeg?.call(direction);
      }
    } else if (phase == BallPhase.falling) {
      if (df + fallenRatio < 1) {
        fallenRatio += df;
      } else {
        fallenRatio = 0;
        if (pegHistory.length > 1) {
          updatePegPosition();
          onHittingPeg?.call(direction);
        } else {
          phase = BallPhase.exited;
          updatePegPosition();
          onOutOfPegs?.call();
        }
      }
    } else if (phase == BallPhase.exited) {
      final finalPosition = finalBinVerticalOffset +
          pegSeparation * PlinkoConstants.pegHeightFractionOffset;
      if (position.dy > finalPosition) {
        fallenRatio += 2 * df * pegSeparation;
      } else {
        phase = BallPhase.collected;
        onCollected?.call();
      }
    }

    updatePosition();
    return true;
  }

  void updatePosition() {
    switch (phase) {
      case BallPhase.initial:
        position = Offset(0, 1 - fallenRatio);
        position = position * pegSeparation;
        position = position.translate(pegPositionX, pegPositionY);
      case BallPhase.falling:
        final shift = (direction == PegDirection.left) ? -0.5 : 0.5;
        position = Offset(shift * fallenRatio, -fallenRatio * fallenRatio);
        position = position * pegSeparation;
        if (row == numberOfRows - 1) {
          position = position.translate(
            finalBinHorizontalOffset * fallenRatio,
            0,
          );
        }
        position = position.translate(pegPositionX, pegPositionY);
      case BallPhase.exited:
        position = Offset(finalBinHorizontalOffset, -fallenRatio);
        position = position.translate(pegPositionX, pegPositionY);
      case BallPhase.collected:
        position = Offset(finalBinHorizontalOffset, finalBinVerticalOffset);
        position = position.translate(pegPositionX, 0);
    }

    position = position.translate(
      0,
      pegSeparation * PlinkoConstants.pegHeightFractionOffset,
    );
  }

  /// Skip animation; land immediately (Lab path/none modes).
  void updateStatisticsAndLand() {
    if (phase == BallPhase.initial) {
      onOutOfPegs?.call();
      onCollected?.call();
      phase = BallPhase.collected;
    }
  }

  void initializePegPosition() {
    final peg = pegHistory.first;
    row = peg.rowNumber;
    pegPositionX = peg.positionX;
    pegPositionY = peg.positionY;
  }

  void updatePegPosition() {
    final peg = pegHistory.removeAt(0);
    row = peg.rowNumber;
    pegPositionX = peg.positionX;
    pegPositionY = peg.positionY;
    direction = peg.direction;
  }
}
