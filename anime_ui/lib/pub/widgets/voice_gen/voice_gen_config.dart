import 'package:flutter/material.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 音色生成模式（保留枚举以兼容已有 Controller / Port 层签名）
enum VoiceGenMode {
  clone('语音克隆'),
  design('音色设计');

  const VoiceGenMode(this.label);
  final String label;
}

/// 驱动 [VoiceGenView] 的纯数据配置（仅保留音色设计模式）
class VoiceGenConfig {
  const VoiceGenConfig({
    required this.title,
    required this.accentColor,
    required this.onSaved,
    this.designPromptHint = '描述你想要的音色特征，如：温柔甜美的少女音色，语速适中…',
    this.quickPrompts = const [],
  });

  final String title;
  final Color accentColor;
  final String designPromptHint;
  final List<String> quickPrompts;

  /// 生成成功后的回调
  final Future<void> Function(VoiceGenMode mode) onSaved;

  // ─── 预设 ────────────────────────────────────────────

  static const _defaultQuickPrompts = [
    '温柔少女',
    '热血少年',
    '沉稳大叔',
    '活泼萝莉',
    '冷酷男声',
    '知性女声',
    '可爱童声',
  ];

  /// 素材库入口
  static VoiceGenConfig voiceLibrary({
    required Future<void> Function(VoiceGenMode mode) onSaved,
    Color accentColor = AppColors.info,
  }) => VoiceGenConfig(
    title: '音色设计',
    accentColor: accentColor,
    onSaved: onSaved,
    quickPrompts: _defaultQuickPrompts,
  );

  /// 独立入口（与 voiceLibrary 功能一致，语义区分）
  static VoiceGenConfig designOnly({
    required Future<void> Function(VoiceGenMode mode) onSaved,
    Color accentColor = AppColors.info,
  }) => VoiceGenConfig(
    title: '音色设计',
    accentColor: accentColor,
    onSaved: onSaved,
    quickPrompts: _defaultQuickPrompts,
  );
}
