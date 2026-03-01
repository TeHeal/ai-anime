import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/widgets/app_dialog.dart';

/// 确认删除对话框
Future<bool?> showConfirmDeleteDialog(
  BuildContext context, {
  required String title,
  required String content,
  String cancelText = '取消',
  String confirmText = '删除',
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AppDialog.alert(
      title: title,
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            cancelText,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
