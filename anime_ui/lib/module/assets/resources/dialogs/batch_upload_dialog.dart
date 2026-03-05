import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

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

/// 批量导入：多选文件后逐个上传并创建 Resource，显示逐条进度
Future<void> showResourceBatchUploadDialog(
  BuildContext context,
  WidgetRef ref, {
  required ResourceLibraryType libraryType,
  required Color accentColor,
}) async {
  final modality = libraryType.modality;

  FileType pickerType;
  List<String>? allowedExt;
  switch (modality) {
    case ResourceModality.visual:
      pickerType = FileType.image;
    case ResourceModality.audio:
      pickerType = FileType.audio;
    case ResourceModality.text:
      pickerType = FileType.custom;
      allowedExt = ['txt', 'md', 'json', 'csv', 'srt', 'ass'];
  }

  final result = await FilePicker.platform.pickFiles(
    type: pickerType,
    allowedExtensions: allowedExt,
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

enum _FileStatus { waiting, uploading, success, failed }

class _FileState {
  _FileState(this.name);
  final String name;
  _FileStatus status = _FileStatus.waiting;
}

/// 批量导入进度弹窗：逐条展示文件状态
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
  late List<_FileState> _fileStates;
  int _done = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _fileStates = widget.files.map((f) => _FileState(f.name)).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runUpload());
  }

  Future<void> _runUpload() async {
    final notifier = widget.ref.read(resourceListProvider.notifier);
    final fileSvc = FileService();
    final isVisual = widget.libraryType.modality == ResourceModality.visual;
    final isText = widget.libraryType.modality == ResourceModality.text;

    for (var i = 0; i < widget.files.length; i++) {
      if (!mounted) return;
      setState(() => _fileStates[i].status = _FileStatus.uploading);

      final file = widget.files[i];
      final bytes = file.bytes;
      if (bytes == null) {
        if (mounted) {
          setState(() {
            _fileStates[i].status = _FileStatus.failed;
            _done++;
          });
        }
        continue;
      }

      try {
        final url = await fileSvc.upload(bytes, file.name, category: 'general');
        final baseName = file.name.contains('.')
            ? file.name.substring(0, file.name.lastIndexOf('.'))
            : file.name;
        final name = baseName.isNotEmpty
            ? baseName
            : '${widget.libraryType.label}-${i + 1}';
        final meta = <String, dynamic>{};

        if (isVisual) {
          try {
            final codec =
                await ui.instantiateImageCodec(Uint8List.fromList(bytes));
            final frame = await codec.getNextFrame();
            meta['resolution'] = '${frame.image.width}x${frame.image.height}';
            frame.image.dispose();
          } catch (_) {}
        }

        String description = '';
        if (isText) {
          try {
            description = utf8.decode(bytes, allowMalformed: true);
          } catch (_) {}
        }

        await notifier.addResource(
          Resource(
            name: name,
            libraryType: widget.libraryType.name,
            modality: widget.libraryType.modality.name,
            thumbnailUrl: url,
            description: description,
            version: 'v1.0',
            metadataJson: meta.isEmpty ? '' : jsonEncode(meta),
          ),
        );
        if (mounted) setState(() => _fileStates[i].status = _FileStatus.success);
      } catch (e) {
        debugPrint('BatchImport failed for ${file.name}: $e');
        if (mounted) setState(() => _fileStates[i].status = _FileStatus.failed);
      }
      if (mounted) setState(() => _done++);
    }

    if (mounted) {
      setState(() => _finished = true);
      await notifier.load();
    }
  }

  int get _failCount =>
      _fileStates.where((f) => f.status == _FileStatus.failed).length;

  @override
  Widget build(BuildContext context) {
    final total = widget.files.length;
    final progress = total > 0 ? _done / total : 0.0;

    return Dialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420.w, maxHeight: 480.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部
            Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.xl.w, Spacing.lg.h, Spacing.md.w, Spacing.md.h,
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.upload,
                    size: 22.r,
                    color: widget.accentColor,
                  ),
                  SizedBox(width: Spacing.md.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _finished ? '导入完成' : '正在导入…',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: Spacing.xxs.h),
                        Text(
                          '$_done/$total 个文件'
                          '${_failCount > 0 ? '（${_failCount} 个失败）' : ''}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_finished)
                    IconButton(
                      icon: Icon(AppIcons.close, size: 18.r, color: AppColors.muted),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
            ),

            // 进度条
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.xl.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.r),
                child: LinearProgressIndicator(
                  value: _finished ? 1.0 : progress,
                  backgroundColor: AppColors.inputBackground,
                  minHeight: 3.h,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(widget.accentColor),
                ),
              ),
            ),
            SizedBox(height: Spacing.md.h),

            // 文件列表
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: Spacing.xl.w),
                itemCount: _fileStates.length,
                itemBuilder: (ctx, i) {
                  final fs = _fileStates[i];
                  return Padding(
                    padding: EdgeInsets.only(bottom: Spacing.xs.h),
                    child: Row(
                      children: [
                        _statusIcon(fs.status),
                        SizedBox(width: Spacing.sm.w),
                        Expanded(
                          child: Text(
                            fs.name,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: fs.status == _FileStatus.failed
                                  ? AppColors.error
                                  : AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: Spacing.md.h),

            // 底部按钮
            if (_finished)
              Padding(
                padding: EdgeInsets.only(bottom: Spacing.lg.h),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.xl.w,
                      vertical: Spacing.sm.h,
                    ),
                  ),
                  child: const Text('完成'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(_FileStatus status) {
    return switch (status) {
      _FileStatus.waiting => Icon(
          Icons.circle_outlined,
          size: 14.r,
          color: AppColors.mutedDark,
        ),
      _FileStatus.uploading => SizedBox(
          width: 14.r,
          height: 14.r,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: widget.accentColor,
          ),
        ),
      _FileStatus.success => Icon(
          Icons.check_circle_rounded,
          size: 14.r,
          color: AppColors.success,
        ),
      _FileStatus.failed => Icon(
          Icons.error_rounded,
          size: 14.r,
          color: AppColors.error,
        ),
    };
  }
}
