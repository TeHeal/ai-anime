import 'package:anime_ui/pub/models/episode.dart';
import 'api.dart';

class EpisodeService {
  Future<Episode> create(int projectId, {
    required String title,
    String summary = '',
  }) async {
    final resp = await dio.post('/projects/$projectId/episodes', data: {
      'title': title,
      'summary': summary,
    });
    return extractDataObject(resp, Episode.fromJson);
  }

  Future<List<Episode>> list(int projectId) async {
    final resp = await dio.get('/projects/$projectId/episodes');
    return extractDataList(resp, Episode.fromJson);
  }

  Future<Episode> get(int projectId, int episodeId) async {
    final resp = await dio.get('/projects/$projectId/episodes/$episodeId');
    return extractDataObject(resp, Episode.fromJson);
  }

  Future<Episode> update(int projectId, int episodeId, {
    String? title,
    String? summary,
    String? status,
    int? currentStep,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (summary != null) body['summary'] = summary;
    if (status != null) body['status'] = status;
    if (currentStep != null) body['current_step'] = currentStep;
    final resp =
        await dio.put('/projects/$projectId/episodes/$episodeId', data: body);
    return extractDataObject(resp, Episode.fromJson);
  }

  Future<void> delete(int projectId, int episodeId) async {
    final resp =
        await dio.delete('/projects/$projectId/episodes/$episodeId');
    extractData<dynamic>(resp);
  }

  Future<void> reorder(int projectId, List<int> orderedIds) async {
    final resp =
        await dio.put('/projects/$projectId/episodes/reorder', data: {
      'ordered_ids': orderedIds,
    });
    extractData<dynamic>(resp);
  }
}
