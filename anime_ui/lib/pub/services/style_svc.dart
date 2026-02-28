import 'package:anime_ui/pub/models/style.dart';
import 'api.dart';

class StyleService {
  Future<Style> create(String projectId, {
    required String name,
    String description = '',
    String negativePrompt = '',
    String referenceImagesJson = '',
    String thumbnailUrl = '',
    bool isProjectDefault = false,
  }) async {
    final resp = await dio.post('/projects/$projectId/styles', data: {
      'name': name,
      'description': description,
      'negative_prompt': negativePrompt,
      'reference_images_json': referenceImagesJson,
      'thumbnail_url': thumbnailUrl,
      'is_project_default': isProjectDefault,
    });
    return extractDataObject(resp, Style.fromJson);
  }

  Future<List<Style>> list(String projectId) async {
    final resp = await dio.get('/projects/$projectId/styles');
    return extractDataList(resp, Style.fromJson);
  }

  Future<Style> get(String projectId, String styleId) async {
    final resp = await dio.get('/projects/$projectId/styles/$styleId');
    return extractDataObject(resp, Style.fromJson);
  }

  Future<Style> update(String projectId, String styleId, {
    String? name,
    String? description,
    String? negativePrompt,
    String? referenceImagesJson,
    String? thumbnailUrl,
    bool? isProjectDefault,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (negativePrompt != null) body['negative_prompt'] = negativePrompt;
    if (referenceImagesJson != null) body['reference_images_json'] = referenceImagesJson;
    if (thumbnailUrl != null) body['thumbnail_url'] = thumbnailUrl;
    if (isProjectDefault != null) body['is_project_default'] = isProjectDefault;
    final resp = await dio.put('/projects/$projectId/styles/$styleId', data: body);
    return extractDataObject(resp, Style.fromJson);
  }

  Future<void> delete(String projectId, String styleId) async {
    await dio.delete('/projects/$projectId/styles/$styleId');
  }

  Future<int> applyAll(String projectId, String styleId) async {
    final resp = await dio.post('/projects/$projectId/styles/$styleId/apply-all');
    final data = extractData<Map<String, dynamic>>(resp);
    return data['applied'] as int? ?? 0;
  }
}
