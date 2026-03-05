import 'package:flutter/foundation.dart';

import 'package:anime_ui/pub/models/dashboard.dart';
import 'api_svc.dart';

class DashboardService {
  Future<Dashboard> get(String projectId) async {
    final resp = await dio.get('/projects/$projectId/dashboard');
    final raw = extractData<Map<String, dynamic>>(resp);
    // 联调排查：检查 data 结构，确认 episodes 是否从后端返回
    if (kDebugMode) {
      final epList = raw['episodes'];
      final epCount = epList is List ? epList.length : 'null/non-List';
      debugPrint(
        '[Dashboard] projectId=$projectId '
        'totalEpisodes=${raw['totalEpisodes']} episodes类型=${epList.runtimeType} '
        'episodesLength=$epCount',
      );
    }
    return Dashboard.fromJson(raw);
  }
}
