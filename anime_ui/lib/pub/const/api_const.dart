/// API 常量
/// 连接后端时使用: flutter run -d web-server --web-port 8080 --dart-define=API_BASE_URL=http://localhost:3737/api/v1
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3737/api/v1',
);
