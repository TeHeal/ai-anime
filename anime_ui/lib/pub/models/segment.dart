import 'package:freezed_annotation/freezed_annotation.dart';

part 'segment.freezed.dart';
part 'segment.g.dart';

@freezed
abstract class ScriptSegment with _$ScriptSegment {
  const factory ScriptSegment({
    int? id,
    int? projectId,
    @Default(0) int sortIndex,
    @Default('') String content,
  }) = _ScriptSegment;

  factory ScriptSegment.fromJson(Map<String, dynamic> json) =>
      _$ScriptSegmentFromJson(json);
}
