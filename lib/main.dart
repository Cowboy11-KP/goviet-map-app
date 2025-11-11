import 'package:flutter/material.dart';
import 'package:goviet_map_app/views/Onboarding/start_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const StartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}