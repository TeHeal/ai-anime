// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';

/// Web 平台：通过 Blob + Anchor 下载
Future<void> downloadTemplateFile(String content, String fileName) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'text/markdown;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
