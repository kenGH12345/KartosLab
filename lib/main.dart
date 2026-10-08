import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'buoyancy/buoyancy_module.dart';
import 'l10n/kartos_localization.dart';
import 'quantum_measurement/quantum_measurement_module.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // Register Simulation Modules before Home (lazy builders only).
  QuantumMeasurementModule.register();
  BuoyancyModule.register();
  runApp(const KratosApp());
}

class KratosApp extends StatelessWidget {
  const KratosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: loc.home.appTitle,
      // Material chrome (BackButton tooltip, etc.) follows product ZH locale.
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final app = child ?? const SizedBox.shrink();
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
          return ExcludeSemantics(child: app);
        }
        return app;
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1177AA),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6FAFC),
        useMaterial3: true,
        fontFamilyFallback: const [
          'Microsoft YaHei',
          'PingFang SC',
          'Noto Sans CJK SC',
          'Arial',
        ],
      ),
      home: const HomeScreen(),
    );
  }
}
