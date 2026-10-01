import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/membrane_transport/membrane_transport_constants.dart';
import 'package:kratos/membrane_transport/membrane_transport_feature_set.dart';
import 'package:kratos/membrane_transport/model/membrane_transport_model.dart';
import 'package:kratos/membrane_transport/model/mt_random.dart';
import 'package:kratos/membrane_transport/model/mt_vec2.dart';
import 'package:kratos/membrane_transport/model/particle_mode.dart';
import 'package:kratos/membrane_transport/model/proteins/ligand_gated_channel.dart';
import 'package:kratos/membrane_transport/model/proteins/sodium_potassium_pump.dart';
import 'package:kratos/membrane_transport/model/proteins/voltage_gated_channel.dart';
import 'package:kratos/membrane_transport/model/solute_type.dart';
import 'package:kratos/membrane_transport/model/transport_protein_type.dart';

MembraneTransportModel _model(
  MembraneTransportFeatureSet fs, {
  int seed = 42,
}) =>
    MembraneTransportModel(featureSet: fs, random: SeededMtRandom(seed));

void main() {
  group('defaults / feature set', () {
    test('simpleDiffusion has no proteins, 5 selectable solutes', () {
      final m = _model(MembraneTransportFeatureSet.simpleDiffusion);
      expect(featureSetHasProteins(m.featureSet), isFalse);
      expect(m.selectableSolutes, isNot(contains(SoluteType.atp)));
      expect(m.selectableSolutes.length, 5);
      expect(m.isPlaying, isTrue);
      expect(m.timeSpeed, MtTimeSpeed.normal);
      expect(m.membraneSlots.length, 7);
    });

    test('playground has all proteins and ATP', () {
      final m = _model(MembraneTransportFeatureSet.playground);
      expect(featureSetTransportProteins(m.featureSet).length, 8);
      expect(m.selectableSolutes, contains(SoluteType.atp));
      expect(m.ligands.length, MembraneTransportConstants.ligandCount * 2);
    });

    test('each screen gets independent model instance', () {
      final a = _model(MembraneTransportFeatureSet.simpleDiffusion, seed: 1);
      final b = _model(MembraneTransportFeatureSet.facilitatedDiffusion, seed: 1);
      a.addSolutes(SoluteType.oxygen, MembraneSide.outside, 10);
      expect(a.solutes.length, 10);
      expect(b.solutes.length, 0);
    });
  });

  group('add / remove / clear / reset', () {
    test('addSolutes respects max and side', () {
      final m = _model(MembraneTransportFeatureSet.simpleDiffusion);
      m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 50);
      expect(m.countSolutes(SoluteType.oxygen, MembraneSide.outside), 50);
      expect(m.countSolutes(SoluteType.oxygen, MembraneSide.inside), 0);
      expect(m.hasAnySolutes, isTrue);
    });

    test('clearSolutes keeps proteins and voltage', () {
      final m = _model(MembraneTransportFeatureSet.facilitatedDiffusion);
      m.placeProtein(TransportProteinType.sodiumIonLeakageChannel);
      m.membranePotential = -50;
      m.addSolutes(SoluteType.sodiumIon, MembraneSide.outside, 20);
      m.clearSolutes();
      expect(m.solutes, isEmpty);
      expect(m.transportProteinCount, 1);
      expect(m.membranePotential, -50);
    });

    test('reset clears solutes and proteins, restores defaults', () {
      final m = _model(MembraneTransportFeatureSet.facilitatedDiffusion);
      m.placeProtein(TransportProteinType.sodiumIonLeakageChannel);
      m.membranePotential = 30;
      m.isPlaying = false;
      m.areLigandsAdded = true;
      m.selectedSolute = SoluteType.glucose;
      m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 10);
      m.time = 5;
      final ligandCountBefore = m.ligands.length;

      m.reset();

      expect(m.solutes, isEmpty);
      expect(m.transportProteinCount, 0);
      expect(m.membranePotential, -70);
      expect(m.isPlaying, isTrue);
      expect(m.areLigandsAdded, isFalse);
      expect(m.selectedSolute, SoluteType.oxygen);
      expect(m.chargesVisible, isTrue); // facilitated default
      expect(m.time, 5); // time NOT reset
      expect(m.ligands.length, ligandCountBefore); // ligands not destroyed
    });

    test('eraser != reset: ligands stay hidden property only on reset', () {
      final m = _model(MembraneTransportFeatureSet.facilitatedDiffusion);
      m.areLigandsAdded = true;
      m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 5);
      m.clearSolutes();
      expect(m.areLigandsAdded, isTrue);
    });
  });

  group('gradient bias', () {
    test('signed gradient positive when more inside', () {
      final m = _model(MembraneTransportFeatureSet.simpleDiffusion, seed: 7);
      m.addSolutes(SoluteType.oxygen, MembraneSide.inside, 90);
      m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 10);
      expect(m.getSignedGradient(SoluteType.oxygen), closeTo(0.8, 1e-9));
    });

    test('against-gradient crossing often vetoed', () {
      final m = _model(MembraneTransportFeatureSet.simpleDiffusion, seed: 99);
      // High outside → particle on outside moving inward is WITH gradient
      // High inside → particle on outside moving inward is AGAINST
      m.addSolutes(SoluteType.oxygen, MembraneSide.inside, 100);
      m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 5);
      var allowed = 0;
      const trials = 200;
      for (var i = 0; i < trials; i++) {
        if (m.checkGradientForCrossing(
          SoluteType.oxygen,
          MembraneSide.outside,
        )) {
          allowed++;
        }
      }
      // With strength 0.9, expect ~10% allowed when against gradient
      expect(allowed / trials, lessThan(0.25));
      expect(allowed / trials, greaterThan(0.02));
    });

    test('no bias when gradient below threshold', () {
      final m = _model(MembraneTransportFeatureSet.simpleDiffusion, seed: 3);
      m.addSolutes(SoluteType.oxygen, MembraneSide.inside, 10);
      m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 10);
      expect(m.shouldApplyBiasForGasses(SoluteType.oxygen), isFalse);
      expect(
        m.checkGradientForCrossing(SoluteType.oxygen, MembraneSide.outside),
        isTrue,
      );
    });
  });

  group('determinism', () {
    test('same seed + actions → same positions', () {
      List<double> run(int seed) {
        final m = _model(MembraneTransportFeatureSet.simpleDiffusion, seed: seed);
        m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 15);
        for (var i = 0; i < 120; i++) {
          m.step(1 / 60);
        }
        return m.solutes.map((p) => p.position.x + p.position.y * 1000).toList()
          ..sort();
      }

      expect(run(123), equals(run(123)));
      expect(run(123), isNot(equals(run(456))));
    });
  });

  group('passive gas diffusion', () {
    test('oxygen can cross into inside over time', () {
      final m = _model(MembraneTransportFeatureSet.simpleDiffusion, seed: 11);
      m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 80);
      expect(m.countSolutes(SoluteType.oxygen, MembraneSide.inside), 0);

      for (var i = 0; i < 2000; i++) {
        m.step(1 / 60);
      }
      expect(
        m.countSolutes(SoluteType.oxygen, MembraneSide.inside),
        greaterThan(0),
      );
    });

    test('pause stops evolution', () {
      final m = _model(MembraneTransportFeatureSet.simpleDiffusion, seed: 5);
      m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 20);
      m.isPlaying = false;
      final xs = m.solutes.map((p) => p.position.x).toList();
      for (var i = 0; i < 60; i++) {
        m.step(1 / 60);
      }
      expect(m.solutes.map((p) => p.position.x).toList(), xs);
    });
  });

  group('voltage-gated', () {
    test('Na opens at -50 after 0.25s delay; K opens at +30', () {
      final m = _model(MembraneTransportFeatureSet.facilitatedDiffusion, seed: 1);
      m.placeProtein(TransportProteinType.sodiumIonVoltageGatedChannel);
      m.placeProtein(TransportProteinType.potassiumIonVoltageGatedChannel);
      final na = m.membraneSlots[0].transportProtein as SodiumVoltageGatedChannel;
      final k = m.membraneSlots[1].transportProtein as PotassiumVoltageGatedChannel;

      expect(na.isOpen, isFalse);
      expect(k.isOpen, isFalse);

      m.membranePotential = -50;
      m.step(0.1);
      expect(na.isOpen, isFalse); // still in delay
      m.step(0.2);
      expect(na.isOpen, isTrue);
      expect(k.isOpen, isFalse);

      m.membranePotential = 30;
      m.step(0.3);
      expect(na.isOpen, isFalse);
      expect(k.isOpen, isTrue);
    });
  });

  group('ligand-gated', () {
    test('bind → open after 0.5s; unbind after duration', () {
      final m = _model(MembraneTransportFeatureSet.facilitatedDiffusion, seed: 2);
      m.placeProtein(TransportProteinType.sodiumIonLigandGatedChannel);
      final ch = m.membraneSlots[0].transportProtein as LigandGatedChannel;
      final ligand = m.ligands.firstWhere((l) => l.type == ParticleType.triangleLigand);

      expect(ch.isAvailableForBinding(), isTrue);
      ch.bindLigand(ligand, true);
      expect(ch.state, 'ligandBoundClosed');
      expect(ligand.mode, isA<LigandBoundMode>());

      ch.step(0.5);
      expect(ch.state, 'ligandBoundOpen');
      expect(ch.isOpen, isTrue);

      // Fast-forward binding duration
      ch.timeSinceStateTransition = LigandGatedChannel.bindingDuration;
      ch.step(0.01);
      expect(ch.state, 'ligandUnboundOpen');
      ch.step(0.5);
      expect(ch.state, 'closed');
    });
  });

  group('sodium-potassium pump', () {
    test('3 Na → ATP → phosphate → open outward', () {
      final m = _model(MembraneTransportFeatureSet.activeTransport, seed: 8);
      m.placeProtein(TransportProteinType.sodiumPotassiumPump);
      final pump = m.membraneSlots[0].transportProtein as SodiumPotassiumPump;
      final slot = m.membraneSlots[0];

      // Force 3 Na waiting
      for (final site in ['sodium1', 'sodium2', 'sodium3']) {
        final p = m.addSoluteAt(SoluteType.sodiumIon, MtVec2(0, -15));
        p.mode = WaitingInPumpMode(slot: slot, site: site);
      }
      pump.step(0.01);
      expect(pump.pumpState, SodiumPotassiumState.openToInsideSodiumBound);

      final atp = m.addSoluteAt(SoluteType.atp, MtVec2(0, -15));
      atp.mode = WaitingInPumpMode(slot: slot, site: 'atp');
      pump.pumpState = SodiumPotassiumState.openToInsideSodiumAndATPBound;

      pump.timeSinceStateTransition = 0.5;
      pump.step(0.01);
      expect(
        pump.pumpState,
        SodiumPotassiumState.openToInsideSodiumAndPhosphateBound,
      );
      expect(m.solutes.any((p) => p.type == ParticleType.adp), isTrue);
      expect(m.solutes.any((p) => p.type == ParticleType.phosphate), isTrue);
    });
  });

  group('constants', () {
    test('slot positions and capture radius', () {
      expect(
        MembraneTransportConstants.slotPositions,
        [-84, -56, -28, 0, 28, 56, 84],
      );
      expect(MembraneTransportConstants.captureRadius, 40);
      expect(MembraneTransportConstants.modelHeight, closeTo(149.8127, 1e-3));
    });
  });
}
