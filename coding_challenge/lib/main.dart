import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Search',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Courier',
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
