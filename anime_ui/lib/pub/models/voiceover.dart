import 'package:freezed_annotation/freezed_annotation.dart';

part 'voiceover.freezed.dart';
part 'voiceover.g.dart';

@freezed
abstract class Voiceover with _$Voiceover {
  const Voiceover._();

  const factory Voiceover({
    int? id,
    int? projectId,
    int? shotId,
    @Default('') String text,
    @Default('') String voiceId,
    @Default('') String voiceName,
    @Default('') String emotion,
    @Default('') String provider,
    @Default('') String model,
    @Default('') String audioUrl,
    @Default(0) double duration,
    @Default('pending') String status,
    @Default('') String taskId,
  }) = _Voiceover;

  factory Voiceover.fromJson(Map<String, dynamic> json) =>
      _$VoiceoverFromJson(json);

  bool get isReady => status == 'completed' && audioUrl.isNotEmpty;
  bool get isProcessing => status == 'pending' || status == 'running';
}
