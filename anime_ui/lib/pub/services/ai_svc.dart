import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:anime_ui/pub/models/image_gen_output.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/models/task.dart';
import 'api_svc.dart';
import 'resource_svc.dart';

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

  /// 统一图生接口，支持 output 参数
  /// output.type=resource 时返回占位 Resource + taskId（异步生成）
  Future<GenerateResourceResult> generateImage({
    required String prompt,
    String negativePrompt = '',
    List<String> referenceImageUrls = const [],
    String provider = '',
    String model = '',
    int? width,
    int? height,
    String aspectRatio = '',
    required ImageGenOutput output,
  }) async {
    final body = <String, dynamic>{
      'prompt': prompt,
      'output': output.toJson(),
    };
    if (negativePrompt.isNotEmpty) body['negativePrompt'] = negativePrompt;
    if (referenceImageUrls.isNotEmpty) {
      body['referenceImageUrls'] = referenceImageUrls;
    }
    if (provider.isNotEmpty) body['provider'] = provider;
    if (model.isNotEmpty) body['model'] = model;
    if (width != null && width > 0) body['width'] = width;
    if (height != null && height > 0) body['height'] = height;
    if (aspectRatio.isNotEmpty) body['aspectRatio'] = aspectRatio;

    final resp = await dio.post('/ai/generate/image', data: body);
    final data = extractData<Map<String, dynamic>>(resp);
    return GenerateResourceResult(
      resource: Resource.fromJson(data['resource'] as Map<String, dynamic>),
      taskId: data['taskId'] as String? ?? data['task_id'] as String? ?? '',
    );
  }

  /// 统一文本生成接口，action=prompt 时同步返回 Resource
  Future<Resource> generateText({
    required String action,
    required String instruction,
    String name = '',
    String targetModel = '',
    String category = '',
    String libraryType = '',
    String language = '',
    String referenceText = '',
  }) async {
    final data = <String, dynamic>{
      'action': action,
      'instruction': instruction,
      'output': {'type': 'resource'},
    };
    if (name.isNotEmpty) data['name'] = name;
    if (targetModel.isNotEmpty) data['targetModel'] = targetModel;
    if (category.isNotEmpty) data['category'] = category;
    if (libraryType.isNotEmpty) data['libraryType'] = libraryType;
    if (language.isNotEmpty) data['language'] = language;
    if (referenceText.isNotEmpty) data['referenceText'] = referenceText;

    final resp = await dio.post('/ai/generate/text', data: data);
    return extractDataObject(resp, Resource.fromJson);
  }

  Future<Task> generateVideo({
    required String imageUrl,
    String prompt = '',
    String provider = '',
    String model = '',
    int? duration,
    String? projectId,
  }) async {
    final resp = await dio.post('/ai/generate/video', data: {
      'image_url': imageUrl,
      if (prompt.isNotEmpty) 'prompt': prompt,
      if (provider.isNotEmpty) 'provider': provider,
      if (model.isNotEmpty) 'model': model,
      ...?duration != null ? {'duration': duration} : null,
      ...?projectId != null ? {'project_id': projectId} : null,
    });
    return extractDataObject(resp, Task.fromJson);
  }
}
