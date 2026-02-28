import 'package:flutter/material.dart';

import 'image_gen_controller.dart';

// ─── 场景配置（纯数据，无 Widget）────────────────────────

class ImageGenConfig {
  const ImageGenConfig({
    required this.title,
    required this.accentColor,
    required this.libraryType,
    required this.modality,
    required this.maxRefImages,
    required this.maxOutputCount,
    required this.allowedRatios,
    required this.defaultRatio,
    required this.promptHint,
    required this.onSaved,
    this.quickPrompts = const [],
  });

  /// 对话框标题，如"生成风格图"
  final String title;
  final Color accentColor;

  /// 对应后端 library_type 字段
  final String libraryType;

  /// 对应后端 modality 字段
  final String modality;

  /// 最多允许的参考图数量（0=禁用参考图，1=单张，99=不限）
  final int maxRefImages;

  /// 最多允许的输出张数（1=禁止组图，99=不限）
  final int maxOutputCount;

  /// 允许的宽高比列表（空 list = 全部允许）
  final List<String> allowedRatios;

  /// 默认选中的宽高比（空字符串 = 智能模式）
  final String defaultRatio;

  /// 提示词输入框占位文本
  final String promptHint;

  /// 快捷提示词芯片（可选）
  final List<String> quickPrompts;

  /// 生成完成后的回调，调用方负责将结果保存到对应位置
  /// [urls] 生成的图片 URL 列表
  /// [mode] 推断出的生成模式
  /// [prompt] 生成时输入的正向提示词
  /// [negativePrompt] 生成时输入的反向提示词
  final Future<void> Function(
    List<String> urls,
    ImageGenMode mode, {
    String prompt,
    String negativePrompt,
  }) onSaved;

  // ─── 场景预设工厂 ───────────────────────────────────────

  /// 风格图：全部 6 种模式，横版推荐
  static ImageGenConfig style({
    required Future<void> Function(List<String> urls, ImageGenMode mode, {String prompt, String negativePrompt}) onSaved,
  }) =>
      ImageGenConfig(
        title: '生成风格图',
        accentColor: const Color(0xFF8B5CF6),
        libraryType: 'style',
        modality: 'visual',
        maxRefImages: 99,
        maxOutputCount: 6,
        allowedRatios: const [],
        defaultRatio: '',
        promptHint: '描述画面风格、色调、氛围，如：赛博朋克夜城，霓虹光感，高对比度…',
        quickPrompts: const ['二次元清新', '赛博朋克', '水彩手绘', '写实油画', '像素风'],
        onSaved: onSaved,
      );

  /// 角色图：最多 5 张参考图（角色一致性融合），推荐竖版
  static ImageGenConfig character({
    required Future<void> Function(List<String> urls, ImageGenMode mode, {String prompt, String negativePrompt}) onSaved,
  }) =>
      ImageGenConfig(
        title: '生成角色参考图',
        accentColor: const Color(0xFF8B5CF6),
        libraryType: 'character',
        modality: 'visual',
        maxRefImages: 5,
        maxOutputCount: 4,
        allowedRatios: const ['', '1:1', '3:4', '9:16', '2:3'],
        defaultRatio: '3:4',
        promptHint: '描述角色外貌、服装、发型、表情，如：银发少女，蓝眼睛，穿白色连衣裙…',
        quickPrompts: const ['主角立绘', '正面全身', '半身像', '表情特写'],
        onSaved: onSaved,
      );

  /// 表情图：固定组图输出（一套表情），单参考图或文生图
  static ImageGenConfig expression({
    required Future<void> Function(List<String> urls, ImageGenMode mode, {String prompt, String negativePrompt}) onSaved,
  }) =>
      ImageGenConfig(
        title: '生成表情图',
        accentColor: const Color(0xFF8B5CF6),
        libraryType: 'expression',
        modality: 'visual',
        maxRefImages: 1,
        maxOutputCount: 6,
        allowedRatios: const ['', '1:1'],
        defaultRatio: '1:1',
        promptHint: '描述表情风格，组图将自动生成一套不同情绪的表情，如：活泼少女，喜怒哀乐…',
        quickPrompts: const ['开心大笑', '委屈落泪', '傲娇', '惊讶'],
        onSaved: onSaved,
      );

  /// 道具图：单张为主，可选单参考图
  static ImageGenConfig prop({
    required Future<void> Function(List<String> urls, ImageGenMode mode, {String prompt, String negativePrompt}) onSaved,
  }) =>
      ImageGenConfig(
        title: '生成道具图',
        accentColor: const Color(0xFF8B5CF6),
        libraryType: 'prop',
        modality: 'visual',
        maxRefImages: 1,
        maxOutputCount: 2,
        allowedRatios: const ['', '1:1', '4:3', '3:4'],
        defaultRatio: '1:1',
        promptHint: '描述道具外观、材质、风格，如：发光传奇长剑，金属质感，特效光芒…',
        quickPrompts: const ['武器', '魔法道具', '日常物品', '交通工具'],
        onSaved: onSaved,
      );

  /// 场景图：全部 6 种模式，推荐宽屏
  static ImageGenConfig scene({
    required Future<void> Function(List<String> urls, ImageGenMode mode, {String prompt, String negativePrompt}) onSaved,
  }) =>
      ImageGenConfig(
        title: '生成场景图',
        accentColor: const Color(0xFF8B5CF6),
        libraryType: 'scene',
        modality: 'visual',
        maxRefImages: 99,
        maxOutputCount: 6,
        allowedRatios: const [],
        defaultRatio: '16:9',
        promptHint: '描述场景环境、光线、时间，如：赛博城市天际线，黄昏，霓虹灯倒影…',
        quickPrompts: const ['城市', '自然', '室内', '宏大远景', '特写'],
        onSaved: onSaved,
      );

  /// 分镜图：多参考图融合（角色+场景），默认多参考图单张
  static ImageGenConfig shot({
    required Future<void> Function(List<String> urls, ImageGenMode mode, {String prompt, String negativePrompt}) onSaved,
  }) =>
      ImageGenConfig(
        title: '生成分镜图',
        accentColor: const Color(0xFF8B5CF6),
        libraryType: 'shot',
        modality: 'visual',
        maxRefImages: 5,
        maxOutputCount: 4,
        allowedRatios: const [],
        defaultRatio: '16:9',
        promptHint: '描述镜头构图、角色动作、情绪，如：两人对峙，仰拍视角，紧张气氛…',
        quickPrompts: const ['近景特写', '中景对话', '全景环境', '动作场景'],
        onSaved: onSaved,
      );

  // ─── 辅助：从 libraryType 字符串获取预设配置 ───────────

  static ImageGenConfig forLibraryType(
    String libraryType, {
    Color? accentColor,
    required Future<void> Function(List<String> urls, ImageGenMode mode, {String prompt, String negativePrompt}) onSaved,
  }) {
    final config = switch (libraryType) {
      'style' => ImageGenConfig.style(onSaved: onSaved),
      'character' => ImageGenConfig.character(onSaved: onSaved),
      'expression' => ImageGenConfig.expression(onSaved: onSaved),
      'prop' => ImageGenConfig.prop(onSaved: onSaved),
      'scene' => ImageGenConfig.scene(onSaved: onSaved),
      'pose' || 'effect' => ImageGenConfig(
          title: '生成图像',
          accentColor: accentColor ?? const Color(0xFF8B5CF6),
          libraryType: libraryType,
          modality: 'visual',
          maxRefImages: 1,
          maxOutputCount: 4,
          allowedRatios: const [],
          defaultRatio: '',
          promptHint: '描述你想生成的图像内容…',
          onSaved: onSaved,
        ),
      _ => ImageGenConfig(
          title: '生成图像',
          accentColor: accentColor ?? const Color(0xFF8B5CF6),
          libraryType: libraryType,
          modality: 'visual',
          maxRefImages: 99,
          maxOutputCount: 6,
          allowedRatios: const [],
          defaultRatio: '',
          promptHint: '描述你想生成的图像内容…',
          onSaved: onSaved,
        ),
    };

    if (accentColor != null) {
      return ImageGenConfig(
        title: config.title,
        accentColor: accentColor,
        libraryType: config.libraryType,
        modality: config.modality,
        maxRefImages: config.maxRefImages,
        maxOutputCount: config.maxOutputCount,
        allowedRatios: config.allowedRatios,
        defaultRatio: config.defaultRatio,
        promptHint: config.promptHint,
        quickPrompts: config.quickPrompts,
        onSaved: config.onSaved,
      );
    }
    return config;
  }
}
