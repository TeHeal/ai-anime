import 'package:anime_ui/pub/models/media_asset.dart';
import 'package:anime_ui/pub/models/prompt_record.dart';
import 'api.dart';

class MediaAssetService {
  // ── Project-scoped queries ──

  Future<List<MediaAsset>> listByProject(int projectId, {String? type, String? status}) async {
    final resp = await dio.get('/projects/$projectId/media-assets', queryParameters: {
      'type': ?type,
      'status': ?status,
    });
    return extractDataList(resp, MediaAsset.fromJson);
  }

  Future<MediaAssetStats> stats(int projectId) async {
    final resp = await dio.get('/projects/$projectId/media-assets/stats');
    return extractDataObject(resp, MediaAssetStats.fromJson);
  }

  // ── Shot-scoped queries ──

  Future<List<MediaAsset>> listByShot(int projectId, int shotId, {String? type}) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId/media-assets', queryParameters: {
      'type': ?type,
    });
    return extractDataList(resp, MediaAsset.fromJson);
  }

  // ── Character-scoped queries ──

  Future<List<MediaAsset>> listByCharacter(int characterId) async {
    final resp = await dio.get('/characters/$characterId/media-assets');
    return extractDataList(resp, MediaAsset.fromJson);
  }

  // ── Location-scoped queries ──

  Future<List<MediaAsset>> listByLocation(int projectId, int locationId) async {
    final resp = await dio.get('/projects/$projectId/locations/$locationId/media-assets');
    return extractDataList(resp, MediaAsset.fromJson);
  }

  // ── Single asset ──

  Future<MediaAsset> get(int assetId) async {
    final resp = await dio.get('/media-assets/$assetId');
    return extractDataObject(resp, MediaAsset.fromJson);
  }

  // ── Version management ──

  Future<List<MediaAsset>> listVersions(int assetId) async {
    final resp = await dio.get('/media-assets/$assetId/versions');
    return extractDataList(resp, MediaAsset.fromJson);
  }

  Future<void> updateStatus(int assetId, String status) async {
    final resp = await dio.put('/media-assets/$assetId/status', data: {
      'status': status,
    });
    extractData<dynamic>(resp);
  }

  Future<MediaAsset> rollback(int assetId) async {
    final resp = await dio.post('/media-assets/$assetId/rollback');
    return extractDataObject(resp, MediaAsset.fromJson);
  }

  // ── Prompt queries ──

  Future<List<PromptRecord>> listPromptsByProject(int projectId, {String? type}) async {
    final resp = await dio.get('/projects/$projectId/prompts', queryParameters: {
      'type': ?type,
    });
    return extractDataList(resp, PromptRecord.fromJson);
  }

  Future<List<PromptRecord>> listPromptsByShot(int projectId, int shotId) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId/prompts');
    return extractDataList(resp, PromptRecord.fromJson);
  }

  Future<PromptRecord> getPrompt(int promptId) async {
    final resp = await dio.get('/prompts/$promptId');
    return extractDataObject(resp, PromptRecord.fromJson);
  }
}
