import 'package:anime_ui/pub/models/asset_version.dart';
import 'api.dart';

class AssetVersionService {
  Future<List<AssetVersion>> list(String projectId) async {
    final resp = await dio.get('/projects/$projectId/asset-versions');
    return extractDataList(resp, AssetVersion.fromJson);
  }

  Future<AssetVersion> freeze(String projectId) async {
    final resp = await dio.post('/projects/$projectId/asset-versions/freeze');
    return extractDataObject(resp, AssetVersion.fromJson);
  }

  Future<void> unfreeze(String projectId) async {
    final resp = await dio.post('/projects/$projectId/asset-versions/unfreeze');
    extractData<dynamic>(resp);
  }

  Future<Map<String, dynamic>> impact(String projectId) async {
    final resp = await dio.get('/projects/$projectId/asset-versions/impact');
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<void> rollback(String projectId) async {
    final resp = await dio.post('/projects/$projectId/asset-versions/rollback');
    extractData<dynamic>(resp);
  }
}
