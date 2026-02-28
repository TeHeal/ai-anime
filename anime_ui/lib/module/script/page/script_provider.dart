import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/episode.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/pub/providers/project.dart';
import 'package:anime_ui/pub/services/storyboard_svc.dart';
import 'package:anime_ui/pub/services/task_svc.dart';

// ---------------------------------------------------------------------------
// 生成配置
// ---------------------------------------------------------------------------

class GenerateConfigNotifier extends Notifier<GenerateConfig> {
  @override
  GenerateConfig build() => GenerateConfig();

  void update({
    String? globalStyle,
    String? defaultNegativePrompt,
    String? productionNotes,
    bool? includeAdjacentSummary,
    String? provider,
    String? model,
  }) {
    state = state.copyWith(
      globalStyle: globalStyle,
      defaultNegativePrompt: defaultNegativePrompt,
      productionNotes: productionNotes,
      includeAdjacentSummary: includeAdjacentSummary,
      provider: provider,
      model: model,
    );
  }
}

final generateConfigProvider =
    NotifierProvider<GenerateConfigNotifier, GenerateConfig>(
        GenerateConfigNotifier.new);

// ---------------------------------------------------------------------------
// 分集生成状态
// ---------------------------------------------------------------------------

class EpisodeStatesNotifier
    extends Notifier<Map<String, EpisodeGenerateState>> {
  @override
  Map<String, EpisodeGenerateState> build() => {};

  StoryboardService get _svc => StoryboardService();
  TaskService get _taskSvc => TaskService();
  String? get _projectId => ref.read(currentProjectProvider).value?.id;

  void initFromEpisodes(List<Episode> episodes, Map<String, int> shotCounts) {
    final map = <String, EpisodeGenerateState>{};
    for (final ep in episodes) {
      if (ep.id == null) continue;
      final existing = state[ep.id];
      final count = shotCounts[ep.id] ?? 0;
      if (existing != null && existing.isGenerating) {
        map[ep.id!] = existing;
      } else {
        map[ep.id!] = EpisodeGenerateState(
          episodeId: ep.id!,
          episodeTitle: ep.title.isNotEmpty
              ? ep.title
              : '第${ep.sortIndex + 1}集',
          status: count > 0
              ? EpisodeScriptStatus.completed
              : EpisodeScriptStatus.notStarted,
          shotCount: count,
        );
      }
    }
    state = map;
  }

  void _update(
    String episodeId,
    EpisodeGenerateState Function(EpisodeGenerateState) fn,
  ) {
    final current = state[episodeId];
    if (current == null) return;
    state = {...state, episodeId: fn(current)};
  }

  Future<void> generateSingle(String episodeId) async {
    final pid = _projectId;
    if (pid == null) return;

    _update(episodeId, (s) => s.copyWith(
      status: EpisodeScriptStatus.generating,
      progress: 5,
      error: null,
    ));

    try {
      try {
        final task = await _svc.generate(pid, episodeId: episodeId);
        await for (final t in _taskSvc.poll(task.taskId)) {
          _update(episodeId, (s) => s.copyWith(progress: t.progress));
          if (t.isCompleted && t.result != null) {
            final shotsList = t.result!['shots'] as List<dynamic>? ?? [];
            final shots = shotsList
                .map((e) => ConfirmShotInput.fromJson(e as Map<String, dynamic>))
                .toList();
            await _svc.confirm(pid, shots);
            _update(episodeId, (s) => s.copyWith(
              status: EpisodeScriptStatus.completed,
              progress: 100,
              shotCount: shots.length,
              pendingCount: shots.length,
            ));
            return;
          }
          if (t.isFailed) {
            _update(episodeId, (s) => s.copyWith(
              status: EpisodeScriptStatus.failed,
              error: t.error ?? '任务失败',
            ));
            return;
          }
        }
      } on Exception catch (e) {
        if (e.toString().contains('异步任务不可用') ||
            e.toString().contains('generate-sync')) {
          final result = await _svc.generateSync(pid, episodeId: episodeId);
          await _svc.confirm(pid, result.shots);
          _update(episodeId, (s) => s.copyWith(
            status: EpisodeScriptStatus.completed,
            progress: 100,
            shotCount: result.shots.length,
            pendingCount: result.shots.length,
          ));
        } else {
          rethrow;
        }
      }
    } catch (e) {
      _update(episodeId, (s) => s.copyWith(
        status: EpisodeScriptStatus.failed,
        error: e.toString(),
      ));
    }
  }

  Future<void> batchGenerate(List<String> episodeIds) async {
    for (final eid in episodeIds) {
      _update(eid, (s) => s.copyWith(
        status: EpisodeScriptStatus.generating,
        progress: 0,
        error: null,
      ));
    }
    await Future.wait(episodeIds.map((eid) => generateSingle(eid)));
  }

  void markCompleted(String episodeId, int shotCount) {
    _update(episodeId, (s) => s.copyWith(
      status: EpisodeScriptStatus.completed,
      progress: 100,
      shotCount: shotCount,
      pendingCount: shotCount,
    ));
  }

  void updateReviewCounts(String episodeId, {
    required int approved,
    required int pending,
    required int revision,
  }) {
    _update(episodeId, (s) => s.copyWith(
      approvedCount: approved,
      pendingCount: pending,
      revisionCount: revision,
    ));
  }
}

final episodeStatesProvider =
    NotifierProvider<EpisodeStatesNotifier, Map<String, EpisodeGenerateState>>(
        EpisodeStatesNotifier.new);

// ---------------------------------------------------------------------------
// 分集脚本数据（ShotV4 列表，按集存储）
// ---------------------------------------------------------------------------

class EpisodeShotsMapNotifier extends Notifier<Map<String, List<ShotV4>>> {
  @override
  Map<String, List<ShotV4>> build() => {};

  List<ShotV4> forEpisode(String episodeId) => state[episodeId] ?? [];

  void setShots(String episodeId, List<ShotV4> shots) {
    state = {...state, episodeId: shots};
  }

  void updateShot(String episodeId, int shotNumber, ShotV4 Function(ShotV4) fn) {
    final list = forEpisode(episodeId);
    state = {
      ...state,
      episodeId: [
        for (final s in list)
          if (s.shotNumber == shotNumber) fn(s) else s,
      ],
    };
  }

  void setReviewStatus(String episodeId, int shotNumber, String status) {
    updateShot(episodeId, shotNumber, (s) => s.copyWith(reviewStatus: status));
  }

  void batchApprove(String episodeId, List<int> shotNumbers) {
    final list = forEpisode(episodeId);
    state = {
      ...state,
      episodeId: [
        for (final s in list)
          if (shotNumbers.contains(s.shotNumber))
            s.copyWith(reviewStatus: 'approved')
          else
            s,
      ],
    };
  }

  void approveAll(String episodeId) {
    final list = forEpisode(episodeId);
    state = {
      ...state,
      episodeId: [for (final s in list) s.copyWith(reviewStatus: 'approved')],
    };
  }

  void addShot(String episodeId) {
    final list = forEpisode(episodeId);
    final nextNum = list.isEmpty ? 1 : list.last.shotNumber + 1;
    state = {
      ...state,
      episodeId: [...list, ShotV4(shotNumber: nextNum)],
    };
  }

  void insertShot(String episodeId, int afterShotNumber) {
    final list = List<ShotV4>.of(forEpisode(episodeId));
    final idx = list.indexWhere((s) => s.shotNumber == afterShotNumber);
    if (idx < 0) return;
    list.insert(idx + 1, ShotV4());
    for (int i = 0; i < list.length; i++) {
      list[i].shotNumber = i + 1;
    }
    state = {...state, episodeId: list};
  }

  void deleteShot(String episodeId, int shotNumber) {
    final list = forEpisode(episodeId)
        .where((s) => s.shotNumber != shotNumber)
        .toList();
    for (int i = 0; i < list.length; i++) {
      list[i].shotNumber = i + 1;
    }
    state = {...state, episodeId: list};
  }
}

final episodeShotsMapProvider =
    NotifierProvider<EpisodeShotsMapNotifier, Map<String, List<ShotV4>>>(
        EpisodeShotsMapNotifier.new);

// ---------------------------------------------------------------------------
// JSON 导入校验
// ---------------------------------------------------------------------------

class ImportResult {
  final bool success;
  final StoryboardScript? script;
  final List<String> errors;
  const ImportResult({
    this.success = false,
    this.script,
    this.errors = const [],
  });
}

ImportResult validateAndParseJson(String jsonStr) {
  try {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final errors = StoryboardScript.validate(data);
    if (errors.isNotEmpty) {
      return ImportResult(errors: errors);
    }
    final script = StoryboardScript.fromJson(data);
    if (script.shots.isEmpty) {
      return const ImportResult(errors: ['镜头列表为空']);
    }
    return ImportResult(success: true, script: script);
  } catch (e) {
    return ImportResult(errors: ['JSON 解析失败: $e']);
  }
}
