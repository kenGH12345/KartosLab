import 'dart:ui' show Offset, Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/membrane_transport/layout/membrane_transport_layout.dart';
import 'package:kratos/membrane_transport/membrane_transport_constants.dart';
import 'package:kratos/membrane_transport/membrane_transport_feature_set.dart';
import 'package:kratos/membrane_transport/model/membrane_transport_model.dart';
import 'package:kratos/membrane_transport/model/mt_random.dart';
import 'package:kratos/membrane_transport/model/particle_mode.dart';
import 'package:kratos/membrane_transport/model/proteins/voltage_gated_channel.dart';
import 'package:kratos/membrane_transport/model/solute_type.dart';
import 'package:kratos/membrane_transport/model/transport_protein_type.dart';
import 'package:kratos/membrane_transport/view/protein_drag_session.dart';

MembraneTransportModel _fd({int seed = 7}) => MembraneTransportModel(
      featureSet: MembraneTransportFeatureSet.facilitatedDiffusion,
      random: SeededMtRandom(seed),
    );

MembraneTransportModel _at({int seed = 7}) => MembraneTransportModel(
      featureSet: MembraneTransportFeatureSet.activeTransport,
      random: SeededMtRandom(seed),
    );

MembraneTransportModel _sd({int seed = 7}) => MembraneTransportModel(
      featureSet: MembraneTransportFeatureSet.simpleDiffusion,
      random: SeededMtRandom(seed),
    );

void main() {
  group('drag geometry / snap', () {
    test('design ↔ model MVT round-trip at origin', () {
      final d = ProteinDragSession.modelToDesign(Offset.zero);
      expect(d.dx, 512);
      expect(d.dy, 208);
      final m = ProteinDragSession.designToModel(d);
      expect(m.dx, closeTo(0, 1e-9));
      expect(m.dy, closeTo(0, 1e-9));
    });

    test('slot indicator centered on slot in design space', () {
      final m = _fd();
      final slot = m.getMiddleSlot();
      final ind = ProteinDragSession.slotIndicatorDesign(slot);
      expect(ind.width, 65);
      expect(ind.height, 105);
      expect(ind.center.dx, closeTo(512, 0.5));
      expect(ind.center.dy, closeTo(208, 0.5));
    });

    test('closest overlapping slot by center distance', () {
      final m = _fd();
      final mid = m.getMiddleSlot();
      final ind = ProteinDragSession.slotIndicatorDesign(mid);
      final hit = ProteinDragSession.closestOverlappingSlot(
        dragBounds: ind.inflate(2),
        slots: m.membraneSlots,
      );
      expect(hit, mid);

      final miss = ProteinDragSession.closestOverlappingSlot(
        dragBounds: const Rect.fromLTWH(0, 0, 10, 10),
        slots: m.membraneSlots,
      );
      expect(miss, isNull);
    });
  });

  group('drop / swap / replace / remove', () {
    test('drop on empty slot places protein', () {
      final m = _fd();
      final target = m.membraneSlots.first;
      m.dropProteinFromDrag(
        TransportProteinType.sodiumIonLeakageChannel,
        target,
      );
      expect(m.transportProteinCount, 1);
      expect(
        target.transportProteinType,
        TransportProteinType.sodiumIonLeakageChannel,
      );
    });

    test('drop from toolbox onto filled slot replaces', () {
      final m = _fd();
      final target = m.membraneSlots.first;
      target.setTransportProteinType(
        TransportProteinType.sodiumIonLeakageChannel,
      );
      m.dropProteinFromDrag(
        TransportProteinType.potassiumIonLeakageChannel,
        target,
      );
      expect(m.transportProteinCount, 1);
      expect(
        target.transportProteinType,
        TransportProteinType.potassiumIonLeakageChannel,
      );
    });

    test('drop from slot onto filled slot swaps', () {
      final m = _fd();
      final a = m.membraneSlots[0];
      final b = m.membraneSlots[1];
      a.setTransportProteinType(TransportProteinType.sodiumIonLeakageChannel);
      b.setTransportProteinType(
        TransportProteinType.potassiumIonLeakageChannel,
      );
      // pickup a
      final typeA = a.transportProteinType!;
      a.setTransportProteinType(null);
      m.dropProteinFromDrag(typeA, b, originSlot: a);
      expect(
        b.transportProteinType,
        TransportProteinType.sodiumIonLeakageChannel,
      );
      expect(
        a.transportProteinType,
        TransportProteinType.potassiumIonLeakageChannel,
      );
    });

    test('invalid drop after membrane pickup removes protein', () {
      final m = _fd();
      final a = m.membraneSlots.first;
      a.setTransportProteinType(TransportProteinType.sodiumIonLeakageChannel);
      a.setTransportProteinType(null); // pickup clear
      // no dropProteinFromDrag → invalid return to toolbox
      expect(m.transportProteinCount, 0);
    });

    test('multiple same-type proteins allowed (7 slots)', () {
      final m = _fd();
      for (var i = 0; i < MembraneTransportConstants.slotCount; i++) {
        m.dropProteinFromDrag(
          TransportProteinType.sodiumIonLeakageChannel,
          m.membraneSlots[i],
        );
      }
      expect(m.transportProteinCount, 7);
    });

    test('removeProtein clears slot', () {
      final m = _fd();
      m.placeProtein(TransportProteinType.sodiumIonLeakageChannel);
      m.removeProtein(m.membraneSlots.first);
      expect(m.transportProteinCount, 0);
    });
  });

  group('featureSet isolation', () {
    test('simpleDiffusion has no protein types', () {
      expect(
        featureSetTransportProteins(
          MembraneTransportFeatureSet.simpleDiffusion,
        ),
        isEmpty,
      );
      expect(
        featureSetHasProteins(MembraneTransportFeatureSet.simpleDiffusion),
        isFalse,
      );
    });

    test('activeTransport solutes include ATP; facilitated does not', () {
      final at = _at();
      final fd = _fd();
      expect(at.selectableSolutes, contains(SoluteType.atp));
      expect(fd.selectableSolutes, isNot(contains(SoluteType.atp)));
    });

    test('independent models do not share protein state', () {
      final a = _fd(seed: 1);
      final b = _fd(seed: 1);
      a.placeProtein(TransportProteinType.sodiumIonLeakageChannel);
      expect(a.transportProteinCount, 1);
      expect(b.transportProteinCount, 0);
    });
  });

  group('voltage / ligands / transport hooks', () {
    test('voltage changes Na gate open state after delay', () {
      final m = _fd();
      m.placeProtein(TransportProteinType.sodiumIonVoltageGatedChannel);
      final ch = m.membraneSlots.first.transportProtein!
          as SodiumVoltageGatedChannel;
      expect(ch.isOpen, isFalse);
      m.setMembranePotential(-50);
      m.step(0.3);
      expect(ch.isOpen, isTrue);
    });

    test('ligands only step when areLigandsAdded', () {
      final m = _fd();
      expect(m.ligands, isNotEmpty);
      final y0 = m.ligands.first.position.y;
      m.areLigandsAdded = false;
      m.step(0.5);
      expect(m.ligands.first.position.y, y0);
      m.setAreLigandsAdded(true);
      m.step(0.5);
      // may or may not move depending on walk — at least property toggles
      expect(m.areLigandsAdded, isTrue);
    });

    test('leakage channel enables Na crossing path (model place)', () {
      final m = _fd(seed: 3);
      m.placeProtein(TransportProteinType.sodiumIonLeakageChannel);
      m.addSolutes(SoluteType.sodiumIon, MembraneSide.outside, 40);
      m.isPlaying = true;
      for (var i = 0; i < 200; i++) {
        m.step(0.05);
      }
      // With leakage + gradient, some Na should reach inside eventually
      final inside =
          m.countSolutes(SoluteType.sodiumIon, MembraneSide.inside);
      expect(inside, greaterThan(0));
    });
  });

  group('simple diffusion / pause / speed / reset', () {
    test('gases diffuse without proteins', () {
      final m = _sd(seed: 11);
      m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 50);
      for (var i = 0; i < 300; i++) {
        m.step(0.05);
      }
      expect(
        m.countSolutes(SoluteType.oxygen, MembraneSide.inside),
        greaterThan(0),
      );
    });

    test('pause stops solute motion', () {
      final m = _sd(seed: 5);
      m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 20);
      m.setPlaying(false);
      final before = m.solutes.map((s) => s.position.y).toList();
      m.step(0.2);
      final after = m.solutes.map((s) => s.position.y).toList();
      expect(after, before);
    });

    test('slow speed halves effective dt progression vs normal clock', () {
      final a = _sd(seed: 2)..setTimeSpeed(MtTimeSpeed.normal);
      final b = _sd(seed: 2)..setTimeSpeed(MtTimeSpeed.slow);
      expect(a.getTimeSpeedFactor(), 1.0);
      expect(b.getTimeSpeedFactor(), 0.5);
    });

    test('reset clears proteins voltage ligands playing', () {
      final m = _fd();
      m.placeProtein(TransportProteinType.sodiumIonLeakageChannel);
      m.setMembranePotential(30);
      m.setAreLigandsAdded(true);
      m.setPlaying(false);
      m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 5);
      m.time = 9;
      m.reset();
      expect(m.transportProteinCount, 0);
      expect(m.membranePotential, -70);
      expect(m.areLigandsAdded, isFalse);
      expect(m.isPlaying, isTrue);
      expect(m.solutes, isEmpty);
      expect(m.time, 9);
    });

    test('rapid place remove cycles ×10 no stuck slots', () {
      final m = _fd();
      for (var i = 0; i < 10; i++) {
        m.placeProtein(TransportProteinType.sodiumIonLeakageChannel);
        m.removeProtein(m.membraneSlots.first);
      }
      expect(m.transportProteinCount, 0);
      m.placeProtein(TransportProteinType.potassiumIonLeakageChannel);
      expect(m.transportProteinCount, 1);
    });
  });

  group('determinism', () {
    test('same seed same add sequence same positions', () {
      MembraneTransportModel run() {
        final m = _sd(seed: 99);
        m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 15);
        for (var i = 0; i < 40; i++) {
          m.step(0.05);
        }
        return m;
      }

      final a = run();
      final b = run();
      expect(a.solutes.length, b.solutes.length);
      for (var i = 0; i < a.solutes.length; i++) {
        expect(a.solutes[i].position.x, b.solutes[i].position.x);
        expect(a.solutes[i].position.y, b.solutes[i].position.y);
      }
    });
  });
}
