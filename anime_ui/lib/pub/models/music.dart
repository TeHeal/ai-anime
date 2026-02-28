import 'package:freezed_annotation/freezed_annotation.dart';

part 'music.freezed.dart';
part 'music.g.dart';

@freezed
abstract class Music with _$Music {
  const Music._();

  const factory Music({
    int? id,
    int? projectId,
    @Default('') String title,
    @Default('') String prompt,
    @Default('') String provider,
    @Default('') String model,
    @Default('') String audioUrl,
    @Default(0) double duration,
    @Default('pending') String status,
    @Default('') String taskId,
  }) = _Music;

  factory Music.fromJson(Map<String, dynamic> json) => _$MusicFromJson(json);

  bool get isReady => status == 'completed' && audioUrl.isNotEmpty;
  bool get isProcessing => status == 'pending' || status == 'running';
}
