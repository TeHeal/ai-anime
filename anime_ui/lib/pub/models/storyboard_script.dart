/// 分镜脚本 v4.0 数据模型（对齐 docs/7.格式模板/03.分镜脚本_模板.json）
///
/// 前端主要用于：JSON 导入校验、AI 生成结果解析、结构化编辑器
library;

import 'storyboard_script_visual.dart';
export 'storyboard_script_visual.dart';

// ---------------------------------------------------------------------------
// 顶层：分镜脚本
// ---------------------------------------------------------------------------

class StoryboardScript {
  final String version;
  final String formatId;
  final String project;
  final int episodeNum;
  final String episodeTitle;
  final ControlledVocabulary? vocabulary;
  final ProjectMeta? projectMeta;
  final List<ShotV4> shots;

  const StoryboardScript({
    this.version = '4.0',
    this.formatId = 'storyboard_ai_v4',
    this.project = '',
    this.episodeNum = 1,
    this.episodeTitle = '',
    this.vocabulary,
    this.projectMeta,
    this.shots = const [],
  });

  factory StoryboardScript.fromJson(Map<String, dynamic> json) {
    return StoryboardScript(
      version: json['版本'] as String? ?? '4.0',
      formatId: json['格式标识'] as String? ?? 'storyboard_ai_v4',
      project: json['项目'] as String? ?? '',
      episodeNum: (json['集数'] as num?)?.toInt() ?? 1,
      episodeTitle: json['集标题'] as String? ?? '',
      vocabulary: json['受控词表'] != null
          ? ControlledVocabulary.fromJson(json['受控词表'] as Map<String, dynamic>)
          : null,
      projectMeta: json['项目元信息'] != null
          ? ProjectMeta.fromJson(json['项目元信息'] as Map<String, dynamic>)
          : null,
      shots: (json['镜头列表'] as List<dynamic>?)
              ?.map((e) => ShotV4.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        '版本': version,
        '格式标识': formatId,
        '项目': project,
        '集数': episodeNum,
        '集标题': episodeTitle,
        if (vocabulary != null) '受控词表': vocabulary!.toJson(),
        if (projectMeta != null) '项目元信息': projectMeta!.toJson(),
        '镜头列表': shots.map((s) => s.toJson()).toList(),
      };

  /// 基本 schema 校验
  static List<String> validate(Map<String, dynamic> json) {
    final errors = <String>[];
    if (json['版本'] == null) errors.add('缺少「版本」字段');
    if (json['镜头列表'] == null) {
      errors.add('缺少「镜头列表」字段');
    } else if (json['镜头列表'] is! List) {
      errors.add('「镜头列表」应为数组');
    }
    return errors;
  }
}

// ---------------------------------------------------------------------------
// 受控词表
// ---------------------------------------------------------------------------

class ControlledVocabulary {
  final List<String> cameraScales;
  final List<String> cameraMovements;
  final List<String> transitions;
  final List<String> priorities;
  final List<String> generateTasks;

  const ControlledVocabulary({
    this.cameraScales = const ['大特写', '特写', '近景', '中景', '中远景', '全景', '远景', '大远景'],
    this.cameraMovements = const ['固定', '推', '拉', '摇', '移', '跟', '升', '降', '环绕', '其他'],
    this.transitions = const ['硬切', '淡入淡出', '闪白', '叠化', '划变', '淡入黑屏', '无'],
    this.priorities = const ['P0必出', 'P1核心', 'P2过渡'],
    this.generateTasks = const ['图像', '视频', 'TTS', '音效', 'BGM', '转场'],
  });

  factory ControlledVocabulary.fromJson(Map<String, dynamic> json) {
    return ControlledVocabulary(
      cameraScales: _strList(json['景别']),
      cameraMovements: _strList(json['运镜']),
      transitions: _strList(json['转场']),
      priorities: _strList(json['优先级']),
      generateTasks: _strList(json['生成任务']),
    );
  }

  Map<String, dynamic> toJson() => {
        '景别': cameraScales,
        '运镜': cameraMovements,
        '转场': transitions,
        '优先级': priorities,
        '生成任务': generateTasks,
      };
}

// ---------------------------------------------------------------------------
// 项目元信息
// ---------------------------------------------------------------------------

class ProjectMeta {
  final String globalStyle;
  final String defaultNegativePrompt;
  final ProductionNotes? productionNotes;

  const ProjectMeta({
    this.globalStyle = '',
    this.defaultNegativePrompt = '',
    this.productionNotes,
  });

  factory ProjectMeta.fromJson(Map<String, dynamic> json) {
    return ProjectMeta(
      globalStyle: json['全局风格'] as String? ?? '',
      defaultNegativePrompt:
          (json['默认反向提示词'] ?? json['默认负面词']) as String? ?? '',
      productionNotes: json['制作适配说明'] != null
          ? ProductionNotes.fromJson(json['制作适配说明'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '全局风格': globalStyle,
        '默认反向提示词': defaultNegativePrompt,
        if (productionNotes != null) '制作适配说明': productionNotes!.toJson(),
      };
}

class ProductionNotes {
  final String rhythm;
  final String cameraRules;
  final String audioRules;
  final String aiRequirements;

  const ProductionNotes({
    this.rhythm = '',
    this.cameraRules = '',
    this.audioRules = '',
    this.aiRequirements = '',
  });

  factory ProductionNotes.fromJson(Map<String, dynamic> json) {
    return ProductionNotes(
      rhythm: json['节奏把控'] as String? ?? '',
      cameraRules: json['运镜规范'] as String? ?? '',
      audioRules: json['音频准则'] as String? ?? '',
      aiRequirements: json['AI生成要求'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '节奏把控': rhythm,
        '运镜规范': cameraRules,
        '音频准则': audioRules,
        'AI生成要求': aiRequirements,
      };
}

// ---------------------------------------------------------------------------
// 镜头 V4
// ---------------------------------------------------------------------------

class ShotV4 {
  int shotNumber;
  double duration;
  TimeRange? timeline;
  String priority;
  String cameraScale;
  String cameraMovement;
  String characterPosition;
  String sceneDescription;
  String dialogue;
  String characterName;
  String characterId;
  String emotionDescription;
  List<double> emotionVector;
  String audioDesignText;
  String aiPrompt;
  String negativePrompt;
  String transition;
  List<String> generateTasks;
  ShotAudioConfig? audio;
  ShotImageConfig? image;
  ShotVideoConfig? video;
  DependencyInfo? dependencies;
  String notes;

  /// 审核状态：pending / approved / needsRevision
  String reviewStatus;

  ShotV4({
    this.shotNumber = 1,
    this.duration = 2.5,
    this.timeline,
    this.priority = 'P1核心',
    this.cameraScale = '全景',
    this.cameraMovement = '固定',
    this.characterPosition = '',
    this.sceneDescription = '',
    this.dialogue = '',
    this.characterName = '',
    this.characterId = '',
    this.emotionDescription = '',
    this.emotionVector = const [],
    this.audioDesignText = '',
    this.aiPrompt = '',
    this.negativePrompt = '',
    this.transition = '硬切',
    this.generateTasks = const [],
    this.audio,
    this.image,
    this.video,
    this.dependencies,
    this.notes = '',
    this.reviewStatus = 'pending',
  });

  factory ShotV4.fromJson(Map<String, dynamic> json) {
    return ShotV4(
      shotNumber: (json['镜号'] as num?)?.toInt() ?? 1,
      duration: (json['时长'] as num?)?.toDouble() ?? 2.5,
      timeline: json['时间轴'] != null
          ? TimeRange.fromJson(json['时间轴'] as Map<String, dynamic>)
          : null,
      priority: json['优先级'] as String? ?? 'P1核心',
      cameraScale: json['景别'] as String? ?? '全景',
      cameraMovement: json['运镜方式'] as String? ?? '固定',
      characterPosition: json['角色站位'] as String? ?? '',
      sceneDescription: json['画面描述'] as String? ?? '',
      dialogue: json['台词'] as String? ?? '',
      characterName: json['角色'] as String? ?? '',
      characterId: json['角色ID'] as String? ?? '',
      emotionDescription: json['情绪描述'] as String? ?? '',
      emotionVector: _doubleList(json['情绪向量']),
      audioDesignText: json['音频设计'] as String? ?? '',
      aiPrompt: json['AI提示词'] as String? ?? '',
      negativePrompt: (json['反向提示词'] ?? json['负面词']) as String? ?? '',
      transition: json['转场方式'] as String? ?? '硬切',
      generateTasks: _strList(json['生成任务']),
      audio: json['音频'] != null
          ? ShotAudioConfig.fromJson(json['音频'] as Map<String, dynamic>)
          : null,
      image: json['图像'] != null
          ? ShotImageConfig.fromJson(json['图像'] as Map<String, dynamic>)
          : null,
      video: json['视频'] != null
          ? ShotVideoConfig.fromJson(json['视频'] as Map<String, dynamic>)
          : null,
      dependencies: json['依赖关系'] != null
          ? DependencyInfo.fromJson(json['依赖关系'] as Map<String, dynamic>)
          : null,
      notes: json['备注'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '镜号': shotNumber,
        '时长': duration,
        if (timeline != null) '时间轴': timeline!.toJson(),
        '优先级': priority,
        '景别': cameraScale,
        '运镜方式': cameraMovement,
        '角色站位': characterPosition,
        '画面描述': sceneDescription,
        '台词': dialogue,
        '角色': characterName,
        '角色ID': characterId,
        '情绪描述': emotionDescription,
        '情绪向量': emotionVector,
        '音频设计': audioDesignText,
        'AI提示词': aiPrompt,
        '反向提示词': negativePrompt,
        '转场方式': transition,
        '生成任务': generateTasks,
        if (audio != null) '音频': audio!.toJson(),
        if (image != null) '图像': image!.toJson(),
        if (video != null) '视频': video!.toJson(),
        if (dependencies != null) '依赖关系': dependencies!.toJson(),
        '备注': notes,
      };

  ShotV4 copyWith({
    int? shotNumber,
    double? duration,
    TimeRange? timeline,
    String? priority,
    String? cameraScale,
    String? cameraMovement,
    String? characterPosition,
    String? sceneDescription,
    String? dialogue,
    String? characterName,
    String? characterId,
    String? emotionDescription,
    String? aiPrompt,
    String? negativePrompt,
    String? transition,
    List<String>? generateTasks,
    ShotAudioConfig? audio,
    ShotImageConfig? image,
    ShotVideoConfig? video,
    String? notes,
    String? reviewStatus,
  }) {
    return ShotV4(
      shotNumber: shotNumber ?? this.shotNumber,
      duration: duration ?? this.duration,
      timeline: timeline ?? this.timeline,
      priority: priority ?? this.priority,
      cameraScale: cameraScale ?? this.cameraScale,
      cameraMovement: cameraMovement ?? this.cameraMovement,
      characterPosition: characterPosition ?? this.characterPosition,
      sceneDescription: sceneDescription ?? this.sceneDescription,
      dialogue: dialogue ?? this.dialogue,
      characterName: characterName ?? this.characterName,
      characterId: characterId ?? this.characterId,
      emotionDescription: emotionDescription ?? this.emotionDescription,
      emotionVector: emotionVector,
      audioDesignText: audioDesignText,
      aiPrompt: aiPrompt ?? this.aiPrompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      transition: transition ?? this.transition,
      generateTasks: generateTasks ?? this.generateTasks,
      audio: audio ?? this.audio,
      image: image ?? this.image,
      video: video ?? this.video,
      dependencies: dependencies,
      notes: notes ?? this.notes,
      reviewStatus: reviewStatus ?? this.reviewStatus,
    );
  }
}

// ---------------------------------------------------------------------------
// 时间轴
// ---------------------------------------------------------------------------

class TimeRange {
  final double start;
  final double end;

  const TimeRange({this.start = 0, this.end = 0});

  factory TimeRange.fromJson(Map<String, dynamic> json) => TimeRange(
        start: (json['开始时间'] as num?)?.toDouble() ?? 0,
        end: (json['结束时间'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {'开始时间': start, '结束时间': end};
}

// ---------------------------------------------------------------------------
// 音频配置（五大流线）
// ---------------------------------------------------------------------------

class ShotAudioConfig {
  final AudioVoiceOver? vo;
  final AudioBGM? bgm;
  final AudioFoley? foley;
  final AudioDynamic? dynamic_;
  final AudioAmbient? ambient;

  const ShotAudioConfig({this.vo, this.bgm, this.foley, this.dynamic_, this.ambient});

  int get enabledCount => [vo?.enabled, bgm?.enabled, foley?.enabled, dynamic_?.enabled, ambient?.enabled]
      .where((e) => e == true)
      .length;

  factory ShotAudioConfig.fromJson(Map<String, dynamic> json) => ShotAudioConfig(
        vo: json['VO'] != null ? AudioVoiceOver.fromJson(json['VO'] as Map<String, dynamic>) : null,
        bgm: json['BGM'] != null ? AudioBGM.fromJson(json['BGM'] as Map<String, dynamic>) : null,
        foley: json['拟声'] != null ? AudioFoley.fromJson(json['拟声'] as Map<String, dynamic>) : null,
        dynamic_: json['动态音效'] != null ? AudioDynamic.fromJson(json['动态音效'] as Map<String, dynamic>) : null,
        ambient: json['氛围音效'] != null ? AudioAmbient.fromJson(json['氛围音效'] as Map<String, dynamic>) : null,
      );

  Map<String, dynamic> toJson() => {
        if (vo != null) 'VO': vo!.toJson(),
        if (bgm != null) 'BGM': bgm!.toJson(),
        if (foley != null) '拟声': foley!.toJson(),
        if (dynamic_ != null) '动态音效': dynamic_!.toJson(),
        if (ambient != null) '氛围音效': ambient!.toJson(),
      };
}

class AudioVoiceOver {
  bool enabled;
  String type;
  String text;
  String characterId;
  String emotion;
  double volume;
  String priority;

  AudioVoiceOver({
    this.enabled = false, this.type = 'TTS', this.text = '',
    this.characterId = '', this.emotion = '', this.volume = 0.8, this.priority = '',
  });

  factory AudioVoiceOver.fromJson(Map<String, dynamic> j) => AudioVoiceOver(
        enabled: j['启用'] as bool? ?? false, type: j['类型'] as String? ?? 'TTS',
        text: j['台词'] as String? ?? '', characterId: j['角色ID'] as String? ?? '',
        emotion: j['情绪描述'] as String? ?? '', volume: (j['音量'] as num?)?.toDouble() ?? 0.8,
        priority: j['优先级'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        '启用': enabled, '类型': type, '台词': text,
        '角色ID': characterId, '情绪描述': emotion, '音量': volume, '优先级': priority,
      };
}

class AudioBGM {
  bool enabled;
  String type;
  String prompt;
  String style;
  String emotion;
  double intensity;
  double fadeIn;
  double fadeOut;

  AudioBGM({
    this.enabled = false, this.type = '延续', this.prompt = '',
    this.style = '', this.emotion = '', this.intensity = 0.6,
    this.fadeIn = 0.5, this.fadeOut = 0.5,
  });

  factory AudioBGM.fromJson(Map<String, dynamic> j) => AudioBGM(
        enabled: j['启用'] as bool? ?? false, type: j['类型'] as String? ?? '延续',
        prompt: j['提示词'] as String? ?? '', style: j['风格'] as String? ?? '',
        emotion: j['情绪描述'] as String? ?? '',
        intensity: (j['强度'] as num?)?.toDouble() ?? 0.6,
        fadeIn: (j['淡入时间'] as num?)?.toDouble() ?? 0.5,
        fadeOut: (j['淡出时间'] as num?)?.toDouble() ?? 0.5,
      );

  Map<String, dynamic> toJson() => {
        '启用': enabled, '类型': type, '提示词': prompt, '风格': style,
        '情绪描述': emotion, '强度': intensity, '淡入时间': fadeIn, '淡出时间': fadeOut,
      };
}

class AudioFoley {
  bool enabled;
  String type;
  String prompt;
  String description;
  double triggerTime;
  double volume;
  String priority;

  AudioFoley({
    this.enabled = false, this.type = '生成', this.prompt = '',
    this.description = '', this.triggerTime = 0, this.volume = 0.7, this.priority = '',
  });

  factory AudioFoley.fromJson(Map<String, dynamic> j) => AudioFoley(
        enabled: j['启用'] as bool? ?? false, type: j['类型'] as String? ?? '生成',
        prompt: j['提示词'] as String? ?? '', description: j['描述'] as String? ?? '',
        triggerTime: (j['触发时间'] as num?)?.toDouble() ?? 0,
        volume: (j['音量'] as num?)?.toDouble() ?? 0.7,
        priority: j['优先级'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        '启用': enabled, '类型': type, '提示词': prompt, '描述': description,
        '触发时间': triggerTime, '音量': volume, '优先级': priority,
      };
}

class AudioDynamic {
  bool enabled;
  String type;
  String prompt;
  String description;
  double triggerTime;
  double volume;

  AudioDynamic({
    this.enabled = false, this.type = '转场', this.prompt = '',
    this.description = '', this.triggerTime = 0, this.volume = 0.6,
  });

  factory AudioDynamic.fromJson(Map<String, dynamic> j) => AudioDynamic(
        enabled: j['启用'] as bool? ?? false, type: j['类型'] as String? ?? '转场',
        prompt: j['提示词'] as String? ?? '', description: j['描述'] as String? ?? '',
        triggerTime: (j['触发时间'] as num?)?.toDouble() ?? 0,
        volume: (j['音量'] as num?)?.toDouble() ?? 0.6,
      );

  Map<String, dynamic> toJson() => {
        '启用': enabled, '类型': type, '提示词': prompt, '描述': description,
        '触发时间': triggerTime, '音量': volume,
      };
}

class AudioAmbient {
  bool enabled;
  String type;
  String prompt;
  String description;
  double intensity;
  bool loop;

  AudioAmbient({
    this.enabled = false, this.type = '生成', this.prompt = '',
    this.description = '', this.intensity = 0.4, this.loop = true,
  });

  factory AudioAmbient.fromJson(Map<String, dynamic> j) => AudioAmbient(
        enabled: j['启用'] as bool? ?? false, type: j['类型'] as String? ?? '生成',
        prompt: j['提示词'] as String? ?? '', description: j['描述'] as String? ?? '',
        intensity: (j['强度'] as num?)?.toDouble() ?? 0.4,
        loop: j['循环'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        '启用': enabled, '类型': type, '提示词': prompt, '描述': description,
        '强度': intensity, '循环': loop,
      };
}

// ---------------------------------------------------------------------------
// 依赖关系
// ---------------------------------------------------------------------------

class DependencyInfo {
  final List<int> before;
  final List<int> after;

  const DependencyInfo({this.before = const [], this.after = const []});

  factory DependencyInfo.fromJson(Map<String, dynamic> j) => DependencyInfo(
        before: _intList(j['前置镜头']),
        after: _intList(j['后置镜头']),
      );

  Map<String, dynamic> toJson() => {'前置镜头': before, '后置镜头': after};
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<String> _strList(dynamic v) =>
    (v as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

List<int> _intList(dynamic v) =>
    (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [];

List<double> _doubleList(dynamic v) =>
    (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [];
