import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage — auth tokens and sensitive credentials only.
abstract final class SecureStore {
  static const _s = FlutterSecureStorage();
  static const _kAccess = 'access', _kRefresh = 'refresh';
  static Future<void> saveTokens(String a, String r) async { await _s.write(key: _kAccess, value: a); await _s.write(key: _kRefresh, value: r); }
  static Future<String?> get access => _s.read(key: _kAccess);
  static Future<String?> get refresh => _s.read(key: _kRefresh);
  static Future<void> clear() => _s.deleteAll();
}

/// Preferences — non-sensitive UI prefs only (theme, locale). Never credentials.
abstract final class Prefs {
  static SharedPreferences? _p;
  static Future<SharedPreferences> get _i async => _p ??= await SharedPreferences.getInstance();
  static Future<void> setTheme(String m) async => (await _i).setString('theme', m);
  static Future<String?> get theme async => (await _i).getString('theme');
  static Future<void> setLocale(String l) async => (await _i).setString('locale', l);
  static Future<String?> get locale async => (await _i).getString('locale');
  static Future<void> setOnboarded() async => (await _i).setString('onboarded', '1');
  static Future<bool> get onboarded async => (await _i).getString('onboarded') == '1';
}
