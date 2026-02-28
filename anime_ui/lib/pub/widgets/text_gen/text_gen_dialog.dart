import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/widgets/app_dialog.dart';
import 'text_gen_config.dart';
import 'text_gen_view.dart';

/// 统一入口：所有需要 AI 文字生成的场景调用此函数。
///
/// 示例（素材库 AI 生成提示词）：
/// ```dart
/// TextGenDialog.show(context, ref,
///   config: TextGenConfig.newPrompt(
///     onComplete: (result) async {
///       promptController.text = result;
///     },
///   ),
/// );
/// ```
///
/// 示例（图像生成中 AI 扩写提示词）：
/// ```dart
/// TextGenDialog.show(context, ref,
///   config: TextGenConfig.imagePrompt(
///     onComplete: (result) async {
///       _promptCtrl.text = result;
///     },
///   ),
/// );
/// ```
///
/// 示例（优化已有提示词）：
/// ```dart
/// TextGenDialog.show(context, ref,
///   config: TextGenConfig.optimizePrompt(
///     original: existingPrompt,
///     onComplete: (result) async {
///       _promptCtrl.text = result;
///     },
///   ),
/// );
/// ```
abstract final class TextGenDialog {
  TextGenDialog._();

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required TextGenConfig config,
  }) {
    return AppDialog.show(context, builder: (_, close) {
      return TextGenView(config: config, ref: ref, onClose: close);
    });
  }
}
