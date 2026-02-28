import 'package:anime_ui/pub/models/music.dart';
import 'api.dart';

class MusicService {
  Future<Music> generate({
    required String prompt,
    String title = '',
    String provider = '',
    String model = '',
    int? projectId,
  }) async {
    final resp = await dio.post('/music', data: {
      'prompt': prompt,
      if (title.isNotEmpty) 'title': title,
      if (provider.isNotEmpty) 'provider': provider,
      if (model.isNotEmpty) 'model': model,
      'project_id': ?projectId,
    });
    return extractDataObject(resp, Music.fromJson);
  }

  Future<List<Music>> list({int? projectId}) async {
    final resp = await dio.get('/music', queryParameters: {
      'project_id': ?projectId,
    });
    return extractDataList(resp, Music.fromJson);
  }

  Future<Music> get(int id) async {
    final resp = await dio.get('/music/$id');
    return extractDataObject(resp, Music.fromJson);
  }

  Future<void> delete(int id) async {
    await dio.delete('/music/$id');
  }
}
