import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'image_gen_config.dart';
import 'image_gen_dialog.dart';

/// 通用「AI 生成」按钮，点击打开 ImageGenDialog
///
/// 用法：
/// ```dart
/// ImageGenTrigger(
///   config: ImageGenConfig.style(onSaved: ...),
///   label: 'AI 生成',
/// )
/// ```
class ImageGenTrigger extends ConsumerWidget {
  const ImageGenTrigger({
    super.key,
    required this.config,
    this.label = 'AI 生成',
    this.icon,
    this.style,
  });

  final ImageGenConfig config;
  final String label;
  final IconData? icon;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () => ImageGenDialog.show(context, ref, config: config),
      icon: Icon(icon ?? Icons.auto_awesome, size: 18.sp),
      label: Text(label),
      style: style,
    );
  }
}
