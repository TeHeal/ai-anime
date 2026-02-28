import 'package:freezed_annotation/freezed_annotation.dart';

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
    String? id,
    String? sceneId,
    @Default('action') String type,
    @Default('') String character,
    @Default('') String emotion,
    @Default('') String content,
    @Default(0) int sortIndex,
  }) = _SceneBlock;

  factory SceneBlock.fromJson(Map<String, dynamic> json) =>
      _$SceneBlockFromJson(json);
}
