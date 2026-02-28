import 'package:anime_ui/pub/models/lock_status.dart';
import 'api.dart';

class LockService {
  Future<LockStatus> lock(int projectId, String phase) async {
    final resp = await dio.post('/projects/$projectId/lock/$phase');
    return extractDataObject(resp, LockStatus.fromJson);
  }

  Future<LockStatus> unlock(int projectId, String phase) async {
    final resp = await dio.delete('/projects/$projectId/lock/$phase');
    return extractDataObject(resp, LockStatus.fromJson);
  }

  Future<LockStatus> getStatus(int projectId) async {
    final resp = await dio.get('/projects/$projectId/lock');
    return extractDataObject(resp, LockStatus.fromJson);
  }
}
