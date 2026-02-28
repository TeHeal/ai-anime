import 'package:anime_ui/pub/models/timeline.dart';
import 'api.dart';

class TimelineService {
  Future<ProjectTimeline> get(String projectId) async {
    final resp = await dio.get('/projects/$projectId/timeline');
    return extractDataObject(resp, ProjectTimeline.fromJson);
  }

  Future<ProjectTimeline> save(
    String projectId, {
    required List<Track> tracks,
    required double duration,
  }) async {
    final resp = await dio.put('/projects/$projectId/timeline', data: {
      'tracks': tracks.map((t) => t.toJson()).toList(),
      'duration': duration,
    });
    return extractDataObject(resp, ProjectTimeline.fromJson);
  }

  Future<ProjectTimeline> autoGenerate(String projectId) async {
    final resp = await dio.post('/projects/$projectId/timeline/auto');
    return extractDataObject(resp, ProjectTimeline.fromJson);
  }
}
