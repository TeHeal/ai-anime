import 'package:anime_ui/pub/models/voiceover.dart';
import 'api.dart';

class VoiceoverService {
  Future<Voiceover> generate({
    required String text,
    String voiceId = '',
    String voiceName = '',
    String emotion = '',
    String provider = '',
    String model = '',
    String? projectId,
    String? shotId,
  }) async {
    final resp = await dio.post('/voiceovers', data: {
      'text': text,
      if (voiceId.isNotEmpty) 'voice_id': voiceId,
      if (voiceName.isNotEmpty) 'voice_name': voiceName,
      if (emotion.isNotEmpty) 'emotion': emotion,
      if (provider.isNotEmpty) 'provider': provider,
      if (model.isNotEmpty) 'model': model,
      'project_id': ?projectId,
      'shot_id': ?shotId,
    });
    return extractDataObject(resp, Voiceover.fromJson);
  }

  Future<List<Voiceover>> list({String? projectId, String? shotId}) async {
    final resp = await dio.get('/voiceovers', queryParameters: {
      'project_id': ?projectId,
      'shot_id': ?shotId,
    });
    return extractDataList(resp, Voiceover.fromJson);
  }

  Future<Voiceover> get(String id) async {
    final resp = await dio.get('/voiceovers/$id');
    return extractDataObject(resp, Voiceover.fromJson);
  }

  Future<void> delete(String id) async {
    await dio.delete('/voiceovers/$id');
  }
}
