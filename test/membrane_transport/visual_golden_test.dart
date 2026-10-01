import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/membrane_transport/layout/membrane_transport_layout.dart';
import 'package:kratos/membrane_transport/membrane_transport_feature_set.dart';
import 'package:kratos/membrane_transport/model/membrane_transport_model.dart';
import 'package:kratos/membrane_transport/model/particle_mode.dart';
import 'package:kratos/membrane_transport/model/solute_type.dart';
import 'package:kratos/membrane_transport/model/transport_protein_type.dart';
import 'package:kratos/membrane_transport/screens/simple_diffusion_screen.dart';
import 'package:kratos/membrane_transport/view/particle_image_cache.dart';
import 'package:kratos/membrane_transport/view/protein_image_cache.dart';

/// Phase 5 Visual Golden — design canvas 1024×618, DPR 1, paused, seed=42.
///
/// Generate baselines:
/// `flutter test --update-goldens test/membrane_transport/visual_golden_test.dart`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const layout = Size(
    MembraneTransportLayoutPrimitives.designWidth,
    MembraneTransportLayoutPrimitives.designHeight,
  );

  Future<void> pumpScreen(
    WidgetTester tester, {
    required MembraneTransportFeatureSet featureSet,
    void Function(MembraneTransportModel model)? setup,
  }) async {
    await tester.binding.setSurfaceSize(layout);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await ParticleImageCache.ensureLoaded();
    if (featureSetHasProteins(featureSet)) {
      await ProteinImageCache.ensureLoaded();
    }

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: MembraneTransportColors.outsideCell,
          body: SizedBox(
            width: layout.width,
            height: layout.height,
            child: MediaQuery(
              data: const MediaQueryData(
                size: layout,
                devicePixelRatio: 1,
                textScaler: TextScaler.linear(1),
              ),
              child: MembraneTransportScreenBody(
                featureSet: featureSet,
                seed: 42,
                pausedForGolden: true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    if (setup != null) {
      final state = tester.state(find.byType(MembraneTransportScreenBody));
      final model =
          (state as dynamic).testModel as MembraneTransportModel;
      setup(model);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> expectGolden(WidgetTester tester, String name) async {
    await expectLater(
      find.byType(MembraneTransportScreenBody),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  group('Simple Diffusion', () {
    testWidgets('MT5-SD-01_initial', (tester) async {
      await pumpScreen(
        tester,
        featureSet: MembraneTransportFeatureSet.simpleDiffusion,
      );
      await expectGolden(tester, 'MT5-SD-01_initial');
    });

    testWidgets('MT5-SD-02_solutes_added', (tester) async {
      await pumpScreen(
        tester,
        featureSet: MembraneTransportFeatureSet.simpleDiffusion,
        setup: (m) {
          m.addSolutes(SoluteType.oxygen, MembraneSide.outside, 40);
          m.addSolutes(SoluteType.carbonDioxide, MembraneSide.inside, 20);
        },
      );
      await expectGolden(tester, 'MT5-SD-02_solutes_added');
    });
  });

  group('Facilitated Diffusion', () {
    testWidgets('MT5-FD-01_initial_toolbox', (tester) async {
      await pumpScreen(
        tester,
        featureSet: MembraneTransportFeatureSet.facilitatedDiffusion,
      );
      await expectGolden(tester, 'MT5-FD-01_initial_toolbox');
    });

    testWidgets('MT5-FD-02_protein_placed', (tester) async {
      await pumpScreen(
        tester,
        featureSet: MembraneTransportFeatureSet.facilitatedDiffusion,
        setup: (m) {
          m.placeProtein(TransportProteinType.sodiumIonLeakageChannel);
          m.placeProtein(TransportProteinType.potassiumIonVoltageGatedChannel);
          m.addSolutes(SoluteType.sodiumIon, MembraneSide.outside, 30);
        },
      );
      await expectGolden(tester, 'MT5-FD-02_protein_placed');
    });

    testWidgets('MT5-FD-03_voltage_30_charges', (tester) async {
      await pumpScreen(
        tester,
        featureSet: MembraneTransportFeatureSet.facilitatedDiffusion,
        setup: (m) {
          m.placeProtein(TransportProteinType.sodiumIonVoltageGatedChannel);
          m.placeProtein(TransportProteinType.potassiumIonVoltageGatedChannel);
          m.setMembranePotential(30);
          m.setChargesVisible(true);
        },
      );
      await expectGolden(tester, 'MT5-FD-03_voltage_30_charges');
    });

    testWidgets('MT5-FD-04_ligands_added', (tester) async {
      await pumpScreen(
        tester,
        featureSet: MembraneTransportFeatureSet.facilitatedDiffusion,
        setup: (m) {
          m.placeProtein(TransportProteinType.sodiumIonLigandGatedChannel);
          m.setAreLigandsAdded(true);
        },
      );
      await expectGolden(tester, 'MT5-FD-04_ligands_added');
    });
  });

  group('Active Transport', () {
    testWidgets('MT5-AT-01_initial', (tester) async {
      await pumpScreen(
        tester,
        featureSet: MembraneTransportFeatureSet.activeTransport,
      );
      await expectGolden(tester, 'MT5-AT-01_initial');
    });

    testWidgets('MT5-AT-02_pump_placed', (tester) async {
      await pumpScreen(
        tester,
        featureSet: MembraneTransportFeatureSet.activeTransport,
        setup: (m) {
          m.placeProtein(TransportProteinType.sodiumPotassiumPump);
          m.setSelectedSolute(SoluteType.atp);
          m.addSolutes(SoluteType.atp, MembraneSide.inside, 10);
          m.addSolutes(SoluteType.sodiumIon, MembraneSide.inside, 20);
        },
      );
      await expectGolden(tester, 'MT5-AT-02_pump_placed');
    });
  });

  group('Playground', () {
    testWidgets('MT5-PG-01_initial_all_panels', (tester) async {
      await pumpScreen(
        tester,
        featureSet: MembraneTransportFeatureSet.playground,
      );
      await expectGolden(tester, 'MT5-PG-01_initial_all_panels');
    });

    testWidgets('MT5-PG-02_mixed_proteins', (tester) async {
      await pumpScreen(
        tester,
        featureSet: MembraneTransportFeatureSet.playground,
        setup: (m) {
          m.placeProtein(TransportProteinType.sodiumIonLeakageChannel);
          m.placeProtein(TransportProteinType.sodiumPotassiumPump);
          m.placeProtein(TransportProteinType.sodiumGlucoseCotransporter);
          m.setAreLigandsAdded(true);
          m.setMembranePotential(-50);
        },
      );
      await expectGolden(tester, 'MT5-PG-02_mixed_proteins');
    });
  });

  group('determinism', () {
    testWidgets('same seed ×3 matches same golden', (tester) async {
      for (var i = 0; i < 3; i++) {
        await pumpScreen(
          tester,
          featureSet: MembraneTransportFeatureSet.simpleDiffusion,
        );
        await expectGolden(tester, 'MT5-SD-01_initial');
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
    });
  });
}
