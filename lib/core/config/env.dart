/// Environment config — dev/staging/prod via --dart-define. No secrets committed.
enum NipEnv { dev, staging, prod }

abstract final class Env {
  static const _env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:4000/api/v1');
  static const socketUrl = String.fromEnvironment('SOCKET_URL', defaultValue: 'http://localhost:4000');
  static const debugLog = bool.fromEnvironment('DEBUG_LOG', defaultValue: true);

  static NipEnv get current => switch (_env) { 'staging' => NipEnv.staging, 'prod' => NipEnv.prod, _ => NipEnv.dev };

  /// Android emulator needs 10.0.2.2, not localhost — doc in env.example.
  static void validate() {
    if (apiUrl.isEmpty) throw StateError('API_URL missing — pass --dart-define=API_URL=…');
    if (socketUrl.isEmpty) throw StateError('SOCKET_URL missing — pass --dart-define=SOCKET_URL=…');
  }
}
