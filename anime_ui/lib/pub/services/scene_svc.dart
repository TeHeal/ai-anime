import 'package:anime_ui/pub/models/scene.dart';
import 'package:anime_ui/pub/models/scene_block.dart';
import 'api.dart';

class SceneService {
  String _basePath(String projectId, String episodeId) =>
      '/projects/$projectId/episodes/$episodeId/scenes';

  Future<Scene> create(String projectId, String episodeId, {
    required String sceneId,
    String location = '',
    String time = '',
    String interiorExterior = '',
    List<String> characters = const [],
  }) async {
    final resp = await dio.post(_basePath(projectId, episodeId), data: {
      'scene_id': sceneId,
      'location': location,
      'time': time,
      'interior_exterior': interiorExterior,
      'characters': characters,
    });
    return extractDataObject(resp, Scene.fromJson);
  }

  Future<List<Scene>> list(String projectId, String episodeId) async {
    final resp = await dio.get(_basePath(projectId, episodeId));
    return extractDataList(resp, Scene.fromJson);
  }

  Future<Scene> get(String projectId, String episodeId, String sceneDbId) async {
    final resp = await dio
        .get('${_basePath(projectId, episodeId)}/$sceneDbId');
    return extractDataObject(resp, Scene.fromJson);
  }

  Future<Scene> update(String projectId, String episodeId, String sceneDbId, {
    String? sceneId,
    String? location,
    String? time,
    String? interiorExterior,
    List<String>? characters,
  }) async {
    final body = <String, dynamic>{};
    if (sceneId != null) body['scene_id'] = sceneId;
    if (location != null) body['location'] = location;
    if (time != null) body['time'] = time;
    if (interiorExterior != null) body['interior_exterior'] = interiorExterior;
    if (characters != null) body['characters'] = characters;
    final resp = await dio
        .put('${_basePath(projectId, episodeId)}/$sceneDbId', data: body);
    return extractDataObject(resp, Scene.fromJson);
  }

  Future<void> delete(String projectId, String episodeId, String sceneDbId) async {
    final resp = await dio
        .delete('${_basePath(projectId, episodeId)}/$sceneDbId');
    extractData<dynamic>(resp);
  }

  Future<void> reorder(
      String projectId, String episodeId, List<String> orderedIds) async {
    final resp = await dio
        .put('${_basePath(projectId, episodeId)}/reorder', data: {
      'ordered_ids': orderedIds,
    });
    extractData<dynamic>(resp);
  }

  Future<List<SceneBlock>> saveBlocks(
      String projectId, String episodeId, String sceneDbId, List<SceneBlock> blocks) async {
    final resp = await dio.put(
      '${_basePath(projectId, episodeId)}/$sceneDbId/blocks',
      data: {
        'blocks': blocks
            .map((b) => {
                  'type': b.type,
                  'character': b.character,
                  'emotion': b.emotion,
                  'content': b.content,
                  'sort_index': b.sortIndex,
                })
            .toList(),
      },
    );
    return extractDataList(resp, SceneBlock.fromJson);
  }
}
