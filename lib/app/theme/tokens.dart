import 'package:flutter/material.dart';

/// NIPANGE design tokens — muted warm-neutral palette (redesign).
abstract final class NipColors {
  static const coral = Color(0xFFC97867);        // muted warm coral
  static const coralDark = Color(0xFFB0624F);
  static const ink = Color(0xFF252525);
  static const inkSoft = Color(0xFF77736F);
  static const muted = Color(0xFFA19B95);
  static const bg = Color(0xFFFAF9F7);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF4F2EF);
  static const border = Color(0xFFECE9E5);
  static const divider = Color(0xFFF0EEEB);
  static const bgDark = Color(0xFF151515);
  static const surfaceDark = Color(0xFF202020);
  static const surface2Dark = Color(0xFF272727);
  static const elevatedDark = Color(0xFF252A2E);
  static const inkDark = Color(0xFFF5F3F0);
  static const inkSoftDark = Color(0xFFB0AAA4);
  static const borderDark = Color(0xFF343434);
  static const success = Color(0xFF5B9A6F);
  static const warn = Color(0xFFB08A3E);
  static const error = Color(0xFFC05E5E);
  static const info = Color(0xFF6B8EAE);
}

abstract final class NipSpace {
  static const xxs = 4.0; static const xs = 8.0; static const sm = 12.0;
  static const md = 16.0; static const lg = 24.0; static const xl = 32.0; static const xxl = 48.0;
  static const screenH = 20.0;
}

abstract final class NipRadius {
  static const sm = 8.0; static const md = 14.0; static const lg = 20.0; static const full = 999.0;
}

abstract final class NipText {
  static const display = TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: NipColors.ink);
  static const pageTitle = TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: NipColors.ink);
  static const sectionTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: NipColors.ink);
  static const cardTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: NipColors.ink);
  static const body = TextStyle(fontSize: 15, height: 1.45, color: NipColors.ink);
  static const bodySmall = TextStyle(fontSize: 13, color: NipColors.inkSoft);
  static const caption = TextStyle(fontSize: 12, color: NipColors.muted);
  static const button = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
}
