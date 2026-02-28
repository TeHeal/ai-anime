import 'dart:typed_data';

/// Stub：非 Web 平台
void saveBytesAsFile(Uint8List bytes, String filename) {
  throw UnsupportedError('当前平台不支持触发下载，请在 Web 端使用');
}
