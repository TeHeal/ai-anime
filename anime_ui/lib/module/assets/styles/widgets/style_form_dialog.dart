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
import 'package:anime_ui/pub/widgets/image_gen/image_gen_config.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_dialog.dart';
import 'package:anime_ui/pub/widgets/prompt_field_with_assistant.dart';

/// 风格表单对话框：新建/编辑，支持上传或 AI 生成参考图
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
      } catch (_) {}
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

  Future<void> _openAiGenForStyleImages() async {
    await ImageGenDialog.show(
      context,
      widget.ref,
      config: ImageGenConfig.style(
        onSaved: (urls, mode, {prompt = '', negativePrompt = ''}) async {
          if (!mounted) return;
          setState(() {
            for (final url in urls) {
              if (_refImageUrls.length < _maxImages) {
                _refImageUrls.add(url);
              }
            }
            if (prompt.isNotEmpty && _descCtrl.text.isEmpty) {
              _descCtrl.text = prompt;
            }
            if (negativePrompt.isNotEmpty && _negCtrl.text.isEmpty) {
              _negCtrl.text = negativePrompt;
            }
          });
        },
      ),
    );
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
    final resources = widget.ref.read(resourceListProvider).value ?? [];
    final prompts =
        resources.where((r) => r.libraryType == 'prompt').toList();
    showPromptLibrary(
      context,
      prompts: prompts,
      accent: _accent,
      onSelected: onSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 520.w,
      padding: EdgeInsets.all(Spacing.xl.r),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEdit ? '编辑风格' : '新建风格',
              style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
            ),
            SizedBox(height: Spacing.lg.h),
            TextField(
              controller: _nameCtrl,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                labelText: '风格名称 *',
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.muted,
                ),
                hintText: '如：赛博朋克、水彩手绘',
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
              ),
            ),
            SizedBox(height: Spacing.md.h),
            PromptFieldWithAssistant(
              controller: _descCtrl,
              negPromptController: _negCtrl,
              hint: '描述画面风格、色调、氛围…',
              negPromptHint: '不想出现的元素，如：模糊、变形…',
              accent: _accent,
              label: '提示词',
              maxLines: 3,
              onLibraryTap: (setText) => _showPromptLibrary(setText),
              onSaveToLibrary: (text, name, {required bool isNegative}) async {
                await widget.ref.read(resourceListProvider.notifier).addResource(
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
            Row(
              children: [
                Text(
                  '风格参考图',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.onSurface,
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
            Wrap(
              spacing: Spacing.sm.w,
              runSpacing: Spacing.sm.h,
              children: [
                ..._refImageUrls.asMap().entries.map((e) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                        child: SizedBox(
                          width: 64.w,
                          height: 64.h,
                          child: Image.network(
                            resolveFileUrl(e.value),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
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
                }),
                if (_refImageUrls.length < _maxImages)
                  GestureDetector(
                    onTap: _uploading ? null : _pickAndUploadImages,
                    child: Container(
                      width: 64.w,
                      height: 64.h,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMutedDark,
                        borderRadius:
                            BorderRadius.circular(RadiusTokens.sm.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        AppIcons.upload,
                        size: 24.r,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                SizedBox(width: Spacing.sm.w),
                OutlinedButton.icon(
                  onPressed: _uploading ? null : _openAiGenForStyleImages,
                  icon: Icon(AppIcons.magicStick, size: 14.r),
                  label: const Text('AI 生成'),
                ),
              ],
            ),
            SizedBox(height: Spacing.xl.h),
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
        ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64.w,
      height: 64.h,
      color: AppColors.surfaceMutedDark,
      child: Icon(AppIcons.brush, size: 24.r, color: AppColors.muted),
    );
  }
}
