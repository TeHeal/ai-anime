import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice.freezed.dart';
part 'voice.g.dart';

@freezed
abstract class Voice with _$Voice {
  const Voice._();

  const factory Voice({
    String? id,
    @Default('') String name,
    @Default('') String gender,
    @Default('') String voiceId,
    @Default('') String provider,
    @Default('') String audioUrl,
    @Default('pending') String status,
    @Default('') String taskId,
    String? error,
    @Default(false) bool shared,
  }) = _Voice;

  factory Voice.fromJson(Map<String, dynamic> json) => _$VoiceFromJson(json);

  bool get isReady => status == 'completed' && voiceId.isNotEmpty;
  bool get isProcessing => status == 'pending' || status == 'running';
}
