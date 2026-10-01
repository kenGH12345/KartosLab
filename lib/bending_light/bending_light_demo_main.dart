import 'package:flutter/material.dart';
import 'package:kratos/bending_light/qa_launch.dart';
import 'package:kratos/bending_light/screens/bending_light_hub.dart';
import 'package:kratos/bending_light/screens/intro_screen.dart';
import 'package:kratos/bending_light/screens/more_tools_screen.dart';
import 'package:kratos/bending_light/screens/prisms_screen.dart';

void main() {
  final qa = qaCapture;
  final Widget home = switch (qa) {
    'intro' => const IntroScreen(),
    'prisms' || 'white' => const PrismsScreen(),
    'more' || 'graph' || 'sensors' => const MoreToolsScreen(),
    _ => const BendingLightHub(),
  };
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: home,
  ));
}
