import 'package:freezed_annotation/freezed_annotation.dart';

part 'export_record.freezed.dart';
part 'export_record.g.dart';

@freezed
abstract class ExportRecord with _$ExportRecord {
  const ExportRecord._();

  const factory ExportRecord({
    String? id,
    String? projectId,
    @Default('mp4') String format,
    @Default('1080p') String resolution,
    @Default('pending') String status,
    @Default('') String outputUrl,
    @Default(0) int fileSize,
    @Default('') String taskId,
    String? error,
    @Default(0) int progress,
  }) = _ExportRecord;

  factory ExportRecord.fromJson(Map<String, dynamic> json) =>
      _$ExportRecordFromJson(json);

  bool get isReady => status == 'completed' && outputUrl.isNotEmpty;
  bool get isProcessing => status == 'pending' || status == 'running';
}
