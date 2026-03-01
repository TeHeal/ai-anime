part of 'storyboard_script.dart';

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
