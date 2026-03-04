import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

import '../models/resource_category.dart';
import '../models/resource_meta_schema.dart';
import '../providers/provider.dart';
import '../widgets/resource_form_fields.dart';
import '../widgets/upload_area.dart';

export 'batch_upload_dialog.dart' show showResourceBatchUploadDialog;
export 'resource_ai_generate.dart' show showResourceAiGenerateDialog;

Future<T?> showResourceFormDialog<T>(
  BuildContext context,
  WidgetRef ref, {
  required ResourceLibraryType libraryType,
  required Color accentColor,
  Resource? initial,
  AddMode? initialMode,
}) {
  return showDialog<T>(
    context: context,
    builder: (_) => _ResourceFormDialog(
      libraryType: libraryType,
      accentColor: accentColor,
      initial: initial,
      ref: ref,
      initialMode: initialMode,
    ),
  );
}

void showResourceUploadDialog(
  BuildContext context,
  WidgetRef ref, {
  required ResourceLibraryType libraryType,
  required Color accentColor,
}) {
  showResourceFormDialog(
    context,
    ref,
    libraryType: libraryType,
    accentColor: accentColor,
    initialMode: AddMode.upload,
  );
}

class _ResourceFormDialog extends ConsumerStatefulWidget {
  const _ResourceFormDialog({
    required this.libraryType,
    required this.accentColor,
    this.initial,
    required this.ref,
    this.initialMode,
  });

  final ResourceLibraryType libraryType;
  final Color accentColor;
  final Resource? initial;
  final WidgetRef ref;
  final AddMode? initialMode;

  @override
  ConsumerState<_ResourceFormDialog> createState() =>
      _ResourceFormDialogState();
}

class _ResourceFormDialogState extends ConsumerState<_ResourceFormDialog>
    with SingleTickerProviderStateMixin {
  @override
  WidgetRef get ref => widget.ref;
  late TabController _tabCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _tagInputCtrl;

  final _metaValues = <String, String>{};
  List<String> _tags = [];
  String _uploadedUrl = '';
  bool _saving = false;

  bool get isEdit => widget.initial != null;
  Color get accent => widget.accentColor;
  List<MetaFieldDef> get schema =>
      ResourceMetaSchema.forLibrary(widget.libraryType);

  @override
  void initState() {
    super.initState();
    final modes = widget.libraryType.uploadModes;
    final initialIndex = widget.initialMode != null
        ? modes.indexOf(widget.initialMode!).clamp(0, modes.length - 1)
        : 0;
    _tabCtrl = TabController(
      length: modes.length,
      vsync: this,
      initialIndex: initialIndex,
    );

    final r = widget.initial;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _tagInputCtrl = TextEditingController();

    if (r != null) {
      _tags = List.from(r.tags);
      _uploadedUrl = r.thumbnailUrl;
      final meta = r.metadata;
      for (final entry in meta.entries) {
        if (schema.any((f) => f.key == entry.key)) {
          _metaValues[entry.key] = '${entry.value}';
        }
      }
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildMetadataMap() {
    final map = <String, dynamic>{};
    for (final entry in _metaValues.entries) {
      if (entry.value.isNotEmpty) map[entry.key] = entry.value;
    }
    return map;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入素材名称')),
      );
      return;
    }
    setState(() => _saving = true);

    final metaJson = jsonEncode(_buildMetadataMap());
    final tagsJson = _tags.isEmpty ? '' : jsonEncode(_tags);

    try {
      if (isEdit) {
        await ref.read(resourceListProvider.notifier).updateResource(
              widget.initial!.copyWith(
                name: name,
                description: _descCtrl.text.trim(),
                thumbnailUrl: _uploadedUrl,
                tagsJson: tagsJson,
                metadataJson: metaJson,
              ),
            );
      } else {
        await ref.read(resourceListProvider.notifier).addResource(
              Resource(
                name: name,
                libraryType: widget.libraryType.name,
                modality: widget.libraryType.modality.name,
                description: _descCtrl.text.trim(),
                thumbnailUrl: _uploadedUrl,
                tagsJson: tagsJson,
                metadataJson: metaJson,
                version: 'v1.0',
              ),
            );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addTag(String tag) {
    tag = tag.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
    }
    _tagInputCtrl.clear();
  }

  bool get _isVisual =>
      widget.libraryType.modality == ResourceModality.visual;

  @override
  Widget build(BuildContext context) {
    final modes = widget.libraryType.uploadModes;
    return Dialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _isVisual ? 700.w : 560.w,
          maxHeight: 700.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (!isEdit && modes.length > 1) _buildModeTabs(modes),
            Flexible(
              child: isEdit
                  ? _buildEditBody()
                  : TabBarView(
                      controller: _tabCtrl,
                      children: modes.map(_buildModeBody).toList(),
                    ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w,
        Spacing.lg.h,
        Spacing.md.w,
        Spacing.md.h,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Spacing.sm.r),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            ),
            child: Icon(widget.libraryType.icon, size: 20.r, color: accent),
          ),
          SizedBox(width: Spacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? '编辑素材' : '添加素材',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Spacing.xxs.h),
                Text(
                  widget.libraryType.label,
                  style: AppTextStyles.bodySmall.copyWith(color: accent),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.close, size: 18.r, color: AppColors.muted),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabs(List<AddMode> modes) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicatorColor: accent,
        labelColor: accent,
        unselectedLabelColor: AppColors.muted,
        labelStyle:
            AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
        tabs: modes.map((m) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  m == AddMode.upload
                      ? AppIcons.upload
                      : m == AddMode.aiGenerate
                          ? AppIcons.magicStick
                          : AppIcons.edit,
                  size: 16.r,
                ),
                SizedBox(width: Spacing.xs.w),
                Text(m == AddMode.upload
                    ? '上传文件'
                    : m == AddMode.aiGenerate
                        ? 'AI 生成'
                        : '手动填写'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModeBody(AddMode mode) {
    final isVisualUpload = mode == AddMode.upload && _isVisual;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl.w,
        vertical: Spacing.lg.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isVisualUpload)
            _buildVisualUploadRow()
          else ...[
            if (mode == AddMode.upload) _buildUploadSection(),
            _buildBasicFields(),
          ],
          _buildTagSection(),
          if (schema.isNotEmpty) _buildSchemaSection(),
        ],
      ),
    );
  }

  /// 视觉类素材双栏布局：左侧上传预览 + 右侧名称/描述
  Widget _buildVisualUploadRow() {
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.lg.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220.w,
            child: ResourceUploadArea(
              accentColor: accent,
              fileType: UploadFileType.image,
              currentUrl: _uploadedUrl.isNotEmpty ? _uploadedUrl : null,
              onUploaded: (url) => setState(() => _uploadedUrl = url),
              height: 200.h,
            ),
          ),
          SizedBox(width: Spacing.lg.w),
          Expanded(child: _buildBasicFields()),
        ],
      ),
    );
  }

  Widget _buildEditBody() {
    final isAudio = widget.libraryType.modality == ResourceModality.audio;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl.w,
        vertical: Spacing.lg.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isVisual) ...[
            Padding(
              padding: EdgeInsets.only(bottom: Spacing.lg.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 220.w,
                    child: ResourceUploadArea(
                      accentColor: accent,
                      fileType: UploadFileType.image,
                      currentUrl:
                          _uploadedUrl.isNotEmpty ? _uploadedUrl : null,
                      label: '点击替换图片',
                      onUploaded: (url) =>
                          setState(() => _uploadedUrl = url),
                      height: 200.h,
                    ),
                  ),
                  SizedBox(width: Spacing.lg.w),
                  Expanded(child: _buildBasicFields()),
                ],
              ),
            ),
          ] else ...[
            if (isAudio) ...[
              ResourceUploadArea(
                accentColor: accent,
                fileType: UploadFileType.audio,
                currentUrl: _uploadedUrl.isNotEmpty ? _uploadedUrl : null,
                label: '点击替换音频',
                onUploaded: (url) => setState(() => _uploadedUrl = url),
              ),
              SizedBox(height: Spacing.lg.h),
            ],
            _buildBasicFields(),
          ],
          _buildTagSection(),
          if (schema.isNotEmpty) _buildSchemaSection(),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    final isAudio = widget.libraryType.modality == ResourceModality.audio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResourceUploadArea(
          accentColor: accent,
          fileType: isAudio ? UploadFileType.audio : UploadFileType.image,
          currentUrl: _uploadedUrl.isNotEmpty ? _uploadedUrl : null,
          onUploaded: (url) => setState(() => _uploadedUrl = url),
        ),
        SizedBox(height: Spacing.lg.h),
      ],
    );
  }

  Widget _buildBasicFields() {
    return ResourceBasicFields(
      nameController: _nameCtrl,
      descController: _descCtrl,
      accentColor: accent,
      libraryType: widget.libraryType,
    );
  }

  Widget _buildTagSection() {
    return ResourceTagEditor(
      tags: _tags,
      tagInputController: _tagInputCtrl,
      accentColor: accent,
      onTagAdded: _addTag,
      onTagRemoved: (tag) => setState(() => _tags.remove(tag)),
    );
  }

  Widget _buildSchemaSection() {
    return ResourceSchemaSection(
      schema: schema,
      metaValues: _metaValues,
      accentColor: accent,
      availableValues: ref.read(availableMetaValuesProvider),
      onChanged: (key, value) => setState(() => _metaValues[key] = value),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w,
        Spacing.md.h,
        Spacing.xl.w,
        Spacing.lg.h,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.lg.w,
                vertical: Spacing.sm.h,
              ),
            ),
            child: Text(
              '取消',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.muted),
            ),
          ),
          SizedBox(width: Spacing.md.w),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              disabledBackgroundColor: accent.withValues(alpha: 0.3),
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.xl.w,
                vertical: Spacing.sm.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              ),
            ),
            child: _saving
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEdit ? AppIcons.save : AppIcons.add,
                        size: 16.r,
                      ),
                      SizedBox(width: Spacing.xs.w),
                      Text(isEdit ? '保存' : '创建'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
