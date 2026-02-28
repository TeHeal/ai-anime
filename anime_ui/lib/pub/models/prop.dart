import 'package:freezed_annotation/freezed_annotation.dart';

part 'prop.freezed.dart';
part 'prop.g.dart';

/// 解析 id/projectId，兼容后端返回 int 或 string（UUID）
String? _nullableIdFromJson(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt().toString();
  return v.toString();
}

@freezed
abstract class Prop with _$Prop {
  const Prop._();

  const factory Prop({
    @JsonKey(fromJson: _nullableIdFromJson) String? id,
    @JsonKey(fromJson: _nullableIdFromJson, name: 'projectId') String? projectId,
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
