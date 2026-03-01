import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:anime_ui/pub/utils/json_id.dart';

part 'prop.freezed.dart';
part 'prop.g.dart';

@freezed
abstract class Prop with _$Prop {
  const Prop._();

  const factory Prop({
    @JsonKey(fromJson: nullableIdFromJson) String? id,
    @JsonKey(fromJson: nullableIdFromJson, name: 'projectId') String? projectId,
    @Default('') String name,
    @Default('') String appearance,
    @Default(false) bool isKeyProp,
    @Default('') String style,
    @Default(false) bool styleOverride,
    @Default('') String referenceImagesJson,
    @Default('') String imageUrl,
    @Default('') String usedByJson,
    @Default('') String scenesJson,
    @Default('draft') String status,
    @Default('manual') String source,
  }) = _Prop;

  factory Prop.fromJson(Map<String, dynamic> json) => _$PropFromJson(json);

  bool get isConfirmed => status == 'confirmed';
  bool get isSkeleton => status == 'skeleton';
}
