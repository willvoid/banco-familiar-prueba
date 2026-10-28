/// Build-time configuration.
///
/// Override with, for example:
/// `flutter run --dart-define=API_BASE_URL=http://<new-ip>:8001`
/// (the server IP changes when the Wi-Fi network changes).
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://172.16.6.215:8001',
  );

  static const String loginPath = String.fromEnvironment(
    'LOGIN_PATH',
    defaultValue: '/auth/login',
  );

  static const String mePath = String.fromEnvironment(
    'ME_PATH',
    defaultValue: '/auth/me',
  );

  static const Duration requestTimeout = Duration(seconds: 15);
}
