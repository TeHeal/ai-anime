import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:anime_ui/pub/utils/json_id.dart';

part 'scene_block.freezed.dart';
part 'scene_block.g.dart';

enum BlockType {
  @JsonValue('action')
  action,
  @JsonValue('dialogue')
  dialogue,
  @JsonValue('os')
  os,
  @JsonValue('direction')
  direction,
  @JsonValue('closeup')
  closeup,
}

@freezed
abstract class SceneBlock with _$SceneBlock {
  const factory SceneBlock({
    @JsonKey(fromJson: nullableIdFromJson) String? id,
    @JsonKey(fromJson: nullableIdFromJson) String? sceneId,
    @Default('action') String type,
    @Default('') String character,
    @Default('') String emotion,
    @Default('') String content,
    @Default(0) int sortIndex,
  }) = _SceneBlock;

  factory SceneBlock.fromJson(Map<String, dynamic> json) =>
      _$SceneBlockFromJson(json);
}
