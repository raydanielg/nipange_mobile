import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/api.dart';

final apiProvider = Provider<ApiClient>((_) => ApiClient());

enum AuthState { unknown, unauthenticated, authenticated }

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._api) : super(AuthState.unknown) { _restore(); }
  final ApiClient _api;

  Future<void> _restore() async {
    final ok = await _api.refreshTokens();
    state = ok ? AuthState.authenticated : AuthState.unauthenticated;
  }

  Future<String> register(String phone, String password) async {
    final d = await _api.post('/auth/register/phone', data: {'phone': phone, 'password': password});
    return d['challengeId'] as String;
  }

  Future<void> verify(String challengeId, String code) async {
    final d = await _api.post('/auth/register/verify', data: {'challengeId': challengeId, 'code': code});
    await _api.saveTokens(d['tokens']['accessToken'], d['tokens']['refreshToken']);
    state = AuthState.authenticated;
  }

  Future<void> login(String phone, String password) async {
    final d = await _api.post('/auth/login', data: {'phone': phone, 'password': password});
    await _api.saveTokens(d['tokens']['accessToken'], d['tokens']['refreshToken']);
    state = AuthState.authenticated;
  }

  Future<void> logout() async {
    try { await _api.post('/auth/logout'); } catch (_) {}
    await _api.clearTokens();
    state = AuthState.unauthenticated;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((r) => AuthNotifier(r.watch(apiProvider)));
