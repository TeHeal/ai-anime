import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
abstract class Task with _$Task {
  const Task._();

  const factory Task({
    required int id,
    required String taskId,
    required String type,
    required String status,
    @Default('') String provider,
    @Default('') String model,
    String? error,
    @Default(0) int progress,
    Map<String, dynamic>? result,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  bool get isPending => status == 'pending';
  bool get isRunning => status == 'running';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isFinished => isCompleted || isFailed || status == 'cancelled';
}
