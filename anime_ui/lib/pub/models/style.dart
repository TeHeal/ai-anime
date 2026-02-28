import 'package:freezed_annotation/freezed_annotation.dart';

part 'style.freezed.dart';
part 'style.g.dart';

@freezed
abstract class Style with _$Style {
  const Style._();

  const factory Style({
    String? id,
    String? projectId,
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
