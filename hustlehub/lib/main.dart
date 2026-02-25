import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/second_screen.dart';

void main() {
  runApp(const HustleHubApp());
}

class HustleHubApp extends StatelessWidget {
  const HustleHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/second': (context) => const SecondScreen(),
      },
    );
  }
}