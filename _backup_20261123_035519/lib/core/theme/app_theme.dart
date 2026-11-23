import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF1B6B5A);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
      );
}