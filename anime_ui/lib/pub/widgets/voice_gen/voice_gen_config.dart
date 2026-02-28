import 'package:flutter/material.dart';

/// Generation mode for voice creation.
enum VoiceGenMode {
  clone('语音克隆'),
  design('音色设计');

  const VoiceGenMode(this.label);
  final String label;
}

/// Pure-data configuration that drives [VoiceGenView].
class VoiceGenConfig {
  const VoiceGenConfig({
    required this.title,
    required this.accentColor,
    required this.onSaved,
    this.allowedModes = const [VoiceGenMode.clone, VoiceGenMode.design],
    this.defaultMode = VoiceGenMode.design,
    this.designPromptHint = '描述你想要的音色特征，如：温柔甜美的少女音色，语速适中…',
    this.quickPrompts = const [],
  });

  final String title;
  final Color accentColor;

  /// Tabs visible to the user.
  final List<VoiceGenMode> allowedModes;
  final VoiceGenMode defaultMode;

  final String designPromptHint;
  final List<String> quickPrompts;

  /// Called after voice resource is successfully generated.
  /// Caller is responsible for saving the resource to the right place.
  final Future<void> Function(VoiceGenMode mode) onSaved;

  // ─── Presets ────────────────────────────────────────────

  /// From resource library voice page.
  static VoiceGenConfig voiceLibrary({
    required Future<void> Function(VoiceGenMode mode) onSaved,
    Color accentColor = const Color(0xFF3B82F6),
  }) =>
      VoiceGenConfig(
        title: '创建音色',
        accentColor: accentColor,
        onSaved: onSaved,
        quickPrompts: const [
          '温柔少女', '热血少年', '沉稳大叔', '活泼萝莉',
          '冷酷男声', '知性女声', '可爱童声',
        ],
      );

  /// From config page — voice clone only.
  static VoiceGenConfig cloneOnly({
    required Future<void> Function(VoiceGenMode mode) onSaved,
    Color accentColor = const Color(0xFF3B82F6),
  }) =>
      VoiceGenConfig(
        title: '语音克隆',
        accentColor: accentColor,
        allowedModes: const [VoiceGenMode.clone],
        defaultMode: VoiceGenMode.clone,
        onSaved: onSaved,
      );

  /// From config page — voice design only.
  static VoiceGenConfig designOnly({
    required Future<void> Function(VoiceGenMode mode) onSaved,
    Color accentColor = const Color(0xFF3B82F6),
  }) =>
      VoiceGenConfig(
        title: '音色设计',
        accentColor: accentColor,
        allowedModes: const [VoiceGenMode.design],
        defaultMode: VoiceGenMode.design,
        onSaved: onSaved,
        quickPrompts: const [
          '温柔少女', '热血少年', '沉稳大叔', '活泼萝莉',
          '冷酷男声', '知性女声', '可爱童声',
        ],
      );
}
