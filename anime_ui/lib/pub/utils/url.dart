/// 文件 URL 解析工具
///
/// 用于将相对路径转换为完整 URL，供 NetworkImage、音频播放等使用。
library;

/// 服务端 origin，用于解析相对文件路径。
/// 构建时覆盖：`flutter run --dart-define=SERVER_ORIGIN=https://example.com`
const kServerOrigin = String.fromEnvironment(
  'SERVER_ORIGIN',
  defaultValue: 'http://localhost:3737',
);

/// 若 [url] 为相对路径（以 `/` 开头），则拼接服务端 origin 返回完整 URL。
/// 若已是 http/https 开头则原样返回。
String resolveFileUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  return '$kServerOrigin$url';
}
