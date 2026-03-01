import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';

/// 批量导入人物小传对话框
class ImportProfileDialog extends ConsumerStatefulWidget {
  const ImportProfileDialog({super.key});

  @override
  ConsumerState<ImportProfileDialog> createState() =>
      _ImportProfileDialogState();
}

class _ImportProfileDialogState extends ConsumerState<ImportProfileDialog> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _fileName;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    final text = String.fromCharCodes(bytes);
    setState(() {
      _controller.text = text;
      _fileName = file.name;
    });
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(assetExtractProvider.notifier)
          .extract(mode: 'with_profile', characterProfileContent: content);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('导入失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainer,
      title: Text(
        '批量导入人物小传',
        style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
      ),
      content: SizedBox(
        width: 520.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '将人物小传文本粘贴到下方，或从文件导入。\n支持 .txt / .md 格式，AI 将自动识别角色信息并补全资产。',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: Spacing.md.h),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _loading ? null : _pickFile,
                  icon: Icon(AppIcons.upload, size: 16.r),
                  label: Text(_fileName ?? '选择文件'),
                ),
              ],
            ),
            SizedBox(height: Spacing.md.h),
            SizedBox(
              height: 200.h,
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: '粘贴人物小传内容…',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: EdgeInsets.all(Spacing.md.r),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: Text(
            '取消',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: _loading
              ? SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onSurface,
                  ),
                )
              : const Text('导入并提取'),
        ),
      ],
    );
  }
}
