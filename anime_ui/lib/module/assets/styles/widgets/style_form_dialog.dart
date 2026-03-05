import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/assets/resources/providers/provider.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/style.dart';
import 'package:anime_ui/pub/services/file_svc.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/widgets/image_lightbox.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';

/// 风格表单对话框：新建/编辑，支持上传参考图
class StyleFormDialog extends ConsumerStatefulWidget {
  const StyleFormDialog({
    super.key,
    required this.ref,
    this.existing,
    required this.onSave,
  });

  final WidgetRef ref;
  final Style? existing;
  final void Function(
    String name,
    String description,
    String negativePrompt,
    String refImagesJson,
    String thumbnailUrl,
  ) onSave;

  @override
  ConsumerState<StyleFormDialog> createState() => _StyleFormDialogState();
}

class _StyleFormDialogState extends ConsumerState<StyleFormDialog> {
  static const _accent = AppColors.primary;
  static const _maxImages = 4;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _negCtrl;
  final List<String> _refImageUrls = [];
  bool _uploading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => widget.ref.read(resourceListProvider.notifier).load());
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _descCtrl = TextEditingController(text: widget.existing?.description ?? '');
    _negCtrl = TextEditingController(text: widget.existing?.negativePrompt ?? '');
    if (widget.existing?.referenceImagesJson.isNotEmpty == true) {
      try {
        final list = jsonDecode(widget.existing!.referenceImagesJson) as List;
        for (final item in list) {
          final url = (item as Map<String, dynamic>)['url'] as String?;
          if (url != null && url.isNotEmpty) {
            _refImageUrls.add(url);
          }
        }
      } catch (e) {
        debugPrint('解析参考图 JSON 失败: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _negCtrl.dispose();
    super.dispose();
  }

  String _buildRefImagesJson() {
    if (_refImageUrls.isEmpty) return '';
    return jsonEncode(
      _refImageUrls.map((u) => {'url': u}).toList(),
    );
  }

  String get _thumbnailUrl =>
      _refImageUrls.isNotEmpty ? _refImageUrls.first : '';

  Future<void> _pickAndUploadImages() async {
    final remaining = _maxImages - _refImageUrls.length;
    if (remaining <= 0) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() => _uploading = true);
    try {
      final svc = FileService();
      for (final file in result.files) {
        if (_refImageUrls.length >= _maxImages) break;
        if (file.bytes == null) continue;
        final url = await svc.upload(
          file.bytes!,
          file.name,
          category: 'style_reference',
        );
        setState(() => _refImageUrls.add(url));
      }
    } catch (e) {
      if (mounted) {
        showToast(context, '上传失败: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _removeImage(int index) {
    setState(() => _refImageUrls.removeAt(index));
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showToast(context, '请输入风格名称', isInfo: true);
      return;
    }
    widget.onSave(
      name,
      _descCtrl.text.trim(),
      _negCtrl.text.trim(),
      _buildRefImagesJson(),
      _thumbnailUrl,
    );
    Navigator.of(context).pop();
  }

  void _showPromptLibrary(void Function(String) onSelected) {
    final promptsAsync = widget.ref.read(promptResourcesProvider);
    promptsAsync.when(
      data: (prompts) => showPromptLibrary(
        context,
        prompts: prompts,
        accent: _accent,
        onSelected: onSelected,
      ),
      loading: () => showToast(context, '正在加载提示词库…', isInfo: true),
      error: (e, _) => showToast(context, '提示词库加载失败', isError: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit
        ? '编辑风格 · ${widget.existing!.name}'
        : '新建风格';

    return Container(
      width: 520.w,
      constraints: BoxConstraints(maxHeight: 640.h),
      padding: EdgeInsets.all(Spacing.xl.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: Spacing.lg.h),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNameField(),
                  SizedBox(height: Spacing.md.h),
                  PromptFieldWithAssistant(
                    controller: _descCtrl,
                    negPromptController: _negCtrl,
                    hint: '描述画面风格、色调、氛围…',
                    negPromptHint: '不想出现的元素，如：模糊、变形…',
                    accent: _accent,
                    label: '提示词',
                    maxLines: 2,
                    onLibraryTap: (setText) => _showPromptLibrary(setText),
                    negOnLibraryTap: (setText) => _showPromptLibrary(setText),
                    onSaveToLibrary:
                        (text, name, {required bool isNegative}) async {
                      await widget.ref
                          .read(resourceListProvider.notifier)
                          .addResource(
                            Resource(
                              name: name,
                              libraryType: 'prompt',
                              modality: 'text',
                              description: text,
                            ),
                          );
                    },
                  ),
                  SizedBox(height: Spacing.lg.h),
                  _buildRefImagesSection(),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  // ── 风格名称 ──

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '风格名称',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        SizedBox(height: Spacing.sm.h),
        TextField(
          controller: _nameCtrl,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: '如：赛博朋克、水彩手绘',
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mutedDarker,
            ),
            filled: true,
            fillColor: AppColors.background.withValues(alpha: 0.5),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.md.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              borderSide: BorderSide(
                color: _accent.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 风格参考图 ──

  Widget _buildRefImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '风格参考图',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            if (_refImageUrls.isNotEmpty) ...[
              SizedBox(width: Spacing.xs.w),
              Text(
                '(${_refImageUrls.length}/$_maxImages)',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ],
            const Spacer(),
            if (_uploading)
              SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _accent,
                ),
              ),
          ],
        ),
        SizedBox(height: Spacing.sm.h),
        if (_refImageUrls.isEmpty)
          _buildUploadGuide()
        else
          Wrap(
            spacing: Spacing.sm.w,
            runSpacing: Spacing.sm.h,
            children: [
              ..._refImageUrls.asMap().entries.map(_buildImageThumb),
              if (_refImageUrls.length < _maxImages)
                _buildUploadButton(),
            ],
          ),
      ],
    );
  }

  Widget _buildImageThumb(MapEntry<int, String> e) {
    return Stack(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => showImageLightbox(context, imageUrl: e.value),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              child: SizedBox(
                width: 72.w,
                height: 72.h,
                child: Image.network(
                  resolveFileUrl(e.value),
                  fit: BoxFit.cover,
                  cacheWidth: 144,
                  errorBuilder: (_, __, ___) => _placeholder(),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 2.r,
          right: 2.r,
          child: GestureDetector(
            onTap: () => _removeImage(e.key),
            child: Container(
              padding: EdgeInsets.all(2.r),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 12.r,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 无参考图时的完整引导区
  Widget _buildUploadGuide() {
    return GestureDetector(
      onTap: _uploading ? null : _pickAndUploadImages,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: Spacing.xl.h),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                AppIcons.upload,
                size: 28.r,
                color: AppColors.muted,
              ),
              SizedBox(height: Spacing.sm.h),
              Text(
                '点击上传风格参考图',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Spacing.xxs.h),
              Text(
                '支持多选，最多 $_maxImages 张',
                style: AppTextStyles.tiny.copyWith(
                  color: AppColors.mutedDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: _uploading ? null : _pickAndUploadImages,
      child: Container(
        width: 72.w,
        height: 72.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceMutedDark,
          borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.upload, size: 20.r, color: AppColors.muted),
            SizedBox(height: Spacing.xxs.h),
            Text(
              '上传',
              style: AppTextStyles.tiny.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  // ── 底部 ──

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(height: 1, color: AppColors.divider),
        SizedBox(height: Spacing.md.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '取消',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72.w,
      height: 72.h,
      color: AppColors.surfaceMutedDark,
      child: Icon(AppIcons.brush, size: 24.r, color: AppColors.muted),
    );
  }
}
