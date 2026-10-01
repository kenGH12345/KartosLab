import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/one_dimension_controller.dart';
import '../controller/two_dimensions_controller.dart';
import '../model/nm_vec.dart';
import '../model/spring.dart';
import '../normal_modes_constants.dart';
import '../solver/normal_mode_math.dart';
import 'nm_mvt.dart';
import 'nm_render_data.dart';

class NmRenderBuilder {
  NmRenderBuilder._();

  static NmRenderData from1D(OneDimensionController c) {
    final model = c.model;
    final mvt = NmMvt.oneDimension();
    return NmRenderData(
      springs: _springs(model.springs, model.springsVisible, mvt),
      masses: [
        for (var i = 1; i < model.masses.length - 1; i++)
          MassRender(
            center: mvt.modelToView(model.masses[i].position),
            visible: model.masses[i].visible,
            index: i,
            showArrows: model.arrowsVisible,
            arrowDirection: model.amplitudeDirection,
          ),
      ],
      walls: [
        WallRender(center: mvt.modelToView(model.masses.first.position)),
        WallRender(center: mvt.modelToView(model.masses.last.position)),
      ],
      border: null,
      staticGraphs: [
        for (var i = 0; i < model.numberOfMasses; i++)
          ModeGraphRender(
            modeIndex: i,
            drawWalls: false,
            ys: ModeCurveMath.curveYs(
              modeIndex: i,
              resolution: NormalModesConstants.staticGraphResolution,
              graphHeight: NormalModesConstants.staticGraphHeight,
              amplitude: NormalModesConstants.staticGraphAmplitude,
              cosTerm: 1,
            ),
          ),
      ],
      modeGraphs: [
        for (var i = 0; i < model.numberOfMasses; i++)
          ModeGraphRender(
            modeIndex: i,
            drawWalls: true,
            ys: ModeCurveMath.curveYs(
              modeIndex: i,
              resolution: NormalModesConstants.modeGraphResolution,
              graphHeight: NormalModesConstants.modeGraphHeight,
              amplitude: model.modeAmplitudes[i],
              cosTerm: math.cos(
                model.modeFrequencies[i] * model.time - model.modePhases[i],
              ),
            ),
          ),
      ],
      numberOfMasses: model.numberOfMasses,
      amplitudes: List<double>.from(model.modeAmplitudes),
      phases: List<double>.from(model.modePhases),
      frequencyLabels: [
        for (var i = 0; i < model.numberOfMasses; i++)
          NormalModeMath.frequencyLabel(i, model.numberOfMasses),
      ],
      ampX: const [],
      ampY: const [],
      maxAmplitude2D: 0,
      amplitudeDirection: model.amplitudeDirection,
      phasesVisible: model.phasesVisible,
      springsVisible: model.springsVisible,
      playing: model.playing,
      time: model.time,
    );
  }

  static NmRenderData from2D(TwoDimensionsController c) {
    final model = c.model;
    final mvt = NmMvt.twoDimensions();
    final topLeft = mvt.modelToView(const NmVec(-1, 1));
    final bottomRight = mvt.modelToView(const NmVec(1, -1));
    final masses = <MassRender>[];
    for (var i = 1; i < model.masses.length - 1; i++) {
      for (var j = 1; j < model.masses[i].length - 1; j++) {
        final mass = model.masses[i][j];
        masses.add(
          MassRender(
            center: mvt.modelToView(mass.position),
            visible: mass.visible,
            index: i * NormalModesConstants.maxMasses + j,
            indexI: i,
            indexJ: j,
            showArrows: model.arrowsVisible,
            arrowDirection: model.amplitudeDirection,
            rotateArrows: true,
          ),
        );
      }
    }
    return NmRenderData(
      springs: [
        ..._springs(
          [
            for (final row in model.springsX)
              for (final s in row)
                ?s,
          ],
          model.springsVisible,
          mvt,
        ),
        ..._springs(
          [
            for (final row in model.springsY)
              for (final s in row)
                ?s,
          ],
          model.springsVisible,
          mvt,
        ),
      ],
      masses: masses,
      walls: const [],
      border: Rect.fromPoints(topLeft, bottomRight),
      staticGraphs: const [],
      modeGraphs: const [],
      numberOfMasses: model.numberOfMasses,
      amplitudes: const [],
      phases: const [],
      frequencyLabels: const [],
      ampX: model.modeXAmplitudes.map((r) => List<double>.from(r)).toList(),
      ampY: model.modeYAmplitudes.map((r) => List<double>.from(r)).toList(),
      maxAmplitude2D: model.maxAmplitude,
      amplitudeDirection: model.amplitudeDirection,
      phasesVisible: false,
      springsVisible: model.springsVisible,
      playing: model.playing,
      time: model.time,
    );
  }

  static List<SpringRender> _springs(
    List<Spring> springs,
    bool springsVisible,
    NmMvt mvt,
  ) {
    return [
      for (final s in springs)
        SpringRender(
          p1: mvt.modelToView(s.leftMass.position),
          p2: mvt.modelToView(s.rightMass.position),
          visible: s.leftVisible && springsVisible,
        ),
    ];
  }
}
