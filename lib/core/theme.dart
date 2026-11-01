import 'package:flutter/material.dart';

/// NIPANGE design tokens — deep charcoal, warm white, coral accent.
abstract final class NipTheme {
  static const coral = Color(0xFFFF5C5C);
  static const coralDark = Color(0xFFE04848);
  static const ink = Color(0xFF1C1C1E);
  static const inkSoft = Color(0xFF6C6C70);
  static const bg = Color(0xFFFBF9F7);
  static const card = Colors.white;
  static const success = Color(0xFF30B566);
  static const warn = Color(0xFFF5A623);
  static const error = Color(0xFFE23D3D);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: coral,
          primary: coral,
          surface: card,
          error: error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg, elevation: 0, centerTitle: false,
          titleTextStyle: TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4),
          iconTheme: IconThemeData(color: ink),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8E4E0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8E4E0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: coral, width: 1.6)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: coral, foregroundColor: Colors.white, elevation: 0,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(color: ink, fontWeight: FontWeight.w800, letterSpacing: -0.4),
          bodyLarge: TextStyle(color: ink, fontSize: 16),
          bodyMedium: TextStyle(color: inkSoft, fontSize: 14),
          labelLarge: TextStyle(color: ink, fontWeight: FontWeight.w700),
        ),
      );

  static ThemeData dark() {
    final l = light();
    return l.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(seedColor: coral, primary: coral, surface: const Color(0xFF1E1E1E), error: error, brightness: Brightness.dark),
    );
  }
}
