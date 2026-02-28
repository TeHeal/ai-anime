import 'api.dart';

class ShotCompositeService {
  Future<List<dynamic>> batchGenerate(
    int projectId, {
    required List<int> shotIds,
    Map<String, dynamic> config = const {},
  }) async {
    final resp = await dio.post(
      '/projects/$projectId/shot-composite/generate',
      data: {'shot_ids': shotIds, 'config': config},
    );
    return extractData<List>(resp);
  }

  Future<Map<String, dynamic>> getStatus(int projectId) async {
    final resp = await dio.get('/projects/$projectId/shot-composite/status');
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<List<dynamic>> listSubtasks(int projectId, int shotId) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId/subtasks');
    return extractData<List>(resp);
  }

  Future<void> retrySubtask(int projectId, int shotId, String type) async {
    await dio.post('/projects/$projectId/shots/$shotId/subtasks/$type/retry');
  }

  Future<void> updateCompositeReview(int projectId, int shotId, {required String status}) async {
    await dio.put(
      '/projects/$projectId/shots/$shotId/composite-review',
      data: {'status': status},
    );
  }

  Future<void> updateTrackReview(int projectId, int shotId, String trackType, {required String status, int? score}) async {
    await dio.put(
      '/projects/$projectId/shots/$shotId/track-review/$trackType',
      data: {'status': status, ...?score != null ? {'score': score} : null},
    );
  }

  Future<Map<String, dynamic>> triggerCompositeQA(int projectId, int shotId) async {
    final resp = await dio.post('/projects/$projectId/shots/$shotId/composite-qa');
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<Map<String, dynamic>> getCompositeQA(int projectId, int shotId) async {
    final resp = await dio.get('/projects/$projectId/shots/$shotId/composite-qa');
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<void> trackRetry(int projectId, int shotId, String trackType) async {
    await dio.post('/projects/$projectId/shots/$shotId/track-retry/$trackType');
  }

  Future<void> batchReview(int projectId, {required List<int> shotIds, required String status}) async {
    await dio.post(
      '/projects/$projectId/shot-composite/batch-review',
      data: {'shot_ids': shotIds, 'status': status},
    );
  }
}
