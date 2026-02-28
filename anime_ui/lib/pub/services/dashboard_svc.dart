import 'package:anime_ui/pub/models/dashboard.dart';
import 'api.dart';

class DashboardService {
  Future<Dashboard> get(int projectId) async {
    final resp = await dio.get('/projects/$projectId/dashboard');
    return extractDataObject(resp, Dashboard.fromJson);
  }
}
