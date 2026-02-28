import 'api.dart';

class ShotCompositeService {
  Future<List<dynamic>> batchGenerate(
    String projectId, {
    required List<String> shotIds,
    Map<String, dynamic> config = const {},
  }) async {
    final resp = await dio.post(
      '/projects/$projectId/shot-composite/generate',
      data: {'shot_ids': shotIds, 'config': config},
    );
    return extractData<List>(resp);
  }

  Future<Map<String, dynamic>> getStatus(String projectId) async {
    final resp = await dio.get('/projects/$projectId/shot-composite/status');
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<List<dynamic>> listSubtasks(String projectId, String shotId) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId/subtasks');
    return extractData<List>(resp);
  }

  Future<void> retrySubtask(String projectId, String shotId, String type) async {
    await dio.post('/projects/$projectId/shots/$shotId/subtasks/$type/retry');
  }

  Future<void> updateCompositeReview(String projectId, String shotId, {required String status}) async {
    await dio.put(
      '/projects/$projectId/shots/$shotId/composite-review',
      data: {'status': status},
    );
  }

  Future<void> updateTrackReview(String projectId, String shotId, String trackType, {required String status, int? score}) async {
    await dio.put(
      '/projects/$projectId/shots/$shotId/track-review/$trackType',
      data: {'status': status, ...?score != null ? {'score': score} : null},
    );
  }

  Future<Map<String, dynamic>> triggerCompositeQA(String projectId, String shotId) async {
    final resp = await dio.post('/projects/$projectId/shots/$shotId/composite-qa');
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<Map<String, dynamic>> getCompositeQA(String projectId, String shotId) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId/composite-qa');
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<void> trackRetry(String projectId, String shotId, String trackType) async {
    await dio.post('/projects/$projectId/shots/$shotId/track-retry/$trackType');
  }

  Future<void> batchReview(String projectId, {required List<String> shotIds, required String status}) async {
    await dio.post(
      '/projects/$projectId/shot-composite/batch-review',
      data: {'shot_ids': shotIds, 'status': status},
    );
  }
}
