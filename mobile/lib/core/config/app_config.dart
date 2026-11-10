/// Environment configuration. Values come from `--dart-define-from-file=env/<env>.json`.
/// Never hardcode URLs or secrets in source code.
class AppConfig {
  AppConfig._();

  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String socketUrl = String.fromEnvironment('SOCKET_URL');

  static bool get isDev => env == 'dev';

  /// Fails loudly at startup if the app was launched without an env file.
  static void validate() {
    if (apiBaseUrl.isEmpty || socketUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL / SOCKET_URL missing. Run with: '
        'flutter run --dart-define-from-file=env/dev.json',
      );
    }
  }
}