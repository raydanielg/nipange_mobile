import 'package:flutter/material.dart';

/// NIPANGE design tokens — single source of truth.
abstract final class NipColors {
  static const coral = Color(0xFFE76F51);
  static const coralDark = Color(0xFFC9553C);
  static const ink = Color(0xFF202124);
  static const inkSoft = Color(0xFF73777D);
  static const bg = Color(0xFFFAF9F7);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFEAE7E2);
  static const bgDark = Color(0xFF111315);
  static const surfaceDark = Color(0xFF1B1F22);
  static const elevatedDark = Color(0xFF252A2E);
  static const inkDark = Color(0xFFF5F5F5);
  static const inkSoftDark = Color(0xFFA7ADB2);
  static const success = Color(0xFF2FA765);
  static const warn = Color(0xFFF0A832);
  static const error = Color(0xFFE05555);
  static const info = Color(0xFF4A86E8);
}

abstract final class NipSpace {
  static const xxs = 4.0; static const xs = 8.0; static const sm = 12.0;
  static const md = 16.0; static const lg = 24.0; static const xl = 32.0;
  static const xxl = 48.0; static const screenH = 20.0;
}

abstract final class NipRadius {
  static const sm = 8.0; static const md = 14.0; static const lg = 20.0;
  static const full = 999.0;
}
