import 'package:anime_ui/pub/models/timeline.dart';
import 'api.dart';

class TimelineService {
  Future<ProjectTimeline> get(int projectId) async {
    final resp = await dio.get('/projects/$projectId/timeline');
    return extractDataObject(resp, ProjectTimeline.fromJson);
  }

  Future<ProjectTimeline> save(
    int projectId, {
    required List<Track> tracks,
    required double duration,
  }) async {
    final resp = await dio.put('/projects/$projectId/timeline', data: {
      'tracks': tracks.map((t) => t.toJson()).toList(),
      'duration': duration,
    });
    return extractDataObject(resp, ProjectTimeline.fromJson);
  }

  Future<ProjectTimeline> autoGenerate(int projectId) async {
    final resp = await dio.post('/projects/$projectId/timeline/auto');
    return extractDataObject(resp, ProjectTimeline.fromJson);
  }
}
