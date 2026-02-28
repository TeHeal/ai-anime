import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/colors.dart';

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
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Text(content,
          style: TextStyle(color: Colors.grey[400], height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelText, style: TextStyle(color: Colors.grey[400])),
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
