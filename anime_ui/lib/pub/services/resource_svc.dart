import 'package:anime_ui/pub/models/resource.dart';
import 'api.dart';

class ResourceService {
  Future<Resource> create({
    required String name,
    required String libraryType,
    required String modality,
    String thumbnailUrl = '',
    String tagsJson = '',
    String version = '',
    String metadataJson = '',
    String bindingIdsJson = '',
    String description = '',
  }) async {
    final resp = await dio.post('/resources', data: {
      'name': name,
      'library_type': libraryType,
      'modality': modality,
      'thumbnail_url': thumbnailUrl,
      'tags_json': tagsJson,
      'version': version,
      'metadata_json': metadataJson,
      'binding_ids_json': bindingIdsJson,
      'description': description,
    });
    return extractDataObject(resp, Resource.fromJson);
  }

  Future<ResourceListResult> list({
    String? modality,
    String? libraryType,
    String? search,
    List<String>? tags,
    String? sortBy,
    int page = 1,
    int pageSize = 50,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (modality != null && modality.isNotEmpty) params['modality'] = modality;
    if (libraryType != null && libraryType.isNotEmpty) {
      params['library_type'] = libraryType;
    }
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (tags != null && tags.isNotEmpty) params['tags'] = tags;
    if (sortBy != null && sortBy.isNotEmpty) params['sort_by'] = sortBy;

    final resp = await dio.get('/resources', queryParameters: params);
    final data = extractData<Map<String, dynamic>>(resp);
    final items = (data['items'] as List<dynamic>?)
            ?.map((e) => Resource.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return ResourceListResult(
      items: items,
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? 1,
      pageSize: data['page_size'] as int? ?? pageSize,
    );
  }

  Future<Resource> get(String resourceId) async {
    final resp = await dio.get('/resources/$resourceId');
    return extractDataObject(resp, Resource.fromJson);
  }

  Future<Resource> update(String resourceId, {
    String? name,
    String? thumbnailUrl,
    String? tagsJson,
    String? version,
    String? metadataJson,
    String? bindingIdsJson,
    String? description,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (thumbnailUrl != null) body['thumbnail_url'] = thumbnailUrl;
    if (tagsJson != null) body['tags_json'] = tagsJson;
    if (version != null) body['version'] = version;
    if (metadataJson != null) body['metadata_json'] = metadataJson;
    if (bindingIdsJson != null) body['binding_ids_json'] = bindingIdsJson;
    if (description != null) body['description'] = description;
    final resp = await dio.put('/resources/$resourceId', data: body);
    return extractDataObject(resp, Resource.fromJson);
  }

  Future<void> delete(String resourceId) async {
    await dio.delete('/resources/$resourceId');
  }

  Future<Map<String, int>> counts({String? modality}) async {
    final params = <String, dynamic>{};
    if (modality != null && modality.isNotEmpty) params['modality'] = modality;
    final resp = await dio.get('/resources/counts', queryParameters: params);
    final data = extractData<Map<String, dynamic>>(resp);
    final counts = data['counts'] as Map<String, dynamic>? ?? {};
    return counts.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  Future<GenerateResourceResult> generateImage({
    required String name,
    required String libraryType,
    required String modality,
    required String prompt,
    String negativePrompt = '',
    String referenceImageUrl = '',
    String provider = '',
    String model = '',
    int? width,
    int? height,
    String size = '',
    int? seed,
    String aspectRatio = '',
    String tagsJson = '',
    String description = '',
  }) async {
    final resp = await dio.post('/resources/generate-image', data: {
      'name': name,
      'library_type': libraryType,
      'modality': modality,
      'prompt': prompt,
      if (negativePrompt.isNotEmpty) 'negative_prompt': negativePrompt,
      if (referenceImageUrl.isNotEmpty) 'reference_image_url': referenceImageUrl,
      if (provider.isNotEmpty) 'provider': provider,
      if (model.isNotEmpty) 'model': model,
      'width': ?width,
      'height': ?height,
      if (size.isNotEmpty) 'size': size,
      if (seed != null && seed != 0) 'seed': seed,
      if (aspectRatio.isNotEmpty) 'aspect_ratio': aspectRatio,
      if (tagsJson.isNotEmpty) 'tags_json': tagsJson,
      if (description.isNotEmpty) 'description': description,
    });
    final data = extractData<Map<String, dynamic>>(resp);
    return GenerateResourceResult(
      resource: Resource.fromJson(data['resource'] as Map<String, dynamic>),
      taskId: data['task_id'] as String? ?? '',
    );
  }

  Future<GenerateResourceResult> generateVoice({
    required String name,
    required String sampleUrl,
    String provider = '',
    String tagsJson = '',
    String description = '',
  }) async {
    final resp = await dio.post('/resources/generate-voice', data: {
      'name': name,
      'sample_url': sampleUrl,
      if (provider.isNotEmpty) 'provider': provider,
      if (tagsJson.isNotEmpty) 'tags_json': tagsJson,
      if (description.isNotEmpty) 'description': description,
    });
    final data = extractData<Map<String, dynamic>>(resp);
    return GenerateResourceResult(
      resource: Resource.fromJson(data['resource'] as Map<String, dynamic>),
      taskId: data['task_id'] as String? ?? '',
    );
  }

  Future<GenerateResourceResult> generateVoiceDesign({
    required String name,
    required String prompt,
    String previewText = '',
    String provider = '',
    String model = '',
    String voiceId = '',
    String tagsJson = '',
    String description = '',
  }) async {
    final resp = await dio.post('/resources/generate-voice-design', data: {
      'name': name,
      'prompt': prompt,
      if (previewText.isNotEmpty) 'preview_text': previewText,
      if (provider.isNotEmpty) 'provider': provider,
      if (model.isNotEmpty) 'model': model,
      if (voiceId.isNotEmpty) 'voice_id': voiceId,
      if (tagsJson.isNotEmpty) 'tags_json': tagsJson,
      if (description.isNotEmpty) 'description': description,
    });
    final data = extractData<Map<String, dynamic>>(resp);
    return GenerateResourceResult(
      resource: Resource.fromJson(data['resource'] as Map<String, dynamic>),
      taskId: data['task_id'] as String? ?? '',
    );
  }

  Future<String> generatePreviewText({
    required String voicePrompt,
    String operator = '',
    String model = '',
  }) async {
    final resp = await dio.post('/resources/generate-preview-text', data: {
      'voice_prompt': voicePrompt,
      if (operator.isNotEmpty) 'operator': operator,
      if (model.isNotEmpty) 'model': model,
    });
    final data = extractData<Map<String, dynamic>>(resp);
    return data['text'] as String? ?? '';
  }

  Future<Resource> syncVoiceResource(String resourceId) async {
    final resp = await dio.post('/resources/$resourceId/sync-voice');
    final data = extractData<Map<String, dynamic>>(resp);
    return Resource.fromJson(data['resource'] as Map<String, dynamic>);
  }

  Future<Resource> generatePrompt({
    required String name,
    required String instruction,
    String targetModel = '',
    String category = '',
    String tagsJson = '',
    String description = '',
    String libraryType = '',
    String language = '',
  }) async {
    final resp = await dio.post('/resources/generate-prompt', data: {
      'name': name,
      'instruction': instruction,
      if (targetModel.isNotEmpty) 'target_model': targetModel,
      if (category.isNotEmpty) 'category': category,
      if (tagsJson.isNotEmpty) 'tags_json': tagsJson,
      if (description.isNotEmpty) 'description': description,
      if (libraryType.isNotEmpty) 'library_type': libraryType,
      if (language.isNotEmpty) 'language': language,
    });
    final data = extractData<Map<String, dynamic>>(resp);
    return Resource.fromJson(data['resource'] as Map<String, dynamic>);
  }
}

class GenerateResourceResult {
  const GenerateResourceResult({required this.resource, required this.taskId});
  final Resource resource;
  final String taskId;
}

class ResourceListResult {
  const ResourceListResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<Resource> items;
  final int total;
  final int page;
  final int pageSize;
}
