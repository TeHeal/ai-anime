import 'package:anime_ui/pub/models/shot.dart';
import 'api.dart';

class ShotService {
  Future<StoryboardShot> create(String projectId, {
    String? segmentId,
    String prompt = '',
    String stylePrompt = '',
    int duration = 5,
  }) async {
    final resp = await dio.post('/projects/$projectId/shots', data: {
      'segment_id': ?segmentId,
      'prompt': prompt,
      'style_prompt': stylePrompt,
      'duration': duration,
    });
    return extractDataObject(resp, StoryboardShot.fromJson);
  }

  Future<List<StoryboardShot>> bulkCreate(String projectId, List<Map<String, dynamic>> shots) async {
    final resp = await dio.put('/projects/$projectId/shots/bulk', data: {
      'shots': shots,
    });
    return extractDataList(resp, StoryboardShot.fromJson);
  }

  Future<List<StoryboardShot>> list(String projectId) async {
    final resp = await dio.get('/projects/$projectId/shots');
    return extractDataList(resp, StoryboardShot.fromJson);
  }

  Future<StoryboardShot> get(String projectId, String shotId) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId');
    return extractDataObject(resp, StoryboardShot.fromJson);
  }

  Future<StoryboardShot> update(String projectId, String shotId, {
    String? prompt,
    String? stylePrompt,
    int? duration,
    String? segmentId,
    String? cameraType,
    String? cameraAngle,
    String? dialogue,
    String? voice,
    String? lipSync,
    String? characterName,
    String? characterId,
    String? emotion,
    String? voiceName,
    String? transition,
    String? audioDesign,
    String? priority,
    String? negativePrompt,
  }) async {
    final body = <String, dynamic>{};
    if (prompt != null) body['prompt'] = prompt;
    if (stylePrompt != null) body['style_prompt'] = stylePrompt;
    if (duration != null) body['duration'] = duration;
    if (segmentId != null) body['segment_id'] = segmentId;
    if (cameraType != null) body['camera_type'] = cameraType;
    if (cameraAngle != null) body['camera_angle'] = cameraAngle;
    if (dialogue != null) body['dialogue'] = dialogue;
    if (voice != null) body['voice'] = voice;
    if (lipSync != null) body['lip_sync'] = lipSync;
    if (characterName != null) body['character_name'] = characterName;
    if (characterId != null) body['character_id'] = characterId;
    if (emotion != null) body['emotion'] = emotion;
    if (voiceName != null) body['voice_name'] = voiceName;
    if (transition != null) body['transition'] = transition;
    if (audioDesign != null) body['audio_design'] = audioDesign;
    if (priority != null) body['priority'] = priority;
    if (negativePrompt != null) body['negative_prompt'] = negativePrompt;
    final resp = await dio.put('/projects/$projectId/shots/$shotId', data: body);
    return extractDataObject(resp, StoryboardShot.fromJson);
  }

  Future<void> delete(String projectId, String shotId) async {
    final resp = await dio.delete('/projects/$projectId/shots/$shotId');
    extractData<dynamic>(resp);
  }

  Future<void> reorder(String projectId, List<String> orderedIds) async {
    final resp = await dio.put('/projects/$projectId/shots/reorder', data: {
      'ordered_ids': orderedIds,
    });
    extractData<dynamic>(resp);
  }

  Future<List<Map<String, dynamic>>> batchGenerateImages(String projectId, {
    required List<String> shotIds,
    String? provider,
    String? model,
    int? width,
    int? height,
  }) async {
    final resp = await dio.post('/projects/$projectId/shots/generate', data: {
      'shot_ids': shotIds,
      'provider': ?provider,
      'model': ?model,
      'width': ?width,
      'height': ?height,
    });
    final data = extractData<List<dynamic>>(resp);
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> generateAllImages(String projectId, {
    String? provider,
    String? model,
    int? width,
    int? height,
  }) async {
    final resp = await dio.post('/projects/$projectId/shots/generate-all', data: {
      'provider': ?provider,
      'model': ?model,
      'width': ?width,
      'height': ?height,
    });
    final data = extractData<List<dynamic>>(resp);
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> batchGenerateVideos(String projectId, {
    required List<String> shotIds,
    String? provider,
    String? model,
    int? duration,
  }) async {
    final resp = await dio.post('/projects/$projectId/shots/generate-video', data: {
      'shot_ids': shotIds,
      'provider': ?provider,
      'model': ?model,
      'duration': ?duration,
    });
    final data = extractData<List<dynamic>>(resp);
    return data.cast<Map<String, dynamic>>();
  }
}
