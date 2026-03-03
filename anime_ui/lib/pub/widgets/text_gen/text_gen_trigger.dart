import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'text_gen_config.dart';
import 'text_gen_dialog.dart';

/// 通用「AI 生成」按钮，点击打开 TextGenDialog
///
/// 用法：
/// ```dart
/// TextGenTrigger(
///   config: TextGenConfig.newPrompt(onComplete: ...),
///   label: 'AI 生成',
/// )
/// ```
class TextGenTrigger extends ConsumerWidget {
  const TextGenTrigger({
    super.key,
    required this.config,
    this.label = 'AI 生成',
    this.icon,
    this.style,
  });

  final TextGenConfig config;
  final String label;
  final IconData? icon;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () => TextGenDialog.show(context, ref, config: config),
      icon: Icon(icon ?? Icons.auto_awesome, size: 18.sp),
      label: Text(label),
      style: style,
    );
  }
}
