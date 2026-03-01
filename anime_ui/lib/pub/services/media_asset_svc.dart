import 'package:anime_ui/pub/models/media_asset.dart';
import 'package:anime_ui/pub/models/prompt_record.dart';
import 'api_svc.dart';

class MediaAssetService {
  // ── Project-scoped queries ──

  Future<List<MediaAsset>> listByProject(String projectId, {String? type, String? status}) async {
    final resp = await dio.get('/projects/$projectId/media-assets', queryParameters: {
      if (type != null) 'type': type,
      if (status != null) 'status': status,
    });
    return extractDataList(resp, MediaAsset.fromJson);
  }

  Future<MediaAssetStats> stats(String projectId) async {
    final resp = await dio.get('/projects/$projectId/media-assets/stats');
    return extractDataObject(resp, MediaAssetStats.fromJson);
  }

  // ── Shot-scoped queries ──

  Future<List<MediaAsset>> listByShot(String projectId, String shotId, {String? type}) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId/media-assets', queryParameters: {
      if (type != null) 'type': type,
    });
    return extractDataList(resp, MediaAsset.fromJson);
  }

  // ── Character-scoped queries ──

  Future<List<MediaAsset>> listByCharacter(String characterId) async {
    final resp = await dio.get('/characters/$characterId/media-assets');
    return extractDataList(resp, MediaAsset.fromJson);
  }

  // ── Location-scoped queries ──

  Future<List<MediaAsset>> listByLocation(String projectId, String locationId) async {
    final resp = await dio.get('/projects/$projectId/locations/$locationId/media-assets');
    return extractDataList(resp, MediaAsset.fromJson);
  }

  // ── Single asset ──

  Future<MediaAsset> get(String assetId) async {
    final resp = await dio.get('/media-assets/$assetId');
    return extractDataObject(resp, MediaAsset.fromJson);
  }

  // ── Version management ──

  Future<List<MediaAsset>> listVersions(String assetId) async {
    final resp = await dio.get('/media-assets/$assetId/versions');
    return extractDataList(resp, MediaAsset.fromJson);
  }

  Future<void> updateStatus(String assetId, String status) async {
    final resp = await dio.put('/media-assets/$assetId/status', data: {
      'status': status,
    });
    extractData<dynamic>(resp);
  }

  Future<MediaAsset> rollback(String assetId) async {
    final resp = await dio.post('/media-assets/$assetId/rollback');
    return extractDataObject(resp, MediaAsset.fromJson);
  }

  // ── Prompt queries ──

  Future<List<PromptRecord>> listPromptsByProject(String projectId, {String? type}) async {
    final resp = await dio.get('/projects/$projectId/prompts', queryParameters: {
      if (type != null) 'type': type,
    });
    return extractDataList(resp, PromptRecord.fromJson);
  }

  Future<List<PromptRecord>> listPromptsByShot(String projectId, String shotId) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId/prompts');
    return extractDataList(resp, PromptRecord.fromJson);
  }

  Future<PromptRecord> getPrompt(String promptId) async {
    final resp = await dio.get('/prompts/$promptId');
    return extractDataObject(resp, PromptRecord.fromJson);
  }
}
