/// 分镜脚本 v4.0 — 视觉配置与生成状态模型
///
/// 图像 / 视频 / 叠加特效 / 口型同步配置，以及分集生成状态。
library;

// ---------------------------------------------------------------------------
// 图像配置
// ---------------------------------------------------------------------------

class ShotImageConfig {
  bool enabled;
  String type;
  String prompt;
  String negativePrompt;
  String style;
  String aspectRatio;
  String resolution;
  String priority;
  OverlayEffect? overlay;

  ShotImageConfig({
    this.enabled = false, this.type = '静态图', this.prompt = '',
    this.negativePrompt = '', this.style = '', this.aspectRatio = '16:9',
    this.resolution = '1920x1080', this.priority = '', this.overlay,
  });

  factory ShotImageConfig.fromJson(Map<String, dynamic> j) => ShotImageConfig(
        enabled: j['启用'] as bool? ?? false, type: j['类型'] as String? ?? '静态图',
        prompt: j['提示词'] as String? ?? '',
        negativePrompt: (j['反向提示词'] ?? j['负面词']) as String? ?? '',
        style: j['风格'] as String? ?? '', aspectRatio: j['宽高比'] as String? ?? '16:9',
        resolution: j['分辨率'] as String? ?? '1920x1080', priority: j['优先级'] as String? ?? '',
        overlay: j['叠加特效'] != null ? OverlayEffect.fromJson(j['叠加特效'] as Map<String, dynamic>) : null,
      );

  Map<String, dynamic> toJson() => {
        '启用': enabled, '类型': type, '提示词': prompt, '反向提示词': negativePrompt,
        '风格': style, '宽高比': aspectRatio, '分辨率': resolution, '优先级': priority,
        if (overlay != null) '叠加特效': overlay!.toJson(),
      };
}

// ---------------------------------------------------------------------------
// 视频配置
// ---------------------------------------------------------------------------

class ShotVideoConfig {
  bool enabled;
  String type;
  String prompt;
  String negativePrompt;
  String cameraMovement;
  String transition;
  List<String> dependsOn;
  int frameRate;
  String priority;
  OverlayEffect? overlay;
  LipSyncConfig? lipSync;

  ShotVideoConfig({
    this.enabled = false, this.type = '动态视频', this.prompt = '',
    this.negativePrompt = '', this.cameraMovement = '', this.transition = '',
    this.dependsOn = const [], this.frameRate = 24, this.priority = '',
    this.overlay, this.lipSync,
  });

  factory ShotVideoConfig.fromJson(Map<String, dynamic> j) => ShotVideoConfig(
        enabled: j['启用'] as bool? ?? false, type: j['类型'] as String? ?? '动态视频',
        prompt: j['提示词'] as String? ?? '',
        negativePrompt: (j['反向提示词'] ?? j['负面词']) as String? ?? '',
        cameraMovement: j['运镜方式'] as String? ?? '', transition: j['转场方式'] as String? ?? '',
        dependsOn: _strList(j['依赖']), frameRate: (j['帧率'] as num?)?.toInt() ?? 24,
        priority: j['优先级'] as String? ?? '',
        overlay: j['叠加特效'] != null ? OverlayEffect.fromJson(j['叠加特效'] as Map<String, dynamic>) : null,
        lipSync: j['口型同步'] != null ? LipSyncConfig.fromJson(j['口型同步'] as Map<String, dynamic>) : null,
      );

  Map<String, dynamic> toJson() => {
        '启用': enabled, '类型': type, '提示词': prompt, '反向提示词': negativePrompt,
        '运镜方式': cameraMovement, '转场方式': transition, '依赖': dependsOn,
        '帧率': frameRate, '优先级': priority,
        if (overlay != null) '叠加特效': overlay!.toJson(),
        if (lipSync != null) '口型同步': lipSync!.toJson(),
      };
}

class OverlayEffect {
  bool enabled;
  String type;
  String prompt;
  String negativePrompt;
  String priority;

  OverlayEffect({
    this.enabled = false, this.type = '静态图', this.prompt = '',
    this.negativePrompt = '', this.priority = '',
  });

  factory OverlayEffect.fromJson(Map<String, dynamic> j) => OverlayEffect(
        enabled: j['启用'] as bool? ?? false, type: j['类型'] as String? ?? '静态图',
        prompt: j['提示词'] as String? ?? '',
        negativePrompt: (j['反向提示词'] ?? j['负面词']) as String? ?? '',
        priority: j['优先级'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        '启用': enabled, '类型': type, '提示词': prompt, '反向提示词': negativePrompt, '优先级': priority,
      };
}

class LipSyncConfig {
  bool enabled;
  String type;
  List<String> dependsOn;
  String priority;

  LipSyncConfig({
    this.enabled = false, this.type = '口型同步',
    this.dependsOn = const [], this.priority = '',
  });

  factory LipSyncConfig.fromJson(Map<String, dynamic> j) => LipSyncConfig(
        enabled: j['启用'] as bool? ?? false, type: j['类型'] as String? ?? '口型同步',
        dependsOn: _strList(j['依赖']), priority: j['优先级'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        '启用': enabled, '类型': type, '依赖': dependsOn, '优先级': priority,
      };
}

// ---------------------------------------------------------------------------
// 生成配置（存储在前端 state，发送给后端 batch-generate）
// ---------------------------------------------------------------------------

class GenerateConfig {
  String globalStyle;
  String defaultNegativePrompt;
  String productionNotes;
  bool includeAdjacentSummary;
  String provider;
  String model;

  GenerateConfig({
    this.globalStyle = '2D漫风，色调偏暗，无失真无穿帮',
    this.defaultNegativePrompt = '失真，穿帮，模糊，低质量',
    this.productionNotes = '对话用定镜，动作用跟镜/推拉镜',
    this.includeAdjacentSummary = true,
    this.provider = '',
    this.model = '',
  });

  Map<String, dynamic> toJson() => {
        'global_style': globalStyle,
        'negative_prompt': defaultNegativePrompt,
        'production_notes': productionNotes,
        'include_adjacent_summary': includeAdjacentSummary,
        if (provider.isNotEmpty) 'provider': provider,
        if (model.isNotEmpty) 'model': model,
      };

  GenerateConfig copyWith({
    String? globalStyle,
    String? defaultNegativePrompt,
    String? productionNotes,
    bool? includeAdjacentSummary,
    String? provider,
    String? model,
  }) => GenerateConfig(
    globalStyle: globalStyle ?? this.globalStyle,
    defaultNegativePrompt: defaultNegativePrompt ?? this.defaultNegativePrompt,
    productionNotes: productionNotes ?? this.productionNotes,
    includeAdjacentSummary: includeAdjacentSummary ?? this.includeAdjacentSummary,
    provider: provider ?? this.provider,
    model: model ?? this.model,
  );
}

// ---------------------------------------------------------------------------
// 分集生成状态
// ---------------------------------------------------------------------------

enum EpisodeScriptStatus { notStarted, generating, completed, failed }

class EpisodeGenerateState {
  final int episodeId;
  final String episodeTitle;
  final EpisodeScriptStatus status;
  final int progress;
  final int shotCount;
  final String? taskId;
  final String? error;
  /// 审核统计
  final int approvedCount;
  final int pendingCount;
  final int revisionCount;

  const EpisodeGenerateState({
    required this.episodeId,
    this.episodeTitle = '',
    this.status = EpisodeScriptStatus.notStarted,
    this.progress = 0,
    this.shotCount = 0,
    this.taskId,
    this.error,
    this.approvedCount = 0,
    this.pendingCount = 0,
    this.revisionCount = 0,
  });

  EpisodeGenerateState copyWith({
    EpisodeScriptStatus? status,
    int? progress,
    int? shotCount,
    String? taskId,
    String? error,
    int? approvedCount,
    int? pendingCount,
    int? revisionCount,
  }) => EpisodeGenerateState(
    episodeId: episodeId,
    episodeTitle: episodeTitle,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    shotCount: shotCount ?? this.shotCount,
    taskId: taskId ?? this.taskId,
    error: error,
    approvedCount: approvedCount ?? this.approvedCount,
    pendingCount: pendingCount ?? this.pendingCount,
    revisionCount: revisionCount ?? this.revisionCount,
  );

  bool get isComplete => status == EpisodeScriptStatus.completed;
  bool get isGenerating => status == EpisodeScriptStatus.generating;
  bool get isFailed => status == EpisodeScriptStatus.failed;
  bool get allApproved => isComplete && shotCount > 0 && approvedCount == shotCount;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<String> _strList(dynamic v) =>
    (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
