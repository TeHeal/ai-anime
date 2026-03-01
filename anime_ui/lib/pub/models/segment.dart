import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:anime_ui/pub/utils/json_id.dart';

part 'segment.freezed.dart';
part 'segment.g.dart';

@freezed
abstract class ScriptSegment with _$ScriptSegment {
  const factory ScriptSegment({
    @JsonKey(fromJson: nullableIdFromJson) String? id,
    @JsonKey(fromJson: nullableIdFromJson, name: 'projectId') String? projectId,
    @Default(0) int sortIndex,
    @Default('') String content,
  }) = _ScriptSegment;

  factory ScriptSegment.fromJson(Map<String, dynamic> json) =>
      _$ScriptSegmentFromJson(json);
}
