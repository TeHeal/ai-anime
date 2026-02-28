import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

/// 解析 id/projectId，兼容后端返回 int 或 string（UUID）
String? _nullableIdFromJson(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt().toString();
  return v.toString();
}

@freezed
abstract class Location with _$Location {
  const Location._();

  const factory Location({
    @JsonKey(fromJson: _nullableIdFromJson) String? id,
    @JsonKey(fromJson: _nullableIdFromJson, name: 'projectId') String? projectId,
    @Default('') String name,
    @Default('') String time,
    @Default('') String interiorExterior,
    @Default('') String atmosphere,
    @Default('') String colorTone,
    @Default('') String layout,
    @Default('') String style,
    @Default(false) bool styleOverride,
    @Default('') String styleNote,
    @Default('') String imageUrl,
    @Default('') String referenceImagesJson,
    @Default('') String taskId,
    @Default('none') String imageStatus,
    @Default('draft') String status,
    @Default('manual') String source,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  bool get isGenerating => imageStatus == 'generating';
  bool get hasImage => imageUrl.isNotEmpty && imageStatus == 'completed';
  bool get isConfirmed => status == 'confirmed';
  bool get isSkeleton => status == 'skeleton';
}
