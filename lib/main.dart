import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const GeometricOpticsApp());
}

class GeometricOpticsApp extends StatelessWidget {
  const GeometricOpticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '几何光学',
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
