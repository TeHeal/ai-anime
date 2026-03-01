import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:anime_ui/pub/utils/json_id.dart';

part 'style.freezed.dart';
part 'style.g.dart';

@freezed
abstract class Style with _$Style {
  const Style._();

  const factory Style({
    @JsonKey(fromJson: nullableIdFromJson) String? id,
    @JsonKey(fromJson: nullableIdFromJson, name: 'projectId') String? projectId,
    @Default('') String name,
    @Default('') String description,
    @Default('') String negativePrompt,
    @Default('') String referenceImagesJson,
    @Default('') String thumbnailUrl,
    @Default(false) bool isPreset,
    @Default(false) bool isProjectDefault,
    DateTime? createdAt,
  }) = _Style;

  factory Style.fromJson(Map<String, dynamic> json) => _$StyleFromJson(json);
}
