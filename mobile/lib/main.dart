import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'dev/screen_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logistic Support',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ScreenPicker(), // later this will be the real first screen
    );
  }
}