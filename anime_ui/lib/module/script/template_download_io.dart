import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// IO 平台：通过 FilePicker 保存
Future<void> downloadScriptTemplate(String content, String fileName) async {
  final savePath = await FilePicker.platform.saveFile(
    dialogTitle: '保存分镜脚本模板',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  if (savePath == null) return;

  final file = File(savePath);
  await file.writeAsBytes(utf8.encode(content));
}
