import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storages.dart';

/// Theme + locale preferences — persisted, riverpod-driven.
class ThemeNotifier extends Notifier<ThemeMode> {
  @override ThemeMode build() { _load(); return ThemeMode.system; }
  Future<void> _load() async { final t = await Prefs.theme; state = switch (t) { 'light' => ThemeMode.light, 'dark' => ThemeMode.dark, _ => ThemeMode.system }; }
  Future<void> set(ThemeMode m) async { state = m; await Prefs.setTheme(m.name); }
}
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class LocaleNotifier extends Notifier<Locale?> {
  @override Locale? build() { _load(); return null; } // null = system
  Future<void> _load() async { final l = await Prefs.locale; if (l != null) state = Locale(l); }
  Future<void> set(Locale? l) async { state = l; await Prefs.setLocale(l?.languageCode ?? ''); }
}
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
