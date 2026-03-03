import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_config.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_dialog.dart';
import 'package:anime_ui/pub/widgets/text_gen/text_gen_config.dart';
import 'package:anime_ui/pub/widgets/text_gen/text_gen_dialog.dart';
import 'package:anime_ui/pub/widgets/voice_gen/voice_gen_config.dart';
import 'package:anime_ui/pub/widgets/voice_gen/voice_gen_dialog.dart';

import '../models/resource_category.dart';
import '../models/resource_meta_schema.dart';
import '../providers/provider.dart';
import '../widgets/meta_field_editor.dart';
import '../widgets/upload_area.dart';

/// 添加模式：上传、AI 生成、手动填写
enum AddMode { upload, aiGenerate, manual }

extension ResourceLibraryAddModes on ResourceLibraryType {
  List<AddMode> get availableAddModes => switch (this) {
        ResourceLibraryType.character ||
        ResourceLibraryType.scene ||
        ResourceLibraryType.prop ||
        ResourceLibraryType.expression ||
        ResourceLibraryType.pose ||
        ResourceLibraryType.effect =>
          [AddMode.upload, AddMode.aiGenerate],
        ResourceLibraryType.voice => [AddMode.upload, AddMode.aiGenerate],
        ResourceLibraryType.voiceover => [AddMode.upload],
        ResourceLibraryType.sfx => [AddMode.upload],
        ResourceLibraryType.music => [AddMode.upload],
        ResourceLibraryType.prompt ||
        ResourceLibraryType.styleGuide ||
        ResourceLibraryType.dialogueTemplate ||
        ResourceLibraryType.scriptSnippet =>
          [AddMode.aiGenerate, AddMode.manual],
      };

  List<AddMode> get uploadModes =>
      availableAddModes.where((m) => m != AddMode.aiGenerate).toList();
}

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

void showResourceAiGenerateDialog(
  BuildContext context,
  WidgetRef ref, {
  required ResourceLibraryType libraryType,
  required Color accentColor,
}) {
  if (libraryType.modality == ResourceModality.audio) {
    VoiceGenDialog.show(
      context,
      ref,
      config: VoiceGenConfig.voiceLibrary(
        accentColor: accentColor,
        onSaved: (_) async {
          ref.read(resourceListProvider.notifier).load();
        },
      ),
    );
    return;
  }

  if (libraryType.modality == ResourceModality.text) {
    final config = switch (libraryType) {
      ResourceLibraryType.styleGuide => TextGenConfig.styleGuide(
          accentColor: accentColor,
          onComplete: (_) async {
            ref.read(resourceListProvider.notifier).load();
          },
        ),
      ResourceLibraryType.dialogueTemplate => TextGenConfig.dialogue(
          accentColor: accentColor,
          onComplete: (_) async {
            ref.read(resourceListProvider.notifier).load();
          },
        ),
      _ => TextGenConfig.newPrompt(
          accentColor: accentColor,
          category: libraryType.name,
          onComplete: (_) async {
            ref.read(resourceListProvider.notifier).load();
          },
        ),
    };
    TextGenDialog.show(context, ref, config: config);
    return;
  }

  ImageGenDialog.show(
    context,
    ref,
    config: ImageGenConfig.forLibraryType(
      libraryType.name,
      accentColor: accentColor,
      onSaved: (urls, mode, {prompt = '', negativePrompt = ''}) async {
        final notifier = ref.read(resourceListProvider.notifier);
        for (final url in urls) {
          await notifier.addResource(
            Resource(
              name:
                  '${libraryType.label}-${DateTime.now().millisecondsSinceEpoch}',
              libraryType: libraryType.name,
              modality: libraryType.modality.name,
              thumbnailUrl: url,
              metadataJson: jsonEncode({
                'prompt': prompt,
                'negativePrompt': negativePrompt,
              }),
            ),
          );
        }
        ref.read(resourceListProvider.notifier).load();
      },
    ),
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

  @override
  Widget build(BuildContext context) {
    final modes = widget.libraryType.uploadModes;
    return Dialog(
      backgroundColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600.w, maxHeight: 700.h),
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
      padding: EdgeInsets.fromLTRB(Spacing.xl.w, Spacing.lg.h, Spacing.md.w, Spacing.md.h),
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
        labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.xl.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mode == AddMode.upload) _buildUploadSection(),
          _buildBasicFields(),
          _buildTagSection(),
          if (schema.isNotEmpty) _buildSchemaSection(),
        ],
      ),
    );
  }

  Widget _buildEditBody() {
    final isVisual = widget.libraryType.modality == ResourceModality.visual;
    final isAudio = widget.libraryType.modality == ResourceModality.audio;
    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.xl.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isVisual || isAudio)
            ResourceUploadArea(
              accentColor: accent,
              fileType:
                  isAudio ? UploadFileType.audio : UploadFileType.image,
              currentUrl: _uploadedUrl.isNotEmpty ? _uploadedUrl : null,
              label: isAudio ? '点击替换音频' : '点击替换图片',
              onUploaded: (url) => setState(() => _uploadedUrl = url),
            ),
          if (isVisual || isAudio) SizedBox(height: Spacing.lg.h),
          _buildBasicFields(),
          _buildTagSection(),
          if (schema.isNotEmpty) _buildSchemaSection(),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    final isAudio =
        widget.libraryType.modality == ResourceModality.audio;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            width: 200.w,
            child: ResourceUploadArea(
              accentColor: accent,
              fileType: isAudio ? UploadFileType.audio : UploadFileType.image,
              currentUrl: _uploadedUrl.isNotEmpty ? _uploadedUrl : null,
              onUploaded: (url) => setState(() => _uploadedUrl = url),
            ),
          ),
        ),
        SizedBox(height: Spacing.lg.h),
      ],
    );
  }

  Widget _buildBasicFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '名称',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mutedLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.xs.h),
        TextField(
          controller: _nameCtrl,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: '输入素材名称',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
          ),
        ),
        SizedBox(height: Spacing.md.h),
        Text(
          '描述',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mutedLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.xs.h),
        TextField(
          controller: _descCtrl,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: widget.libraryType == ResourceLibraryType.prompt
                ? '输入提示词内容…'
                : '输入素材描述…',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Spacing.md.w,
              vertical: Spacing.sm.h,
            ),
          ),
        ),
        SizedBox(height: Spacing.lg.h),
      ],
    );
  }

  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标签',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mutedLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.xs.h),
        Wrap(
          spacing: Spacing.xs.w,
          runSpacing: Spacing.xs.h,
          children: [
            ..._tags.map((tag) => Chip(
                  label: Text(tag, style: AppTextStyles.caption),
                  deleteIcon: Icon(AppIcons.close, size: 14.r, color: accent),
                  onDeleted: () => setState(() => _tags.remove(tag)),
                  backgroundColor: accent.withValues(alpha: 0.1),
                  side: BorderSide(color: accent.withValues(alpha: 0.2)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )),
            SizedBox(
              width: 120.w,
              height: 32.h,
              child: TextField(
                controller: _tagInputCtrl,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: '+ 添加标签',
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm.w,
                    vertical: 0,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: _addTag,
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.lg.h),
      ],
    );
  }

  Widget _buildSchemaSection() {
    final availableValues = ref.read(availableMetaValuesProvider);
    final editableFields = schema.where((f) => !f.readOnly).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '元数据',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.mutedLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Spacing.sm.h),
        ...editableFields.map((f) => MetaFieldEditor(
              field: f,
              value: _metaValues[f.key] ?? '',
              accentColor: accent,
              extraOptions: availableValues[f.key],
              onChanged: (v) => setState(() => _metaValues[f.key] = v),
            )),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(Spacing.xl.w, Spacing.md.h, Spacing.xl.w, Spacing.lg.h),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            ),
          ),
          SizedBox(width: Spacing.md.w),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(backgroundColor: accent),
            child: _saving
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Text(isEdit ? '保存' : '创建'),
          ),
        ],
      ),
    );
  }
}
