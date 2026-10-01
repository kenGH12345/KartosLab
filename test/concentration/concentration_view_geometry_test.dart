import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/concentration/model/concentration_constants.dart';
import 'package:kratos/concentration/view/beaker_solution_nodes.dart';
import 'package:kratos/concentration/view/concentration_layout.dart';
import 'package:kratos/concentration/view/concentration_faucet_node.dart';
import 'package:kratos/concentration/view/shaker_dropper_nodes.dart';

void main() {
  group('ConcentrationLayout geometry', () {
    test('layoutBounds 1100×700', () {
      expect(ConcentrationLayout.layoutBounds.width, 1100);
      expect(ConcentrationLayout.layoutBounds.height, 700);
    });

    test('beaker position and size', () {
      expect(ConcentrationLayout.beakerPosition.dx, 350);
      expect(ConcentrationLayout.beakerPosition.dy, 550);
      expect(ConcentrationLayout.beakerSize.width, 600);
      expect(ConcentrationLayout.beakerSize.height, 300);
      expect(ConcentrationLayout.beakerLeft, 50);
      expect(ConcentrationLayout.beakerRight, 650);
      expect(ConcentrationLayout.beakerTop, 250);
      expect(ConcentrationLayout.beakerBottom, 550);
    });

    test('shaker position, scale, orientation, drag bounds', () {
      expect(ConcentrationLayout.shakerPosition.dx, 350);
      expect(ConcentrationLayout.shakerPosition.dy, 170);
      expect(ConcentrationLayout.shakerImageScale, 0.75);
      expect(ShakerNode.imageScale, 0.75);
      expect(
        ConcentrationLayout.shakerOrientation,
        ConcentrationConstants.shakerOrientation,
      );
      expect(ConcentrationLayout.shakerDragBounds.left, 250);
      expect(ConcentrationLayout.shakerDragBounds.top, 50);
      expect(ConcentrationLayout.shakerDragBounds.right, 575);
      expect(ConcentrationLayout.shakerDragBounds.bottom, 210);
    });

    test('dropper fixed position', () {
      expect(ConcentrationLayout.dropperPosition.dx, 410);
      expect(ConcentrationLayout.dropperPosition.dy, 225);
    });

    test('solvent and drain faucet positions', () {
      expect(ConcentrationLayout.solventFaucetPosition.dx, 155);
      expect(ConcentrationLayout.solventFaucetPosition.dy, 220);
      expect(ConcentrationLayout.solventFaucetPipeMinX, -400);
      expect(ConcentrationLayout.drainFaucetPosition.dx, 750);
      expect(ConcentrationLayout.drainFaucetPosition.dy, 630);
      expect(ConcentrationLayout.drainFaucetPipeMinX, 650);
      expect(ConcentrationFaucetNode.scale, 0.75);
    });

    test('meter and probe', () {
      expect(ConcentrationLayout.meterBodyPosition.dx, 785);
      expect(ConcentrationLayout.meterBodyPosition.dy, 210);
      expect(ConcentrationLayout.probeInitialPosition.dx, 750);
      expect(ConcentrationLayout.probeInitialPosition.dy, 370);
      expect(ConcentrationLayout.probeDragBounds.left, 30);
      expect(ConcentrationLayout.probeDragBounds.top, 150);
      expect(ConcentrationLayout.probeDragBounds.right, 966);
      expect(ConcentrationLayout.probeDragBounds.bottom, 680);
    });

    test('solute panel right/top', () {
      expect(ConcentrationLayout.solutePanelRight, 1080);
      expect(ConcentrationLayout.solutePanelTop, 20);
    });

    test('evaporation placement', () {
      expect(ConcentrationLayout.evaporationLeft, 50);
      expect(ConcentrationLayout.evaporationTop, 580);
    });

    test('reset placement and scale', () {
      expect(ConcentrationLayout.resetRight, 1070);
      expect(ConcentrationLayout.resetBottom, 670);
      expect(ConcentrationLayout.resetScale, 1.32);
      expect(ConcentrationLayout.resetRadius, 20.5);
    });
  });

  group('SolutionNode liquid height', () {
    test('volume 0 → height 0', () {
      expect(
        SolutionNode.liquidHeight(
          volume: 0,
          beakerVolume: 1,
          beakerHeight: 300,
        ),
        0,
      );
    });

    test('volume 0.5 → height 150', () {
      expect(
        SolutionNode.liquidHeight(
          volume: 0.5,
          beakerVolume: 1,
          beakerHeight: 300,
        ),
        150,
      );
    });

    test('tiny volume uses min 5px height', () {
      expect(
        SolutionNode.liquidHeight(
          volume: 0.001,
          beakerVolume: 1,
          beakerHeight: 300,
        ),
        ConcentrationConstants.minNonzeroSolutionHeight,
      );
    });

    test('volume 1 → full beaker height', () {
      expect(
        SolutionNode.liquidHeight(
          volume: 1,
          beakerVolume: 1,
          beakerHeight: 300,
        ),
        300,
      );
    });
  });

  group('Dropper constants', () {
    test('tip and glass widths match EyeDropperNode', () {
      expect(DropperNode.tipWidth, 15);
      expect(DropperNode.glassWidth, 46);
    });
  });
}
