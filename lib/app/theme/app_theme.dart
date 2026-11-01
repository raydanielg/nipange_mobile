import 'package:flutter/material.dart';
import 'tokens.dart';

/// Light + dark ThemeData built from design tokens — no hardcoded colors in widgets.
abstract final class AppTheme {
  static ThemeData light() {
    final cs = ColorScheme.fromSeed(seedColor: NipColors.coral, primary: NipColors.coral, surface: NipColors.surface, error: NipColors.error);
    return _base(cs, NipColors.bg, NipColors.surface, NipColors.ink, NipColors.inkSoft, NipColors.border);
  }

  static ThemeData dark() {
    final cs = ColorScheme.fromSeed(seedColor: NipColors.coral, primary: NipColors.coral, surface: NipColors.surfaceDark, error: NipColors.error, brightness: Brightness.dark);
    return _base(cs, NipColors.bgDark, NipColors.surfaceDark, NipColors.inkDark, NipColors.inkSoftDark, NipColors.elevatedDark);
  }

  static ThemeData _base(ColorScheme cs, Color bg, Color surface, Color ink, Color inkSoft, Color border) => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: cs,
        appBarTheme: AppBarTheme(
          backgroundColor: bg, elevation: 0, centerTitle: false,
          titleTextStyle: TextStyle(color: ink, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4),
          iconTheme: IconThemeData(color: ink),
        ),
        cardTheme: CardThemeData(color: surface, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NipRadius.md), side: BorderSide(color: border))),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: NipSpace.md, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(NipRadius.md), borderSide: BorderSide(color: border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(NipRadius.md), borderSide: BorderSide(color: border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(NipRadius.md), borderSide: const BorderSide(color: NipColors.coral, width: 1.6)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: NipColors.coral, foregroundColor: Colors.white, elevation: 0,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NipRadius.md)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        textTheme: TextTheme(
          headlineSmall: TextStyle(color: ink, fontWeight: FontWeight.w800, letterSpacing: -0.4),
          titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(color: ink, fontSize: 16, height: 1.4),
          bodyMedium: TextStyle(color: inkSoft, fontSize: 14),
          labelLarge: TextStyle(color: ink, fontWeight: FontWeight.w700),
          labelSmall: TextStyle(color: inkSoft, fontSize: 12),
        ),
        navigationBarTheme: NavigationBarThemeData(backgroundColor: surface, indicatorColor: NipColors.coral.withValues(alpha: .14)),
      );
}
