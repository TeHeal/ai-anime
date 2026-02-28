import 'package:flutter/material.dart';

/// 文字生成场景模式
enum TextGenMode {
  imagePrompt('图像提示词'),
  styleGuide('风格指令'),
  dialogue('台词对白'),
  scriptSnippet('剧本片段'),
  optimize('优化改写'),
  freeform('自由生成');

  const TextGenMode(this.label);
  final String label;
}

/// 纯数据配置，驱动 [TextGenView]
class TextGenConfig {
  const TextGenConfig({
    required this.title,
    required this.accentColor,
    required this.mode,
    required this.onComplete,
    this.instructionHint = '描述你想生成的内容…',
    this.referenceText = '',
    this.targetModel = '',
    this.language = '',
    this.maxTokens = 0,
    this.quickPrompts = const [],
    this.saveToLibrary = true,
    this.libraryType = 'prompt',
  });

  final String title;
  final Color accentColor;
  final TextGenMode mode;

  /// 输入框占位提示
  final String instructionHint;

  /// 优化场景下的原始文本
  final String referenceText;

  /// 目标模型（告诉LLM生成的提示词适配哪个模型）
  final String targetModel;

  /// 输出语言偏好
  final String language;

  /// 最大token数（0=不限制）
  final int maxTokens;

  /// 快捷提示词芯片
  final List<String> quickPrompts;

  /// 是否默认保存到素材库
  final bool saveToLibrary;

  /// 保存到哪个子库类型
  final String libraryType;

  /// 生成完成回调，result 为 LLM 生成结果文本
  final Future<void> Function(String result) onComplete;

  // ─── 场景预设工厂 ───────────────────────────────────────

  /// 图像生成中的「AI 生成提示词」
  static TextGenConfig imagePrompt({
    required Future<void> Function(String result) onComplete,
    Color accentColor = const Color(0xFF8B5CF6),
    String targetModel = '',
  }) =>
      TextGenConfig(
        title: 'AI 生成提示词',
        accentColor: accentColor,
        mode: TextGenMode.imagePrompt,
        instructionHint: '输入关键词或简短描述，AI 将扩展为完整的图像提示词…',
        targetModel: targetModel,
        quickPrompts: const [
          '角色立绘', '场景氛围', '动作特写', '情绪表达',
          '赛博朋克', '水彩手绘', '写实风格',
        ],
        saveToLibrary: false,
        onComplete: onComplete,
      );

  /// 素材库中新建提示词
  static TextGenConfig newPrompt({
    required Future<void> Function(String result) onComplete,
    Color accentColor = const Color(0xFF22C55E),
    String targetModel = '',
    String category = '',
  }) =>
      TextGenConfig(
        title: '生成提示词',
        accentColor: accentColor,
        mode: TextGenMode.imagePrompt,
        instructionHint: '描述想生成的提示词内容，如：一个赛博朋克风格的少女站在霓虹灯下…',
        targetModel: targetModel,
        quickPrompts: const [
          '角色描述', '场景描述', '动作描述', '风格描述', '情绪描述',
        ],
        saveToLibrary: true,
        onComplete: onComplete,
      );

  /// 优化已有提示词
  static TextGenConfig optimizePrompt({
    required String original,
    required Future<void> Function(String result) onComplete,
    Color accentColor = const Color(0xFF22C55E),
    String targetModel = '',
  }) =>
      TextGenConfig(
        title: '优化提示词',
        accentColor: accentColor,
        mode: TextGenMode.optimize,
        instructionHint: '描述优化方向，如：增加细节、改为英文、适配Flux模型…',
        referenceText: original,
        targetModel: targetModel,
        quickPrompts: const [
          '增加细节', '精简描述', '翻译为英文', '增强情绪', '添加构图指令',
        ],
        saveToLibrary: false,
        onComplete: onComplete,
      );

  /// 风格指令生成
  static TextGenConfig styleGuide({
    required Future<void> Function(String result) onComplete,
    Color accentColor = const Color(0xFF22C55E),
  }) =>
      TextGenConfig(
        title: '生成风格指令',
        accentColor: accentColor,
        mode: TextGenMode.styleGuide,
        instructionHint: '描述想要的画面风格、色调、构图规则…',
        libraryType: 'styleGuide',
        quickPrompts: const [
          '二次元清新', '赛博朋克', '水彩写意', '复古胶片', '极简扁平',
        ],
        onComplete: onComplete,
      );

  /// 台词对白生成
  static TextGenConfig dialogue({
    required Future<void> Function(String result) onComplete,
    Color accentColor = const Color(0xFF22C55E),
    String referenceText = '',
  }) =>
      TextGenConfig(
        title: '生成台词',
        accentColor: accentColor,
        mode: TextGenMode.dialogue,
        instructionHint: '描述场景和角色关系，如：主角向同伴告别的对话，语气坚定但不舍…',
        referenceText: referenceText,
        libraryType: 'dialogueTemplate',
        quickPrompts: const [
          '日常对话', '战斗宣言', '内心独白', '搞笑段子', '感人告别',
        ],
        onComplete: onComplete,
      );

  /// 自由文本生成
  static TextGenConfig freeform({
    required Future<void> Function(String result) onComplete,
    Color accentColor = const Color(0xFF22C55E),
  }) =>
      TextGenConfig(
        title: '文字生成',
        accentColor: accentColor,
        mode: TextGenMode.freeform,
        instructionHint: '输入任何创作指令…',
        onComplete: onComplete,
      );
}
