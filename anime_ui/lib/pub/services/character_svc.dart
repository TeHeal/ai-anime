import 'package:anime_ui/pub/models/character.dart';
import 'api.dart';

class CharacterService {
  Future<Character> create({
    int? projectId,
    required String name,
    String appearance = '',
    String style = '',
    String personality = '',
    String voiceHint = '',
    String emotions = '',
    String scenes = '',
    String gender = '',
    String ageGroup = '',
    String voiceId = '',
    String voiceName = '',
    String imageUrl = '',
    bool shared = false,
  }) async {
    final resp = await dio.post('/characters', data: {
      'project_id': ?projectId,
      'name': name,
      'appearance': appearance,
      'style': style,
      'personality': personality,
      'voice_hint': voiceHint,
      'emotions': emotions,
      'scenes': scenes,
      'gender': gender,
      'age_group': ageGroup,
      'voice_id': voiceId,
      'voice_name': voiceName,
      'image_url': imageUrl,
      'shared': shared,
    });
    return extractDataObject(resp, Character.fromJson);
  }

  Future<List<Character>> listLibrary() async {
    final resp = await dio.get('/characters');
    return extractDataList(resp, Character.fromJson);
  }

  Future<List<Character>> listByProject(int projectId) async {
    final resp = await dio.get('/projects/$projectId/characters');
    return extractDataList(resp, Character.fromJson);
  }

  Future<Character> get(int id) async {
    final resp = await dio.get('/characters/$id');
    return extractDataObject(resp, Character.fromJson);
  }

  Future<Character> update(int id, {
    String? name,
    String? appearance,
    String? style,
    String? personality,
    String? voiceHint,
    String? emotions,
    String? scenes,
    String? gender,
    String? ageGroup,
    String? voiceId,
    String? voiceName,
    String? imageUrl,
    bool? shared,
    String? importance,
    String? consistency,
    String? roleType,
    String? tagsJson,
    String? propsJson,
    String? bio,
    String? bioFragmentsJson,
    String? imageGenOverrideJson,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (appearance != null) body['appearance'] = appearance;
    if (style != null) body['style'] = style;
    if (personality != null) body['personality'] = personality;
    if (voiceHint != null) body['voice_hint'] = voiceHint;
    if (emotions != null) body['emotions'] = emotions;
    if (scenes != null) body['scenes'] = scenes;
    if (gender != null) body['gender'] = gender;
    if (ageGroup != null) body['age_group'] = ageGroup;
    if (voiceId != null) body['voice_id'] = voiceId;
    if (voiceName != null) body['voice_name'] = voiceName;
    if (imageUrl != null) body['image_url'] = imageUrl;
    if (shared != null) body['shared'] = shared;
    if (importance != null) body['importance'] = importance;
    if (consistency != null) body['consistency'] = consistency;
    if (roleType != null) body['role_type'] = roleType;
    if (tagsJson != null) body['tags_json'] = tagsJson;
    if (propsJson != null) body['props_json'] = propsJson;
    if (bio != null) body['bio'] = bio;
    if (bioFragmentsJson != null) body['bio_fragments_json'] = bioFragmentsJson;
    if (imageGenOverrideJson != null) body['image_gen_override_json'] = imageGenOverrideJson;
    final resp = await dio.put('/characters/$id', data: body);
    return extractDataObject(resp, Character.fromJson);
  }

  Future<void> delete(int id) async {
    final resp = await dio.delete('/characters/$id');
    extractData<dynamic>(resp);
  }

  Future<Character> confirm(int id) async {
    final resp = await dio.post('/characters/$id/confirm');
    return extractDataObject(resp, Character.fromJson);
  }

  Future<void> batchConfirm(List<int> ids) async {
    final resp = await dio.post('/characters/batch-confirm', data: {'ids': ids});
    extractData<dynamic>(resp);
  }

  Future<int> batchSetStyle(List<int> ids, String style) async {
    final resp = await dio.post('/characters/batch-set-style', data: {'ids': ids, 'style': style});
    final data = extractData<Map<String, dynamic>>(resp);
    return data['updated'] as int? ?? 0;
  }

  Future<int> batchAIComplete(List<int> ids) async {
    final resp = await dio.post('/characters/batch-ai-complete', data: {'ids': ids});
    final data = extractData<Map<String, dynamic>>(resp);
    return data['completed'] as int? ?? 0;
  }

  Future<Character> addVariant(int charId, {
    required String label,
    int? episodeId,
    String? sceneId,
    String? appearance,
    String? referenceImage,
  }) async {
    final resp = await dio.post('/characters/$charId/variants', data: {
      'label': label,
      'episode_id': ?episodeId,
      'scene_id': ?sceneId,
      'appearance': ?appearance,
      'reference_image': ?referenceImage,
    });
    return extractDataObject(resp, Character.fromJson);
  }

  Future<Character> updateVariant(int charId, int idx, {
    String? label,
    String? appearance,
    String? referenceImage,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (label != null) body['label'] = label;
    if (appearance != null) body['appearance'] = appearance;
    if (referenceImage != null) body['reference_image'] = referenceImage;
    if (status != null) body['status'] = status;
    final resp = await dio.put('/characters/$charId/variants/$idx', data: body);
    return extractDataObject(resp, Character.fromJson);
  }

  Future<Character> deleteVariant(int charId, int idx) async {
    final resp = await dio.delete('/characters/$charId/variants/$idx');
    return extractDataObject(resp, Character.fromJson);
  }

  Future<Character> generateImage(int id, {String? provider, String? model}) async {
    final resp = await dio.post('/characters/$id/generate-image', data: {
      'provider': ?provider,
      'model': ?model,
    });
    return extractDataObject(resp, Character.fromJson);
  }

  Future<Character> addReferenceImage(int charId, {
    required String angle,
    required String url,
    Map<String, dynamic>? genMeta,
  }) async {
    final resp = await dio.post('/characters/$charId/reference-images', data: {
      'angle': angle,
      'url': url,
      'genMeta': ?genMeta,
    });
    return extractDataObject(resp, Character.fromJson);
  }

  Future<Character> deleteReferenceImage(int charId, int idx) async {
    final resp = await dio.delete('/characters/$charId/reference-images/$idx');
    return extractDataObject(resp, Character.fromJson);
  }

  Future<Character> extractBio(int projectId, int charId, {String? provider, String? model}) async {
    final resp = await dio.post('/projects/$projectId/characters/$charId/extract-bio', data: {
      'provider': ?provider,
      'model': ?model,
    });
    return extractDataObject(resp, Character.fromJson);
  }

  Future<Character> updateBio(int charId, String bio) async {
    final resp = await dio.patch('/characters/$charId/bio', data: {'bio': bio});
    return extractDataObject(resp, Character.fromJson);
  }

  Future<Character> regenerateBio(int charId, {String? provider, String? model}) async {
    final resp = await dio.post('/characters/$charId/regenerate-bio', data: {
      'provider': ?provider,
      'model': ?model,
    });
    return extractDataObject(resp, Character.fromJson);
  }

  Future<Map<String, dynamic>> generateCandidates(int charId, {
    String? angle,
    int? variantIdx,
    int count = 4,
    Map<String, dynamic>? override,
  }) async {
    final resp = await dio.post('/characters/$charId/generate-candidates', data: {
      'angle': ?angle,
      'variantIdx': ?variantIdx,
      'count': count,
      'override': ?override,
    });
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<Map<String, dynamic>> getCandidates(int charId, String taskId) async {
    final resp = await dio.get('/characters/$charId/candidates', queryParameters: {'taskId': taskId});
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<Character> selectCandidate(int charId, {
    required String taskId,
    required int candidateIdx,
    required String action,
    String? angle,
  }) async {
    final resp = await dio.post('/characters/$charId/candidates/select', data: {
      'taskId': taskId,
      'candidateIdx': candidateIdx,
      'action': action,
      'angle': ?angle,
    });
    return extractDataObject(resp, Character.fromJson);
  }
}
