import 'resource_category.dart';

enum MetaFieldType { text, select, number, multiSelect }

/// 字段选项来源：静态预设或模型目录动态加载
enum MetaFieldSource { static, modelCatalog }

class MetaFieldDef {
  const MetaFieldDef({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.required = false,
    this.readOnly = false,
    this.hint,
    this.allowCustom = true,
    this.filterable,
    this.source = MetaFieldSource.static,
    this.serviceType,
  });

  final String key;
  final String label;
  final MetaFieldType type;
  final List<String>? options;
  final bool required;
  final bool readOnly;
  final String? hint;
  final bool allowCustom;
  final bool? filterable;

  /// [source] 为 modelCatalog 时，[serviceType] 指定模型目录服务类型
  final MetaFieldSource source;
  final String? serviceType;

  bool get isFilterable =>
      filterable ??
      (type == MetaFieldType.select &&
          options != null &&
          options!.isNotEmpty);

  bool get isDynamic => source == MetaFieldSource.modelCatalog;
}

/// 素材库各子库的元数据 Schema（不含风格库，风格已独立）
abstract final class ResourceMetaSchema {
  static List<MetaFieldDef> forLibrary(ResourceLibraryType lib) =>
      _schemas[lib] ?? [];

  /// 返回可筛选字段
  static List<MetaFieldDef> filterableFields(ResourceLibraryType lib) =>
      forLibrary(lib).where((f) => f.isFilterable && !f.readOnly).toList();

  static const _schemas = <ResourceLibraryType, List<MetaFieldDef>>{
    ResourceLibraryType.character: _characterSchema,
    ResourceLibraryType.scene: _sceneSchema,
    ResourceLibraryType.prop: _propSchema,
    ResourceLibraryType.expression: _expressionSchema,
    ResourceLibraryType.pose: _poseSchema,
    ResourceLibraryType.effect: _effectSchema,
    ResourceLibraryType.voice: _voiceSchema,
    ResourceLibraryType.voiceover: _voiceoverSchema,
    ResourceLibraryType.sfx: _sfxSchema,
    ResourceLibraryType.music: _musicSchema,
    ResourceLibraryType.prompt: _promptSchema,
    ResourceLibraryType.styleGuide: _styleGuideSchema,
    ResourceLibraryType.dialogueTemplate: _dialogueTemplateSchema,
    ResourceLibraryType.scriptSnippet: _scriptSnippetSchema,
  };

  static const _visualCommon = [
    MetaFieldDef(
      key: 'resolution',
      label: '分辨率',
      type: MetaFieldType.select,
      options: ['512x512', '1024x1024', '1920x1080', '2048x1024'],
      filterable: false,
    ),
    MetaFieldDef(
      key: 'model',
      label: '生成模型',
      type: MetaFieldType.select,
      source: MetaFieldSource.modelCatalog,
      serviceType: 'image',
    ),
    MetaFieldDef(key: 'prompt', label: '提示词', type: MetaFieldType.text),
    MetaFieldDef(
      key: 'negativePrompt',
      label: '反向提示词',
      type: MetaFieldType.text,
    ),
    MetaFieldDef(key: 'seed', label: '种子', type: MetaFieldType.number),
  ];

  static const _characterSchema = [
    MetaFieldDef(
      key: 'gender',
      label: '性别',
      type: MetaFieldType.select,
      options: ['男', '女', '中性', '其他'],
    ),
    MetaFieldDef(
      key: 'ageGroup',
      label: '年龄段',
      type: MetaFieldType.select,
      options: ['幼年', '少年', '青年', '中年', '老年'],
    ),
    MetaFieldDef(
      key: 'role',
      label: '角色定位',
      type: MetaFieldType.select,
      options: ['主角', '配角', '反派', '路人', '其他'],
    ),
    ..._visualCommon,
  ];

  static const _sceneSchema = [
    MetaFieldDef(
      key: 'sceneType',
      label: '场景类型',
      type: MetaFieldType.select,
      options: ['室内', '室外', '自然', '城市', '幻想', '太空', '其他'],
    ),
    MetaFieldDef(
      key: 'timeOfDay',
      label: '时间段',
      type: MetaFieldType.select,
      options: ['白天', '黄昏', '夜晚', '黎明', '不限'],
    ),
    MetaFieldDef(
      key: 'weather',
      label: '天气',
      type: MetaFieldType.select,
      options: ['晴天', '阴天', '雨天', '雪天', '雾', '不限'],
    ),
    ..._visualCommon,
  ];

  static const _propSchema = [
    MetaFieldDef(
      key: 'propCategory',
      label: '道具类别',
      type: MetaFieldType.select,
      options: ['武器', '装备', '日用品', '食物', '交通工具', '装饰', '其他'],
    ),
    MetaFieldDef(
      key: 'usage',
      label: '用途',
      type: MetaFieldType.select,
      options: ['战斗', '生活', '装饰', '剧情道具', '其他'],
    ),
    ..._visualCommon,
  ];

  static const _expressionSchema = [
    MetaFieldDef(
      key: 'emotion',
      label: '情绪',
      type: MetaFieldType.select,
      options: ['喜悦', '悲伤', '愤怒', '惊讶', '害羞', '恐惧', '厌恶', '平静'],
    ),
    MetaFieldDef(
      key: 'intensity',
      label: '强度',
      type: MetaFieldType.select,
      options: ['微弱', '中等', '强烈', '极端'],
    ),
    ..._visualCommon,
  ];

  static const _poseSchema = [
    MetaFieldDef(
      key: 'poseType',
      label: '姿势类型',
      type: MetaFieldType.select,
      options: [
        '站立',
        '坐姿',
        '行走',
        '奔跑',
        '战斗',
        '跳跃',
        '飞行',
        '躺卧',
        '其他',
      ],
    ),
    MetaFieldDef(
      key: 'angle',
      label: '视角',
      type: MetaFieldType.select,
      options: ['正面', '侧面', '背面', '俯视', '仰视', '四分之三'],
    ),
    ..._visualCommon,
  ];

  static const _effectSchema = [
    MetaFieldDef(
      key: 'effectType',
      label: '特效类型',
      type: MetaFieldType.select,
      options: [
        '火焰',
        '水流',
        '雷电',
        '烟雾',
        '光效',
        '爆炸',
        '魔法',
        '粒子',
        '其他',
      ],
    ),
    MetaFieldDef(
      key: 'intensity',
      label: '强度',
      type: MetaFieldType.select,
      options: ['微弱', '中等', '强烈'],
    ),
    ..._visualCommon,
  ];

  static const _voiceSchema = [
    MetaFieldDef(
      key: 'gender',
      label: '性别',
      type: MetaFieldType.select,
      options: ['男声', '女声', '中性'],
    ),
    MetaFieldDef(
      key: 'emotion',
      label: '情绪',
      type: MetaFieldType.select,
      options: ['温柔', '激昂', '平静', '忧郁', '活泼'],
    ),
    MetaFieldDef(
      key: 'model',
      label: '模型',
      type: MetaFieldType.select,
      source: MetaFieldSource.modelCatalog,
      serviceType: 'voice_clone',
    ),
    MetaFieldDef(
      key: 'source',
      label: '来源',
      type: MetaFieldType.select,
      options: ['上传', 'AI 生成', '语音克隆'],
      allowCustom: false,
    ),
  ];

  static const _voiceoverSchema = [
    MetaFieldDef(key: 'voice_name', label: '音色名称', type: MetaFieldType.text),
    MetaFieldDef(
      key: 'emotion',
      label: '情绪',
      type: MetaFieldType.select,
      options: ['默认', '开心', '悲伤', '愤怒', '惊讶', '温柔'],
    ),
    MetaFieldDef(
      key: 'duration',
      label: '时长',
      type: MetaFieldType.text,
      readOnly: true,
    ),
  ];

  static const _sfxSchema = [
    MetaFieldDef(
      key: 'sfxCategory',
      label: '音效类别',
      type: MetaFieldType.select,
      options: ['战斗', '环境', '界面', '脚步', '爆炸', '魔法', '自然', '其他'],
    ),
    MetaFieldDef(
      key: 'duration',
      label: '时长',
      type: MetaFieldType.text,
      readOnly: true,
    ),
  ];

  static const _musicSchema = [
    MetaFieldDef(
      key: 'genre',
      label: '风格',
      type: MetaFieldType.select,
      options: [
        '史诗',
        '抒情',
        '紧张',
        '欢快',
        '悲伤',
        '神秘',
        '日常',
        '战斗',
        '其他',
      ],
    ),
    MetaFieldDef(key: 'bpm', label: 'BPM', type: MetaFieldType.number),
    MetaFieldDef(
      key: 'duration',
      label: '时长',
      type: MetaFieldType.text,
      readOnly: true,
    ),
  ];

  static const _promptSchema = [
    MetaFieldDef(
      key: 'targetModel',
      label: '目标模型',
      type: MetaFieldType.select,
      source: MetaFieldSource.modelCatalog,
      serviceType: 'image',
    ),
    MetaFieldDef(
      key: 'category',
      label: '用途',
      type: MetaFieldType.select,
      options: ['角色描述', '场景描述', '动作描述', '风格描述', '通用'],
    ),
    MetaFieldDef(
      key: 'language',
      label: '语言',
      type: MetaFieldType.select,
      options: ['中文', 'English', '中英混合'],
      allowCustom: false,
    ),
  ];

  static const _styleGuideSchema = [
    MetaFieldDef(
      key: 'styleType',
      label: '风格类型',
      type: MetaFieldType.select,
      options: ['二次元', '写实', '水彩', '赛博朋克', '极简', '复古', '其他'],
    ),
    MetaFieldDef(
      key: 'targetModel',
      label: '适用模型',
      type: MetaFieldType.select,
      source: MetaFieldSource.modelCatalog,
      serviceType: 'image',
    ),
    MetaFieldDef(
      key: 'language',
      label: '语言',
      type: MetaFieldType.select,
      options: ['中文', 'English', '中英混合'],
      allowCustom: false,
    ),
  ];

  static const _dialogueTemplateSchema = [
    MetaFieldDef(
      key: 'dialogueType',
      label: '台词类型',
      type: MetaFieldType.select,
      options: ['日常对话', '战斗宣言', '内心独白', '旁白', '搞笑', '感人', '其他'],
    ),
    MetaFieldDef(
      key: 'characterRole',
      label: '角色类型',
      type: MetaFieldType.select,
      options: ['主角', '配角', '反派', '路人', '旁白', '通用'],
    ),
    MetaFieldDef(
      key: 'language',
      label: '语言',
      type: MetaFieldType.select,
      options: ['中文', 'English', '中英混合'],
      allowCustom: false,
    ),
  ];

  static const _scriptSnippetSchema = [
    MetaFieldDef(
      key: 'snippetType',
      label: '片段类型',
      type: MetaFieldType.select,
      options: ['场景描述', '动作描写', '情绪渲染', '环境氛围', '转场', '其他'],
    ),
    MetaFieldDef(
      key: 'genre',
      label: '题材',
      type: MetaFieldType.select,
      options: ['奇幻', '科幻', '日常', '悬疑', '热血', '治愈', '其他'],
    ),
    MetaFieldDef(
      key: 'language',
      label: '语言',
      type: MetaFieldType.select,
      options: ['中文', 'English', '中英混合'],
      allowCustom: false,
    ),
  ];

  /// AI 生成追溯字段（只读展示）
  static const traceFields = [
    MetaFieldDef(
      key: 'prompt',
      label: '提示词',
      type: MetaFieldType.text,
      readOnly: true,
    ),
    MetaFieldDef(
      key: 'negativePrompt',
      label: '反向提示词',
      type: MetaFieldType.text,
      readOnly: true,
    ),
    MetaFieldDef(
      key: 'model',
      label: '模型',
      type: MetaFieldType.text,
      readOnly: true,
    ),
    MetaFieldDef(
      key: 'provider',
      label: 'Provider',
      type: MetaFieldType.text,
      readOnly: true,
    ),
    MetaFieldDef(
      key: 'generatedAt',
      label: '生成时间',
      type: MetaFieldType.text,
      readOnly: true,
    ),
    MetaFieldDef(
      key: 'taskId',
      label: '任务 ID',
      type: MetaFieldType.text,
      readOnly: true,
    ),
  ];
}
