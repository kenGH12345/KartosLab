import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:geometric_optics/optics/solvers/optics_solver.dart';
import 'package:geometric_optics/optics/models/optical_element.dart';
import 'package:geometric_optics/optics/models/lens_element.dart';
import 'package:geometric_optics/optics/models/light_source_element.dart';
import 'package:geometric_optics/optics/models/screen_element.dart';
import 'package:geometric_optics/optics/models/optics_world.dart';

void main() {
  test('Single convex lens produces image', () {
    final solver = OpticalSolver();
    final world = OpticsWorld(
      elements: [
        LightSourceElement(id: 's1', x: -6, y: 0, objectHeight: 5, sourceType: SourceType.object, width: 20, height: 80),
        LensElement(id: 'l1', x: 0, y: 0, lensKind: LensType.convex, focalLength: 10, diameter: 5, width: 20, height: 80),
      ],
    );

    final result = solver.solve(world);
    expect(result.rays.isNotEmpty, true);
    expect(result.imageInfo, isNotNull);
    expect(result.imageInfo!.isVirtual, true);
    expect(result.imageStages.length, 1);
  });

  test('Double lens produces two image stages', () {
    final solver = OpticalSolver();
    final world = OpticsWorld(
      elements: [
        LightSourceElement(id: 's1', x: -20, y: 0, objectHeight: 5, sourceType: SourceType.object, width: 20, height: 80),
        LensElement(id: 'l1', x: -10, y: 0, lensKind: LensType.convex, focalLength: 15, diameter: 5, width: 20, height: 80),
        LensElement(id: 'l2', x: 10, y: 0, lensKind: LensType.convex, focalLength: 15, diameter: 5, width: 20, height: 80),
      ],
    );

    final result = solver.solve(world);
    expect(result.imageStages.length, 2);
    expect(result.imageInfo, isNotNull);

    final stage0 = result.imageStages[0];
    final stage1 = result.imageStages[1];
    expect(stage1.objectPoint.dx, closeTo(stage0.imagePoint.dx, 0.1));
    expect(stage1.objectPoint.dy, closeTo(stage0.imagePoint.dy, 0.1));
  });

  test('Screen hit when ray reaches screen', () {
    final solver = OpticalSolver();
    final world = OpticsWorld(
      elements: [
        LightSourceElement(id: 's1', x: -6, y: 0, objectHeight: 5, sourceType: SourceType.object, width: 20, height: 80),
        LensElement(id: 'l1', x: 0, y: 0, lensKind: LensType.convex, focalLength: 10, diameter: 5, width: 20, height: 80),
        ScreenElement(id: 'sc1', x: 15, y: 0, width: 20, height: 80),
      ],
    );

    final result = solver.solve(world);
    expect(result.screenHits.isNotEmpty, true);
  });

  test('No source returns empty result', () {
    final solver = OpticalSolver();
    final world = OpticsWorld(
      elements: [
        LensElement(id: 'l1', x: 0, y: 0, lensKind: LensType.convex, focalLength: 10, diameter: 5, width: 20, height: 80),
      ],
    );

    final result = solver.solve(world);
    expect(result.rays, isEmpty);
    expect(result.imageInfo, isNull);
  });
}
