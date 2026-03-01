import 'package:anime_ui/pub/models/dashboard.dart';
import 'api_svc.dart';

class DashboardService {
  Future<Dashboard> get(String projectId) async {
    final resp = await dio.get('/projects/$projectId/dashboard');
    return extractDataObject(resp, Dashboard.fromJson);
  }
}
