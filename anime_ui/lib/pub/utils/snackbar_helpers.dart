/// 统一 SnackBar 与提示词库弹窗的辅助函数
library;

import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/widgets/prompt_library_dialog.dart';

/// 显示 Toast 提示
///
/// [isError] 为 true 时使用错误色，[isInfo] 为 true 时使用信息色，否则使用成功色。
void showToast(
  BuildContext context,
  String msg, {
  bool isError = false,
  bool isInfo = false,
}) {
  if (!context.mounted) return;
  final bg = isError
      ? AppColors.error
      : (isInfo ? AppColors.info : AppColors.success);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// 显示提示词库选择对话框
///
/// [prompts] 需包含 name、description 属性。若为空则显示「提示词库中暂无模板」信息提示。
void showPromptLibrary(
  BuildContext context, {
  required List<dynamic> prompts,
  required Color accent,
  required ValueChanged<String> onSelected,
}) {
  if (prompts.isEmpty) {
    showToast(context, '提示词库中暂无模板', isInfo: true);
    return;
  }
  showDialog(
    context: context,
    builder: (ctx) => PromptLibraryDialog(
      prompts: prompts,
      accent: accent,
      onSelected: (p) {
        onSelected(p);
        Navigator.pop(ctx);
      },
    ),
  );
}
