import 'api.dart';

class ShotImageService {
  Future<List<dynamic>> batchGenerate(
    String projectId, {
    required List<String> shotIds,
    Map<String, dynamic> config = const {},
  }) async {
    final resp = await dio.post(
      '/projects/$projectId/shot-images/generate',
      data: {'shot_ids': shotIds, 'config': config},
    );
    return extractData<List>(resp);
  }

  Future<Map<String, dynamic>> getStatus(String projectId) async {
    final resp = await dio.get('/projects/$projectId/shot-images/status');
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<List<dynamic>> getCandidates(String projectId, String shotId) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId/candidates');
    return extractData<List>(resp);
  }

  Future<void> selectCandidate(String projectId, {required String shotId, required String assetId}) async {
    await dio.post(
      '/projects/$projectId/shot-images/select-candidate',
      data: {'shot_id': shotId, 'asset_id': assetId},
    );
  }

  Future<void> updateImageReview(String projectId, String shotId, {required String status, String? comment}) async {
    await dio.put(
      '/projects/$projectId/shots/$shotId/image-review',
      data: {'status': status, ...?comment != null ? {'comment': comment} : null},
    );
  }

  Future<Map<String, dynamic>> triggerQA(String projectId, String shotId) async {
    final resp = await dio.post('/projects/$projectId/shots/$shotId/image-qa');
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<Map<String, dynamic>> getQAResult(String projectId, String shotId) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId/image-qa');
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<void> batchReview(String projectId, {required List<String> shotIds, required String status}) async {
    await dio.post(
      '/projects/$projectId/shot-images/batch-review',
      data: {'shot_ids': shotIds, 'status': status},
    );
  }
}
