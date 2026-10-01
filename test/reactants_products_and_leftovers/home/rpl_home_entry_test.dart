import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/reactants_products_and_leftovers/rpal_strings.dart';
import 'package:kratos/reactants_products_and_leftovers/screens/reactants_products_and_leftovers_home.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  testWidgets('Home lists RPL under 化学 / 反应物与生成物', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();

    await tester.ensureVisible(find.text('化学').first);
    expect(find.text('化学'), findsWidgets);
    await tester.ensureVisible(find.text('反应物与生成物').first);
    expect(find.text('反应物与生成物'), findsOneWidget);
    await tester.ensureVisible(
      find.text(ReactantsProductsAndLeftoversHome.title).first,
    );
    expect(
      find.text(ReactantsProductsAndLeftoversHome.title),
      findsOneWidget,
    );
    expect(
      find.text(ReactantsProductsAndLeftoversHome.subtitle),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.restaurant_outlined), findsOneWidget);
  });

  testWidgets('tap RPL card opens ReactantsProductsAndLeftoversHome',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    await tester.ensureVisible(
      find.text(ReactantsProductsAndLeftoversHome.title).first,
    );
    await tester.tap(find.text(ReactantsProductsAndLeftoversHome.title).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ReactantsProductsAndLeftoversHome), findsOneWidget);
    expect(find.text(RpalStrings.sandwiches), findsWidgets);
  });
}
