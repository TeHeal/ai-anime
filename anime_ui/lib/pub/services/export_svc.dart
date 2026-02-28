import 'package:anime_ui/pub/models/export_record.dart';
import 'api.dart';

class ExportService {
  Future<ExportRecord> submit(
    String projectId, {
    String format = 'mp4',
    String resolution = '1080p',
  }) async {
    final resp = await dio.post('/projects/$projectId/export', data: {
      'format': format,
      'resolution': resolution,
    });
    return extractDataObject(resp, ExportRecord.fromJson);
  }

  Future<List<ExportRecord>> list({String? projectId}) async {
    final resp = await dio.get('/exports', queryParameters: {
      'project_id': ?projectId,
    });
    return extractDataList(resp, ExportRecord.fromJson);
  }

  Future<ExportRecord> get(String id) async {
    final resp = await dio.get('/exports/$id');
    return extractDataObject(resp, ExportRecord.fromJson);
  }
}
