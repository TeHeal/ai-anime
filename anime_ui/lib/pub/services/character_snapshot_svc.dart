import 'package:anime_ui/pub/models/character_snapshot.dart';
import 'api.dart';

class CharacterSnapshotService {
  Future<List<CharacterSnapshot>> listByCharacter(String characterId) async {
    final resp = await dio.get('/characters/$characterId/snapshots');
    return extractDataList(resp, CharacterSnapshot.fromJson);
  }

  Future<List<CharacterSnapshot>> listByProject(String projectId) async {
    final resp = await dio.get('/projects/$projectId/character-snapshots');
    return extractDataList(resp, CharacterSnapshot.fromJson);
  }

  Future<CharacterSnapshot> create({
    required String characterId,
    required String projectId,
    String startSceneId = '',
    String endSceneId = '',
    String triggerEvent = '',
    String costume = '',
    String hairstyle = '',
    String physicalMarks = '',
    String accessories = '',
    String mentalState = '',
    String demeanor = '',
    String relationshipsJson = '',
    String composedAppearance = '',
    int sortIndex = 0,
  }) async {
    final resp = await dio.post('/character-snapshots', data: {
      'character_id': characterId,
      'project_id': projectId,
      'start_scene_id': startSceneId,
      'end_scene_id': endSceneId,
      'trigger_event': triggerEvent,
      'costume': costume,
      'hairstyle': hairstyle,
      'physical_marks': physicalMarks,
      'accessories': accessories,
      'mental_state': mentalState,
      'demeanor': demeanor,
      'relationships_json': relationshipsJson,
      'composed_appearance': composedAppearance,
      'sort_index': sortIndex,
    });
    return extractDataObject(resp, CharacterSnapshot.fromJson);
  }

  Future<CharacterSnapshot> get(String snapshotId) async {
    final resp = await dio.get('/character-snapshots/$snapshotId');
    return extractDataObject(resp, CharacterSnapshot.fromJson);
  }

  Future<CharacterSnapshot> update(String snapshotId, Map<String, dynamic> fields) async {
    final resp = await dio.put('/character-snapshots/$snapshotId', data: fields);
    return extractDataObject(resp, CharacterSnapshot.fromJson);
  }

  Future<void> delete(String snapshotId) async {
    final resp = await dio.delete('/character-snapshots/$snapshotId');
    extractData<dynamic>(resp);
  }

  Future<Map<String, dynamic>> analyzePreview(String projectId, {String? provider, String? model}) async {
    final resp = await dio.post('/projects/$projectId/characters/analyze-preview', data: {
      'provider': ?provider,
      'model': ?model,
    });
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<Map<String, dynamic>> analyzeConfirm(String projectId, {String? provider, String? model}) async {
    final resp = await dio.post('/projects/$projectId/characters/analyze', data: {
      'provider': ?provider,
      'model': ?model,
    });
    return extractData<Map<String, dynamic>>(resp);
  }
}
