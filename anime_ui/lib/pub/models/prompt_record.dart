import 'package:freezed_annotation/freezed_annotation.dart';

part 'prompt_record.freezed.dart';
part 'prompt_record.g.dart';

@freezed
abstract class PromptRecord with _$PromptRecord {
  const PromptRecord._();

  const factory PromptRecord({
    String? id,
    required String projectId,
    required String userId,
    String? episodeId,
    String? sceneId,
    String? shotId,
    String? characterId,
    String? locationId,
    @Default('') String type,
    @Default('') String inputText,
    @Default('') String fullPrompt,
    @Default('') String negativePrompt,
    @Default('') String provider,
    @Default('') String model,
    @Default('') String paramsJson,
    @Default('ai') String createdBy,
    @Default('') String assetIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PromptRecord;

  factory PromptRecord.fromJson(Map<String, dynamic> json) =>
      _$PromptRecordFromJson(json);

  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isTTS => type == 'tts';
  bool get isMusic => type == 'music';
}
