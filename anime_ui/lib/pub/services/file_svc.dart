import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'api.dart';

class FileService {
  /// Upload a file and return its URL.
  Future<String> upload(Uint8List bytes, String filename, {String category = 'general'}) async {
    final formData = FormData.fromMap({
      'category': category,
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final resp = await dio.post('/files/upload', data: formData);
    final data = extractData<Map<String, dynamic>>(resp);
    return data['url'] as String;
  }
}
