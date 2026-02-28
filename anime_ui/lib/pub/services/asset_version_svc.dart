import 'package:anime_ui/pub/models/asset_version.dart';
import 'api.dart';

class AssetVersionService {
  Future<List<AssetVersion>> list(int projectId) async {
    final resp = await dio.get('/projects/$projectId/asset-versions');
    return extractDataList(resp, AssetVersion.fromJson);
  }

  Future<AssetVersion> freeze(int projectId) async {
    final resp = await dio.post('/projects/$projectId/asset-versions/freeze');
    return extractDataObject(resp, AssetVersion.fromJson);
  }

  Future<void> unfreeze(int projectId) async {
    final resp = await dio.post('/projects/$projectId/asset-versions/unfreeze');
    extractData<dynamic>(resp);
  }

  Future<Map<String, dynamic>> impact(int projectId) async {
    final resp = await dio.get('/projects/$projectId/asset-versions/impact');
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<void> rollback(int projectId) async {
    final resp = await dio.post('/projects/$projectId/asset-versions/rollback');
    extractData<dynamic>(resp);
  }
}
