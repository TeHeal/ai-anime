import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'api.dart';

class ScriptAiService {
  Stream<String> assistBlock({
    required String action,
    required String blockType,
    required String blockContent,
    String sceneMeta = '',
    List<String> contextBlocks = const [],
    int projectId = 0,
  }) async* {
    final pid = projectId > 0 ? projectId : 1;

    final resp = await dio.post(
      '/projects/$pid/script/ai-assist',
      data: {
        'action': action,
        'block_type': blockType,
        'block_content': blockContent,
        'scene_meta': sceneMeta,
        'context_blocks': contextBlocks,
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
}
