import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'voice_gen_config.dart';
import 'voice_gen_dialog.dart';

/// 通用「创建音色」按钮，点击打开 VoiceGenDialog
///
/// 用法：
/// ```dart
/// VoiceGenTrigger(
///   config: VoiceGenConfig.voiceLibrary(onSaved: ...),
///   label: '创建音色',
/// )
/// ```
class VoiceGenTrigger extends ConsumerWidget {
  const VoiceGenTrigger({
    super.key,
    required this.config,
    this.label = '创建音色',
    this.icon,
    this.style,
  });

  final VoiceGenConfig config;
  final String label;
  final IconData? icon;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () => VoiceGenDialog.show(context, ref, config: config),
      icon: Icon(icon ?? Icons.record_voice_over, size: 18.sp),
      label: Text(label),
      style: style,
    );
  }
}
