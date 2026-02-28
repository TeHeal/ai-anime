import 'package:anime_ui/pub/models/asset.dart';
import 'api.dart';

class AssetService {
  Future<Asset> create({
    String? projectId,
    required String type,
    required String name,
    String desc = '',
    String imageUrl = '',
    String tags = '',
    bool shared = false,
  }) async {
    final resp = await dio.post('/assets', data: {
      'project_id': ?projectId,
      'type': type,
      'name': name,
      'desc': desc,
      'image_url': imageUrl,
      'tags': tags,
      'shared': shared,
    });
    return extractDataObject(resp, Asset.fromJson);
  }

  Future<List<Asset>> list({String? type}) async {
    final resp = await dio.get('/assets', queryParameters: {
      'type': ?type,
    });
    return extractDataList(resp, Asset.fromJson);
  }

  Future<List<Asset>> listByProject(String projectId) async {
    final resp = await dio.get('/projects/$projectId/assets');
    return extractDataList(resp, Asset.fromJson);
  }

  Future<Asset> get(String id) async {
    final resp = await dio.get('/assets/$id');
    return extractDataObject(resp, Asset.fromJson);
  }

  Future<Asset> update(String id, {
    String? name,
    String? desc,
    String? imageUrl,
    String? tags,
    bool? shared,
  }) async {
    final resp = await dio.put('/assets/$id', data: {
      'name': ?name,
      'desc': ?desc,
      'image_url': ?imageUrl,
      'tags': ?tags,
      'shared': ?shared,
    });
    return extractDataObject(resp, Asset.fromJson);
  }

  Future<void> delete(String id) async {
    await dio.delete('/assets/$id');
  }
}
