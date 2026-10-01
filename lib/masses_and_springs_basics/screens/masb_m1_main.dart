import 'package:flutter/material.dart';
import 'package:kratos/masses_and_springs_basics/screens/bounce_screen.dart';

/// Quick M1 harness:
/// `flutter run -d windows -t lib/masses_and_springs_basics/screens/masb_m1_main.dart`
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: BounceScreen()),
    ),
  );
}
