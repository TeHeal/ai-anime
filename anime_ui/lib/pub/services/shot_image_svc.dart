import 'api.dart';

class ShotImageService {
  /// Batch generate shot images.
  Future<List<dynamic>> batchGenerate(
    int projectId, {
    required List<int> shotIds,
    Map<String, dynamic> config = const {},
  }) async {
    final resp = await dio.post(
      '/projects/$projectId/shot-images/generate',
      data: {'shot_ids': shotIds, 'config': config},
    );
    return extractData<List>(resp);
  }

  /// Get generation status summary for all shots.
  Future<Map<String, dynamic>> getStatus(int projectId) async {
    final resp = await dio.get('/projects/$projectId/shot-images/status');
    return extractData<Map<String, dynamic>>(resp);
  }

  /// Get candidate images for a shot (card-draw mode).
  Future<List<dynamic>> getCandidates(int projectId, int shotId) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId/candidates');
    return extractData<List>(resp);
  }

  /// Select a candidate as the final shot image.
  Future<void> selectCandidate(int projectId, {required int shotId, required int assetId}) async {
    await dio.post(
      '/projects/$projectId/shot-images/select-candidate',
      data: {'shot_id': shotId, 'asset_id': assetId},
    );
  }

  /// Update image review status for a shot.
  Future<void> updateImageReview(int projectId, int shotId, {required String status, String? comment}) async {
    await dio.put(
      '/projects/$projectId/shots/$shotId/image-review',
      data: {'status': status, ...?comment != null ? {'comment': comment} : null},
    );
  }

  /// Trigger AI QA review for a shot image.
  Future<Map<String, dynamic>> triggerQA(int projectId, int shotId) async {
    final resp = await dio.post('/projects/$projectId/shots/$shotId/image-qa');
    return extractData<Map<String, dynamic>>(resp);
  }

  /// Get QA review results.
  Future<Map<String, dynamic>> getQAResult(int projectId, int shotId) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId/image-qa');
    return extractData<Map<String, dynamic>>(resp);
  }

  /// Batch review.
  Future<void> batchReview(int projectId, {required List<int> shotIds, required String status}) async {
    await dio.post(
      '/projects/$projectId/shot-images/batch-review',
      data: {'shot_ids': shotIds, 'status': status},
    );
  }
}
