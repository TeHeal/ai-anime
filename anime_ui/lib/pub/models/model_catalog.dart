class ModelCatalogItem {
  const ModelCatalogItem({
    required this.id,
    required this.operator,
    required this.operatorLabel,
    required this.brand,
    required this.modelId,
    required this.displayName,
    required this.service,
    this.priority = 0,
    this.features = '',
    this.bestFor = '',
    this.providerName = '',
  });

  final int id;
  final String operator;
  final String operatorLabel;
  final String brand;
  final String modelId;
  final String displayName;
  final String service;
  final int priority;
  final String features;
  final String bestFor;
  final String providerName;

  factory ModelCatalogItem.fromJson(Map<String, dynamic> json) {
    return ModelCatalogItem(
      id: json['id'] as int? ?? 0,
      operator: json['operator'] as String? ?? '',
      operatorLabel: json['operator_label'] as String? ?? json['operator'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      modelId: json['model_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      service: json['service'] as String? ?? '',
      priority: json['priority'] as int? ?? 0,
      features: json['features'] as String? ?? '',
      bestFor: json['best_for'] as String? ?? '',
      providerName: json['provider_name'] as String? ?? '',
    );
  }

  bool get isRecommended => priority >= 100;

  List<String> get featureList =>
      features.isEmpty ? [] : features.split(',').map((f) => f.trim()).toList();

  List<String> get bestForList =>
      bestFor.isEmpty ? [] : bestFor.split(',').map((f) => f.trim()).toList();

  bool matchesBestFor(String tag) =>
      bestFor.isEmpty || bestForList.contains(tag);
}
