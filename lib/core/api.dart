import 'package:dio/dio.dart';
import 'config/env.dart';
import 'storage/storages.dart';

/// Central API layer — envelope {success,data} / {error:{code,message}},
/// Bearer auth, silent refresh on 401, Tanzania-safe error surfacing.
class ApiClient {
  ApiClient({String? baseUrl})
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? Env.apiUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (o, h) async {
        final t = await SecureStore.access;
        if (t != null) o.headers['authorization'] = 'Bearer $t';
        h.next(o);
      },
      onError: (e, h) async {
        if (e.response?.statusCode == 401 && !_refreshing) {
          _refreshing = true;
          try {
            final ok = await refreshTokens();
            if (ok) {
              final t = await SecureStore.access;
              e.requestOptions.headers['authorization'] = 'Bearer $t';
              return h.resolve(await dio.fetch(e.requestOptions));
            }
          } finally { _refreshing = false; }
        }
        h.next(e);
      },
    ));
  }

  final Dio dio;
  
  bool _refreshing = false;

  Future<void> saveTokens(String access, String refresh) async {
    await SecureStore.saveTokens(access, refresh);
  }

  Future<bool> refreshTokens() async {
    final r = await SecureStore.refresh;
    if (r == null) return false;
    try {
      final res = await Dio(BaseOptions(baseUrl: dio.options.baseUrl))
          .post('/auth/refresh', data: {'refreshToken': r});
      final d = res.data['data'];
      await saveTokens(d['accessToken'], d['refreshToken']);
      return true;
    } catch (_) {
      await SecureStore.clear();
      return false;
    }
  }

  Future<void> clearTokens() => SecureStore.clear();

  /// Unwraps {success, data} or throws [ApiException] with the backend code.
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async =>
      _unwrap(await dio.get(path, queryParameters: query));
  Future<dynamic> post(String path, {dynamic data}) async =>
      _unwrap(await dio.post(path, data: data));
  Future<dynamic> patch(String path, {dynamic data}) async =>
      _unwrap(await dio.patch(path, data: data));
  Future<dynamic> del(String path) async => _unwrap(await dio.delete(path));

  dynamic _unwrap(Response res) {
    final b = res.data;
    if (b is Map && b['success'] == true) return b['data'];
    if (b is Map && b['error'] != null) {
      throw ApiException(b['error']['code'] ?? 'ERROR', b['error']['message'] ?? 'Request failed');
    }
    return b is Map && b.containsKey('data') ? b['data'] : b;
  }
}

class ApiException implements Exception {
  ApiException(this.code, this.message);
  final String code, message;
  @override
  String toString() => message;
}
