import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/l10n/kartos_localization.dart';
import 'package:kratos/main.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 9 — Material Back tooltip must be Chinese for user-facing chrome.
void main() {
  testWidgets('KratosApp MaterialLocalizations.backButtonTooltip is Chinese',
      (tester) async {
    await tester.pumpWidget(const KratosApp());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(HomeScreen), findsOneWidget);

    final context = tester.element(find.byType(HomeScreen));
    final tooltip = MaterialLocalizations.of(context).backButtonTooltip;
    expect(tooltip, anyOf(equals('返回'), equals('後退'), equals('后退')));
    expect(tooltip.toLowerCase(), isNot(contains('back')));
  });

  test('common.back canonical string is 返回', () {
    expect(loc.common.back, '返回');
  });

  testWidgets('zh_CN Material delegates resolve Back tooltip', (tester) async {
    late String tip;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            tip = MaterialLocalizations.of(context).backButtonTooltip;
            return const Scaffold(body: BackButton());
          },
        ),
      ),
    );
    await tester.pump();
    expect(tip, anyOf(equals('返回'), equals('後退'), equals('后退')));
  });
}
