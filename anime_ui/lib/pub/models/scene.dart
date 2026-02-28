import 'package:freezed_annotation/freezed_annotation.dart';
import 'scene_block.dart';

part 'scene.freezed.dart';
part 'scene.g.dart';

@freezed
abstract class Scene with _$Scene {
  const factory Scene({
    String? id,
    String? episodeId,
    @Default('') String sceneId,
    @Default('') String location,
    @Default('') String time,
    @Default('') String interiorExterior,
    @Default([]) List<String> characters,
    @Default(0) int sortIndex,
    @Default([]) List<SceneBlock> blocks,
  }) = _Scene;

  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);
}
