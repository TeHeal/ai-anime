import 'api.dart';

class GenerateGroupStatus {
  final int total;
  final int completed;
  final int pending;
  final int failed;
  final int running;

  const GenerateGroupStatus({
    this.total = 0,
    this.completed = 0,
    this.pending = 0,
    this.failed = 0,
    this.running = 0,
  });

  factory GenerateGroupStatus.fromJson(Map<String, dynamic> json) =>
      GenerateGroupStatus(
        total: (json['total'] as num?)?.toInt() ?? 0,
        completed: (json['completed'] as num?)?.toInt() ?? 0,
        pending: (json['pending'] as num?)?.toInt() ?? 0,
        failed: (json['failed'] as num?)?.toInt() ?? 0,
        running: (json['running'] as num?)?.toInt() ?? 0,
      );

  bool get allDone => completed == total && total > 0;
  bool get hasRunning => running > 0;
  bool get hasFailed => failed > 0;
  double get progress => total > 0 ? completed / total : 0;
}

class GenerateStatus {
  final GenerateGroupStatus characters;
  final GenerateGroupStatus locations;
  final GenerateGroupStatus shots;
  final GenerateGroupStatus videos;
  final GenerateGroupStatus voiceovers;
  final GenerateGroupStatus music;

  const GenerateStatus({
    this.characters = const GenerateGroupStatus(),
    this.locations = const GenerateGroupStatus(),
    this.shots = const GenerateGroupStatus(),
    this.videos = const GenerateGroupStatus(),
    this.voiceovers = const GenerateGroupStatus(),
    this.music = const GenerateGroupStatus(),
  });

  factory GenerateStatus.fromJson(Map<String, dynamic> json) => GenerateStatus(
        characters: GenerateGroupStatus.fromJson(json['characters'] as Map<String, dynamic>? ?? {}),
        locations: GenerateGroupStatus.fromJson(json['locations'] as Map<String, dynamic>? ?? {}),
        shots: GenerateGroupStatus.fromJson(json['shots'] as Map<String, dynamic>? ?? {}),
        videos: GenerateGroupStatus.fromJson(json['videos'] as Map<String, dynamic>? ?? {}),
        voiceovers: GenerateGroupStatus.fromJson(json['voiceovers'] as Map<String, dynamic>? ?? {}),
        music: GenerateGroupStatus.fromJson(json['music'] as Map<String, dynamic>? ?? {}),
      );

  int get totalTasks =>
      characters.total + locations.total + shots.total + videos.total + voiceovers.total + music.total;

  int get completedTasks =>
      characters.completed + locations.completed + shots.completed +
      videos.completed + voiceovers.completed + music.completed;

  int get runningTasks =>
      characters.running + locations.running + shots.running +
      videos.running + voiceovers.running + music.running;

  int get failedTasks =>
      characters.failed + locations.failed + shots.failed +
      videos.failed + voiceovers.failed + music.failed;

  double get overallProgress => totalTasks > 0 ? completedTasks / totalTasks : 0;
  bool get hasRunning => runningTasks > 0;
}

class GenerateService {
  Future<GenerateStatus> getStatus(String projectId) async {
    final resp = await dio.get('/projects/$projectId/generate/status');
    return extractDataObject(resp, GenerateStatus.fromJson);
  }

  Future<Map<String, dynamic>> generateAll(String projectId, {String? provider, String? model}) async {
    final resp = await dio.post('/projects/$projectId/generate/all', data: {
      'provider': ?provider,
      'model': ?model,
    });
    return extractData<Map<String, dynamic>>(resp);
  }

  Future<Map<String, dynamic>> retryFailed(String projectId) async {
    final resp = await dio.post('/projects/$projectId/generate/retry');
    return extractData<Map<String, dynamic>>(resp);
  }
}
