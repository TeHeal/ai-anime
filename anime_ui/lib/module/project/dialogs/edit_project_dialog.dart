import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 编辑项目名称对话框
class EditProjectDialog extends StatefulWidget {
  const EditProjectDialog({super.key, required this.initialName});

  final String initialName;

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initialName.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
      ),
      title: Text(
        '编辑项目名称',
        style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: '输入项目名称',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mutedDark,
          ),
          filled: true,
          fillColor: AppColors.surfaceMutedDarker,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        onSubmitted: (v) {
          if (v.trim().isNotEmpty) Navigator.pop(context, v.trim());
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '取消',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
          ),
        ),
        FilledButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) Navigator.pop(context, name);
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('保存'),
        ),
      ],
    );
  }
}
