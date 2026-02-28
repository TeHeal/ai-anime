import 'package:dio/dio.dart';

import 'package:anime_ui/pub/models/dashboard.dart';
import 'api.dart';

class DashboardService {
  Future<Dashboard> get(String projectId) async {
    try {
      final resp = await dio.get('/projects/$projectId/dashboard');
      return extractDataObject(resp, Dashboard.fromJson);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Dashboard();
      }
      rethrow;
    }
  }
}
