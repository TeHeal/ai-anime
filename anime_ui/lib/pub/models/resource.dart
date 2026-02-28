import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'resource.freezed.dart';
part 'resource.g.dart';

@freezed
abstract class Resource with _$Resource {
  const Resource._();

  const factory Resource({
    int? id,
    int? userId,
    @Default('') String name,
    @Default('') String libraryType,
    @Default('') String modality,
    @Default('') String thumbnailUrl,
    @Default('') String tagsJson,
    @Default('') String version,
    @Default('') String metadataJson,
    @Default('') String bindingIdsJson,
    @Default('') String description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Resource;

  factory Resource.fromJson(Map<String, dynamic> json) =>
      _$ResourceFromJson(json);

  List<String> get tags {
    if (tagsJson.isEmpty) return [];
    try {
      return (jsonDecode(tagsJson) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> get metadata {
    if (metadataJson.isEmpty) return {};
    try {
      return jsonDecode(metadataJson) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  List<int> get bindingIds {
    if (bindingIdsJson.isEmpty) return [];
    try {
      return (jsonDecode(bindingIdsJson) as List).cast<int>();
    } catch (_) {
      return [];
    }
  }

  bool get hasThumbnail => thumbnailUrl.isNotEmpty;
}
