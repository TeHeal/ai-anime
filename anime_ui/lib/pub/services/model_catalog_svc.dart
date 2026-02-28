import 'package:anime_ui/pub/models/model_catalog.dart';
import 'api.dart';

/// Fetches and caches model catalog from the backend.
class ModelCatalogService {
  static final _cache = <String, _CacheEntry>{};
  static const _ttl = Duration(minutes: 5);

  Future<List<ModelCatalogItem>> list({String? service}) async {
    final key = service ?? '__all__';

    final cached = _cache[key];
    if (cached != null && DateTime.now().difference(cached.time) < _ttl) {
      return cached.items;
    }

    final params = <String, dynamic>{};
    if (service != null && service.isNotEmpty) params['service'] = service;

    final resp = await dio.get('/models', queryParameters: params);
    final data = extractData<Map<String, dynamic>>(resp);
    final items = (data['items'] as List<dynamic>?)
            ?.map((e) => ModelCatalogItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    _cache[key] = _CacheEntry(items: items, time: DateTime.now());
    return items;
  }

  /// Force refresh, clearing all cached data.
  void invalidate() => _cache.clear();
}

class _CacheEntry {
  const _CacheEntry({required this.items, required this.time});
  final List<ModelCatalogItem> items;
  final DateTime time;
}
