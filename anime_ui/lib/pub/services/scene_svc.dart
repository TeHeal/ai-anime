import 'package:anime_ui/pub/models/scene.dart';
import 'package:anime_ui/pub/models/scene_block.dart';
import 'api.dart';

class SceneService {
  String _basePath(int projectId, int episodeId) =>
      '/projects/$projectId/episodes/$episodeId/scenes';

  Future<Scene> create(int projectId, int episodeId, {
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

  Future<List<Scene>> list(int projectId, int episodeId) async {
    final resp = await dio.get(_basePath(projectId, episodeId));
    return extractDataList(resp, Scene.fromJson);
  }

  Future<Scene> get(int projectId, int episodeId, int sceneDbId) async {
    final resp = await dio
        .get('${_basePath(projectId, episodeId)}/$sceneDbId');
    return extractDataObject(resp, Scene.fromJson);
  }

  Future<Scene> update(int projectId, int episodeId, int sceneDbId, {
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

  Future<void> delete(int projectId, int episodeId, int sceneDbId) async {
    final resp = await dio
        .delete('${_basePath(projectId, episodeId)}/$sceneDbId');
    extractData<dynamic>(resp);
  }

  Future<void> reorder(
      int projectId, int episodeId, List<int> orderedIds) async {
    final resp = await dio
        .put('${_basePath(projectId, episodeId)}/reorder', data: {
      'ordered_ids': orderedIds,
    });
    extractData<dynamic>(resp);
  }

  Future<List<SceneBlock>> saveBlocks(
      int projectId, int episodeId, int sceneDbId, List<SceneBlock> blocks) async {
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
