import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/services/script_parse_svc.dart';

/// 格式提示：0 = 标准格式，1 = 自由格式
class FormatHintNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setHint(int hint) => state = hint;
}

final formatHintProvider =
    NotifierProvider<FormatHintNotifier, int>(FormatHintNotifier.new);

/// 解析状态机
enum ParsePhase { idle, parsing, preview, confirming, done, error }

class ParseState {
  final ParsePhase phase;
  final ScriptParseResult? result;
  final String? errorMessage;
  final int progress;
  final String stepLabel;

  const ParseState({
    this.phase = ParsePhase.idle,
    this.result,
    this.errorMessage,
    this.progress = 0,
    this.stepLabel = '',
  });

  ParseState copyWith({
    ParsePhase? phase,
    ScriptParseResult? result,
    String? errorMessage,
    int? progress,
    String? stepLabel,
  }) {
    return ParseState(
      phase: phase ?? this.phase,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
      stepLabel: stepLabel ?? this.stepLabel,
    );
  }
}

class ParseStateNotifier extends Notifier<ParseState> {
  @override
  ParseState build() => const ParseState();

  final _svc = ScriptParseService();

  Future<void> parseSync(int projectId, String content, int formatHint) async {
    state = const ParseState(
      phase: ParsePhase.parsing,
      progress: 10,
      stepLabel: '正在预处理文本…',
    );

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(progress: 25, stepLabel: '正在识别集与场结构…');

      await Future.delayed(const Duration(milliseconds: 200));
      state = state.copyWith(progress: 40, stepLabel: '正在解析内容块…');

      final hint = formatHint == 0 ? 'standard' : 'unknown';
      if (hint == 'unknown') {
        state = state.copyWith(progress: 50, stepLabel: '正在调用 AI 辅助解析…');
      }

      final result = await _svc.parseSync(
        projectId,
        content: content,
        formatHint: hint,
      );

      state = state.copyWith(progress: 90, stepLabel: '正在生成预览…');
      await Future.delayed(const Duration(milliseconds: 200));

      state = ParseState(
        phase: ParsePhase.preview,
        result: result,
        progress: 100,
        stepLabel: '解析完成',
      );
    } catch (e) {
      state = ParseState(
        phase: ParsePhase.error,
        errorMessage: e.toString(),
        stepLabel: '解析失败',
      );
    }
  }

  Future<void> confirm(int projectId) async {
    final episodes = state.result?.script.episodes;
    if (episodes == null || episodes.isEmpty) return;

    state = state.copyWith(phase: ParsePhase.confirming);
    try {
      await _svc.confirm(projectId, episodes);
      state = state.copyWith(phase: ParsePhase.done);
    } catch (e) {
      state = ParseState(
        phase: ParsePhase.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const ParseState();
  }
}

final parseStateProvider =
    NotifierProvider<ParseStateNotifier, ParseState>(ParseStateNotifier.new);
