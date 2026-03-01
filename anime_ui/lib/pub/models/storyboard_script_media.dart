part of 'storyboard_script.dart';

// ---------------------------------------------------------------------------
// 图像与视频配置
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
