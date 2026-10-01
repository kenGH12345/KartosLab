import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';

void main() {
  testWidgets('Lab screen constructs and shows carousel', (tester) async {
    final c = BaBalanceLabController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: BaBalanceLabScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('ba_lab_viewport')), findsOneWidget);
    expect(find.byKey(const Key('ba_lab_carousel')), findsOneWidget);
    expect(find.byKey(const Key('ba_lab_reset_all')), findsOneWidget);
    expect(c.model.massList, isEmpty);
    expect(c.model.carousel.currentPage, LabCarouselPage.bricks);
    expect(c.clock.isRunning, isTrue);
    c.dispose();
  });

  testWidgets('carousel next/prev pages', (tester) async {
    final c = BaBalanceLabController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: BaBalanceLabScreen(controller: c),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(BaStrings.bricks), findsOneWidget);
    await tester.tap(find.byKey(const Key('ba_lab_carousel_next')));
    await tester.pump();
    expect(c.model.carousel.currentPage, LabCarouselPage.people1);
    expect(find.text(BaStrings.people), findsOneWidget);

    await tester.tap(find.byKey(const Key('ba_lab_carousel_next')));
    await tester.pump();
    expect(c.model.carousel.currentPage, LabCarouselPage.people2);

    await tester.tap(find.byKey(const Key('ba_lab_carousel_prev')));
    await tester.pump();
    expect(c.model.carousel.currentPage, LabCarouselPage.people1);
    c.dispose();
  });
}
