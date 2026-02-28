import 'package:freezed_annotation/freezed_annotation.dart';

part 'character_snapshot.freezed.dart';
part 'character_snapshot.g.dart';

@freezed
abstract class CharacterSnapshot with _$CharacterSnapshot {
  const CharacterSnapshot._();

  const factory CharacterSnapshot({
    String? id,
    required String characterId,
    required String projectId,
    @Default('') String startSceneId,
    @Default('') String endSceneId,
    @Default('') String triggerEvent,
    @Default('') String costume,
    @Default('') String hairstyle,
    @Default('') String physicalMarks,
    @Default('') String accessories,
    @Default('') String mentalState,
    @Default('') String demeanor,
    @Default('') String relationshipsJson,
    @Default('') String composedAppearance,
    @Default(0) int sortIndex,
    @Default('ai') String source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CharacterSnapshot;

  factory CharacterSnapshot.fromJson(Map<String, dynamic> json) =>
      _$CharacterSnapshotFromJson(json);

  String get sceneRange {
    if (startSceneId.isEmpty && endSceneId.isEmpty) return '';
    if (startSceneId == endSceneId) return startSceneId;
    return '$startSceneId ~ $endSceneId';
  }

  bool get isHumanEdited => source == 'human' || source == 'mixed';
}
