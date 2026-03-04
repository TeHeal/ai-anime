import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/services/file_svc.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

import '../models/resource_category.dart';
import '../providers/provider.dart';

/// 批量上传：多选文件后逐个上传并创建 Resource，显示进度
Future<void> showResourceBatchUploadDialog(
  BuildContext context,
  WidgetRef ref, {
  required ResourceLibraryType libraryType,
  required Color accentColor,
}) async {
  final modality = libraryType.modality;
  if (modality != ResourceModality.visual &&
      modality != ResourceModality.audio) {
    return;
  }
  final result = await FilePicker.platform.pickFiles(
    type: modality == ResourceModality.audio ? FileType.audio : FileType.image,
    allowMultiple: true,
    withData: true,
  );
  if (result == null || result.files.isEmpty) return;
  final files =
      result.files.where((f) => f.bytes != null && f.name.isNotEmpty).toList();
  if (files.isEmpty) return;

  if (!context.mounted) return;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _BatchUploadProgressDialog(
      files: files,
      libraryType: libraryType,
      accentColor: accentColor,
      ref: ref,
    ),
  );
}

/// 批量上传进度弹窗：逐个上传并创建 Resource，显示「已上传 3/10」
class _BatchUploadProgressDialog extends ConsumerStatefulWidget {
  const _BatchUploadProgressDialog({
    required this.files,
    required this.libraryType,
    required this.accentColor,
    required this.ref,
  });

  final List<PlatformFile> files;
  final ResourceLibraryType libraryType;
  final Color accentColor;
  final WidgetRef ref;

  @override
  ConsumerState<_BatchUploadProgressDialog> createState() =>
      _BatchUploadProgressDialogState();
}

class _BatchUploadProgressDialogState
    extends ConsumerState<_BatchUploadProgressDialog> {
  int _done = 0;
  int _failed = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runUpload());
  }

  Future<void> _runUpload() async {
    final notifier = widget.ref.read(resourceListProvider.notifier);
    final fileSvc = FileService();
    final total = widget.files.length;

    for (var i = 0; i < total; i++) {
      final file = widget.files[i];
      final bytes = file.bytes;
      if (bytes == null) continue;

      try {
        final url = await fileSvc.upload(
          bytes,
          file.name,
          category: 'general',
        );
        final name = '${widget.libraryType.label}-${i + 1}';
        await notifier.addResource(
          Resource(
            name: name,
            libraryType: widget.libraryType.name,
            modality: widget.libraryType.modality.name,
            thumbnailUrl: url,
            version: 'v1.0',
          ),
        );
      } catch (e) {
        debugPrint('BatchUpload failed for ${file.name}: $e');
        if (mounted) setState(() => _failed++);
      }
      if (mounted) setState(() => _done++);
    }

    if (mounted) {
      setState(() => _finished = true);
      await notifier.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.files.length;
    return Dialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(Spacing.xl.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.upload,
              size: 40.r,
              color: widget.accentColor.withValues(alpha: 0.7),
            ),
            SizedBox(height: Spacing.lg.h),
            Text(
              _finished ? '上传完成' : '正在上传',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Spacing.sm.h),
            Text(
              '已上传 $_done/$total'
              '${_failed > 0 ? '（失败 $_failed 个）' : ''}',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            ),
            SizedBox(height: Spacing.lg.h),
            if (!_finished)
              SizedBox(
                width: 200.w,
                child: LinearProgressIndicator(
                  value: total > 0 ? _done / total : null,
                  backgroundColor: AppColors.inputBackground,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(widget.accentColor),
                ),
              )
            else
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: widget.accentColor,
                ),
                child: const Text('完成'),
              ),
          ],
        ),
      ),
    );
  }
}
