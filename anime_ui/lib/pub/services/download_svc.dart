import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'api.dart';
import 'download_svc_stub.dart' if (dart.library.html) 'download_svc_web.dart' as platform;

/// 单文件下载服务（README 2.7 生成物下载）
/// 通过项目下载接口代理，支持 path 或 url 参数
class DownloadService {
  /// 通过 dio 下载文件字节（携带鉴权），返回后由调用方触发保存
  Future<Uint8List> downloadBytes(
    String projectId, {
    String? path,
    String? url,
  }) async {
    final q = <String, String>{};
    if (path != null && path.isNotEmpty) q['path'] = path;
    if (url != null && url.isNotEmpty) q['url'] = url;
    if (q.isEmpty) throw ArgumentError('需要 path 或 url');
    final resp = await dio.get(
      '/projects/$projectId/download',
      queryParameters: q,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(resp.data as List<int>);
  }

  /// 触发浏览器下载（Web 平台；非 Web 时抛出）
  /// 使用 dio 拉取后创建 Blob 下载，以携带鉴权
  Future<void> triggerDownload(
    String projectId, {
    String? path,
    String? url,
    String filename = 'download',
  }) async {
    final bytes = await downloadBytes(projectId, path: path, url: url);
    platform.saveBytesAsFile(bytes, filename);
  }
}
