import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:anime_ui/pub/models/task.dart';
import 'api.dart';

class AiService {
  Stream<String> chatStream({
    required String model,
    required List<Map<String, String>> messages,
    String? provider,
    String? feature,
  }) async* {
    final resp = await dio.post(
      '/ai/chat',
      data: {
        'model': model,
        'messages': messages,
        'provider': ?provider,
        'feature': ?feature,
      },
      options: Options(responseType: ResponseType.stream),
    );

    final stream = resp.data as ResponseBody;
    final buffer = StringBuffer();

    await for (final chunk in stream.stream) {
      buffer.write(utf8.decode(chunk));
      final raw = buffer.toString();
      final lines = raw.split('\n');

      buffer.clear();
      if (!raw.endsWith('\n')) {
        buffer.write(lines.removeLast());
      } else {
        lines.removeLast();
      }

      for (final line in lines) {
        final trimmed = line.trim();
        if (!trimmed.startsWith('data: ')) continue;
        final payload = trimmed.substring(6);
        if (payload == '[DONE]') return;
        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          if (json.containsKey('error')) {
            throw ApiException(-1, json['error'] as String);
          }
          final content = json['content'] as String?;
          if (content != null && content.isNotEmpty) {
            yield content;
          }
        } catch (e) {
          if (e is ApiException) rethrow;
        }
      }
    }
  }

  Future<Task> generateImage({
    required String prompt,
    String provider = '',
    String model = '',
    int? width,
    int? height,
    int count = 1,
    int? projectId,
  }) async {
    final resp = await dio.post('/ai/generate/image', data: {
      'prompt': prompt,
      if (provider.isNotEmpty) 'provider': provider,
      if (model.isNotEmpty) 'model': model,
      'width': ?width,
      'height': ?height,
      if (count > 1) 'count': count,
      'project_id': ?projectId,
    });
    return extractDataObject(resp, Task.fromJson);
  }

  Future<Task> generateVideo({
    required String imageUrl,
    String prompt = '',
    String provider = '',
    String model = '',
    int? duration,
    int? projectId,
  }) async {
    final resp = await dio.post('/ai/generate/video', data: {
      'image_url': imageUrl,
      if (prompt.isNotEmpty) 'prompt': prompt,
      if (provider.isNotEmpty) 'provider': provider,
      if (model.isNotEmpty) 'model': model,
      'duration': ?duration,
      'project_id': ?projectId,
    });
    return extractDataObject(resp, Task.fromJson);
  }
}
