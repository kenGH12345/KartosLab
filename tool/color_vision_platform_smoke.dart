import 'package:flutter/material.dart';
import 'package:kratos/color_vision/screens/color_vision_home.dart';

/// Platform smoke entry — opens Color Vision directly (no Home scroll).
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ColorVisionHome(),
    ),
  );
}
