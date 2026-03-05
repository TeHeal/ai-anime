/// 模板下载桩实现 — 不支持平台
Future<void> downloadScriptTemplate(String content, String fileName) async {
  throw UnsupportedError('当前平台不支持文件下载');
}
