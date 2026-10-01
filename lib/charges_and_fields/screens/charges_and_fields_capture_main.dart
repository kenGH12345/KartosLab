import 'package:flutter/material.dart';

import 'charges_and_fields_home.dart';

/// Independent entry for Visual QA / debug:
/// `flutter run -d windows -t lib/charges_and_fields/screens/charges_and_fields_capture_main.dart`
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChargesAndFieldsHome(),
    ),
  );
}
