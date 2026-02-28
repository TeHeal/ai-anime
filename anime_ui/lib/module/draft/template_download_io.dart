import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// IO 平台：通过 FilePicker 保存
Future<void> downloadTemplateFile(String content, String fileName) async {
  final savePath = await FilePicker.platform.saveFile(
    dialogTitle: '保存剧本模板',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: ['md', 'txt'],
  );
  if (savePath == null) return;

  final file = File(savePath);
  await file.writeAsBytes(utf8.encode(content));
}
