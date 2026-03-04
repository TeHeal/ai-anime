import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'resource.freezed.dart';
part 'resource.g.dart';

/// 兼容后端 int 或 String（UUID）的 id 解析
String? _resourceIdFromJson(dynamic v) {
  if (v == null) return null;
  if (v is String) return v.isEmpty ? null : v;
  if (v is num) return v.toInt().toString();
  return null;
}

@freezed
abstract class Resource with _$Resource {
  const Resource._();

  const factory Resource({
    @JsonKey(fromJson: _resourceIdFromJson) String? id,
    @JsonKey(fromJson: _resourceIdFromJson) String? userId,
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

  /// 绑定 ID 列表（可为 int 或 String，统一转为 String）
  List<String> get bindingIds {
    if (bindingIdsJson.isEmpty) return [];
    try {
      return (jsonDecode(bindingIdsJson) as List)
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  bool get hasThumbnail => thumbnailUrl.isNotEmpty;

  /// 音色类素材的音频 URL（从 metadata.audioUrl 或 metadata.audio_url 读取）
  String get audioUrl {
    final m = metadata;
    return (m['audioUrl'] as String?) ??
        (m['audio_url'] as String?) ??
        '';
  }
}
