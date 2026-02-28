import 'package:shared_preferences/shared_preferences.dart';

import 'package:anime_ui/pub/models/model_catalog.dart';

/// Persists per-service-type model preference locally.
class ModelPreferenceService {
  static const _prefix = 'model_pref_';

  Future<void> save(String serviceType, String modelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$serviceType', modelId);
  }

  Future<String?> load(String serviceType) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$serviceType');
  }

  /// Pick the best default model from a list:
  /// 1) user's last choice (if still in list)
  /// 2) best match for [bestForHint] among recommended models
  /// 3) highest-priority recommended model
  /// 4) first model
  Future<ModelCatalogItem?> pickDefault(
    List<ModelCatalogItem> models, {
    required String serviceType,
    String bestForHint = '',
  }) async {
    if (models.isEmpty) return null;

    final savedId = await load(serviceType);
    if (savedId != null && savedId.isNotEmpty) {
      final saved = models.where((m) => m.modelId == savedId).firstOrNull;
      if (saved != null) return saved;
    }

    if (bestForHint.isNotEmpty) {
      final matched = models
          .where((m) => m.isRecommended && m.matchesBestFor(bestForHint))
          .toList();
      if (matched.isNotEmpty) return matched.first;
    }

    return models.where((m) => m.isRecommended).firstOrNull ?? models.first;
  }
}
