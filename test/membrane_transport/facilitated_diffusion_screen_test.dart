import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/membrane_transport/layout/membrane_transport_layout.dart';
import 'package:kratos/membrane_transport/membrane_transport_feature_set.dart';
import 'package:kratos/membrane_transport/model/membrane_transport_model.dart';
import 'package:kratos/membrane_transport/model/mt_random.dart';
import 'package:kratos/membrane_transport/model/transport_protein_type.dart';
import 'package:kratos/membrane_transport/screens/simple_diffusion_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Facilitated Diffusion screen', () {
    testWidgets('builds protein toolbox sections', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MembraneTransportScreenBody(
              featureSet: MembraneTransportFeatureSet.facilitatedDiffusion,
              seed: 3,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Solutes'), findsOneWidget);
      expect(find.text('Leakage Channels'), findsOneWidget);
      expect(find.text('Voltage-Gated Channels'), findsOneWidget);
      expect(find.text('Ligand-Gated Channels'), findsOneWidget);
      expect(find.text('Add Ligands'), findsOneWidget);
      expect(find.text('Charges'), findsOneWidget);
      expect(find.text('-70'), findsOneWidget);
      expect(find.text('+30'), findsOneWidget);
      expect(MembraneTransportLayoutPrimitives.designWidth, 1024);
    });

    testWidgets('Active Transport shows pumps, not voltage', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MembraneTransportScreenBody(
              featureSet: MembraneTransportFeatureSet.activeTransport,
              seed: 3,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Active Transporters'), findsOneWidget);
      expect(find.text('Leakage Channels'), findsNothing);
      expect(find.text('Add Ligands'), findsNothing);
    });
  });

  group('protein placement model', () {
    test('place fills leftmost empty; remove clears', () {
      final m = MembraneTransportModel(
        featureSet: MembraneTransportFeatureSet.facilitatedDiffusion,
        random: SeededMtRandom(1),
      );
      m.placeProtein(TransportProteinType.sodiumIonLeakageChannel);
      expect(m.transportProteinCount, 1);
      expect(
        m.membraneSlots.first.transportProteinType,
        TransportProteinType.sodiumIonLeakageChannel,
      );
      m.placeProtein(TransportProteinType.potassiumIonVoltageGatedChannel);
      expect(m.transportProteinCount, 2);
      m.removeProtein(m.membraneSlots.first);
      expect(m.transportProteinCount, 1);
    });

    test('full membrane: tap places on middle (source keyboard path)', () {
      final m = MembraneTransportModel(
        featureSet: MembraneTransportFeatureSet.facilitatedDiffusion,
        random: SeededMtRandom(1),
      );
      for (var i = 0; i < 7; i++) {
        m.placeProtein(TransportProteinType.sodiumIonLeakageChannel);
      }
      expect(m.transportProteinCount, 7);
      m.placeProtein(TransportProteinType.potassiumIonLeakageChannel);
      expect(m.transportProteinCount, 7);
      expect(
        m.getMiddleSlot().transportProteinType,
        TransportProteinType.potassiumIonLeakageChannel,
      );
    });

    test('charges default true only on facilitated', () {
      final fd = MembraneTransportModel(
        featureSet: MembraneTransportFeatureSet.facilitatedDiffusion,
        random: SeededMtRandom(1),
      );
      final pg = MembraneTransportModel(
        featureSet: MembraneTransportFeatureSet.playground,
        random: SeededMtRandom(1),
      );
      expect(fd.chargesVisible, isTrue);
      expect(pg.chargesVisible, isFalse);
    });
  });
}
