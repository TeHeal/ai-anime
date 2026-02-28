import 'package:anime_ui/pub/models/voice.dart';
import 'api.dart';

class VoiceService {
  Future<Voice> clone({
    required String name,
    required String audioUrl,
    String gender = '',
  }) async {
    final resp = await dio.post('/voices/clone', data: {
      'name': name,
      'audio_url': audioUrl,
      if (gender.isNotEmpty) 'gender': gender,
    });
    return extractDataObject(resp, Voice.fromJson);
  }

  Future<List<Voice>> list({String? gender}) async {
    final resp = await dio.get('/voices', queryParameters: {
      'gender': ?gender,
    });
    return extractDataList(resp, Voice.fromJson);
  }

  Future<Voice> get(int id) async {
    final resp = await dio.get('/voices/$id');
    return extractDataObject(resp, Voice.fromJson);
  }

  Future<Voice> update(int id, {
    String? name,
    String? gender,
    bool? shared,
  }) async {
    final resp = await dio.put('/voices/$id', data: {
      'name': ?name,
      'gender': ?gender,
      'shared': ?shared,
    });
    return extractDataObject(resp, Voice.fromJson);
  }

  Future<void> delete(int id) async {
    await dio.delete('/voices/$id');
  }
}
