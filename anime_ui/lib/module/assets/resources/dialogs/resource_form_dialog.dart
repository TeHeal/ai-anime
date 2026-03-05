import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/asset_form_shell.dart';
import 'package:anime_ui/pub/widgets/asset_upload_area.dart';
import 'package:anime_ui/pub/widgets/asset_section_label.dart';
import 'package:anime_ui/pub/widgets/asset_input_field.dart';
import 'package:anime_ui/pub/widgets/asset_tag_editor.dart';

import '../models/resource_category.dart';
import '../models/resource_meta_schema.dart';
import '../providers/provider.dart';
import '../widgets/resource_form_fields.dart';

export 'batch_upload_dialog.dart' show showResourceBatchUploadDialog;
export 'resource_ai_generate.dart' show showResourceAiGenerateDialog;

Future<T?> showResourceFormDialog<T>(
  BuildContext context,
  WidgetRef ref, {
  required ResourceLibraryType libraryType,
  required Color accentColor,
  Resource? initial,
}) {
  return showDialog<T>(
    context: context,
    builder: (_) => _ResourceFormDialog(
      libraryType: libraryType,
      accentColor: accentColor,
      initial: initial,
      ref: ref,
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
  );
}

class _ResourceFormDialog extends ConsumerStatefulWidget {
  const _ResourceFormDialog({
    required this.libraryType,
    required this.accentColor,
    this.initial,
    required this.ref,
  });

  final ResourceLibraryType libraryType;
  final Color accentColor;
  final Resource? initial;
  final WidgetRef ref;

  @override
  ConsumerState<_ResourceFormDialog> createState() =>
      _ResourceFormDialogState();
}

class _ResourceFormDialogState extends ConsumerState<_ResourceFormDialog> {
  @override
  WidgetRef get ref => widget.ref;
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _tagInputCtrl;

  final _metaValues = <String, String>{};
  final _customMeta = <String, String>{};
  List<String> _tags = [];
  String _uploadedUrl = '';
  String _textPreview = '';
  bool _saving = false;

  bool get isEdit => widget.initial != null;
  Color get accent => widget.accentColor;
  List<MetaFieldDef> get schema =>
      ResourceMetaSchema.forLibrary(widget.libraryType);
  ResourceModality get _modality => widget.libraryType.modality;
  bool get _isVisual => _modality == ResourceModality.visual;
  bool get _isAudio => _modality == ResourceModality.audio;
  bool get _isText => _modality == ResourceModality.text;

  UploadFileType get _uploadFileType => switch (_modality) {
        ResourceModality.visual => UploadFileType.image,
        ResourceModality.audio => UploadFileType.audio,
        ResourceModality.text => UploadFileType.text,
      };

  @override
  void initState() {
    super.initState();
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
        } else {
          _customMeta[entry.key] = '${entry.value}';
        }
      }
    }
  }

  @override
  void dispose() {
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
    for (final entry in _customMeta.entries) {
      if (entry.key.isNotEmpty && entry.value.isNotEmpty) {
        map[entry.key] = entry.value;
      }
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
    // 非编辑模式下，视觉/音频类必须上传文件
    if (!isEdit && !_isText && _uploadedUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isVisual ? '请先上传图片' : '请先上传音频文件'),
          backgroundColor: AppColors.warning,
        ),
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

  void _applyFileInfo(UploadFileInfo info) {
    if (_nameCtrl.text.trim().isEmpty) {
      _nameCtrl.text = info.fileName;
    }
    if (info.resolution != null &&
        schema.any((f) => f.key == 'resolution')) {
      _metaValues['resolution'] = info.resolution!;
      setState(() {});
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
    return AssetFormShell(
      title: isEdit ? '编辑素材' : '添加素材',
      subtitle: widget.libraryType.label,
      icon: widget.libraryType.icon,
      accent: accent,
      primaryLabel: isEdit ? '保存' : '创建',
      onPrimary: _save,
      saving: _saving,
      maxWidth: 820.w,
      maxHeight: 720.h,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          return isWide ? _buildTwoColumnBody() : _buildBody();
        },
      ),
    );
  }

  // ─────────────────── 表单主体 ───────────────────

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl.w,
        vertical: Spacing.lg.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUploadSection(),
          SizedBox(height: Spacing.lg.h),
          _buildNameField(),
          SizedBox(height: Spacing.md.h),
          AssetTagEditor(
            tags: _tags,
            controller: _tagInputCtrl,
            accent: accent,
            onTagAdded: _addTag,
            onTagRemoved: (tag) => setState(() => _tags.remove(tag)),
          ),
          if (schema.isNotEmpty) ...[
            ResourceSchemaSection(
              schema: schema,
              metaValues: _metaValues,
              accentColor: accent,
              availableValues: ref.read(availableMetaValuesProvider),
              onChanged: (key, value) =>
                  setState(() => _metaValues[key] = value),
            ),
          ],
          if (_isText) _buildTextPreviewSection(),
          _buildCustomMetaSection(),
        ],
      ),
    );
  }

  // ─────────────────── 双列布局（宽屏） ───────────────────

  Widget _buildTwoColumnBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左列：上传 + 名称 + 标签 + 自定义元数据
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              Spacing.xl.w, Spacing.lg.h, Spacing.md.w, Spacing.lg.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUploadSection(),
                SizedBox(height: Spacing.lg.h),
                _buildNameField(),
                SizedBox(height: Spacing.md.h),
                AssetTagEditor(
                  tags: _tags,
                  controller: _tagInputCtrl,
                  accent: accent,
                  onTagAdded: _addTag,
                  onTagRemoved: (tag) => setState(() => _tags.remove(tag)),
                ),
                _buildCustomMetaSection(),
              ],
            ),
          ),
        ),
        // 分隔线
        Container(
          width: 1,
          color: AppColors.border.withValues(alpha: 0.4),
        ),
        // 右列：属性 + 提示词（视觉/音频）或内容预览（文本）
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              Spacing.md.w, Spacing.lg.h, Spacing.xl.w, Spacing.lg.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (schema.isNotEmpty)
                  ResourceSchemaSection(
                    schema: schema,
                    metaValues: _metaValues,
                    accentColor: accent,
                    availableValues: ref.read(availableMetaValuesProvider),
                    onChanged: (key, value) =>
                        setState(() => _metaValues[key] = value),
                  ),
                if (_isText) _buildTextPreviewSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────── 文本内容预览（仅文本类右列） ───────────────────

  Widget _buildTextPreviewSection() {
    final hasContent = _textPreview.isNotEmpty ||
        (isEdit && (widget.initial?.description.isNotEmpty ?? false));
    final content = _textPreview.isNotEmpty
        ? _textPreview
        : (widget.initial?.description ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Spacing.lg.h),
        AssetSectionLabel('内容预览', accent: accent),
        SizedBox(height: Spacing.sm.h),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 120.h, maxHeight: 200.h),
          padding: EdgeInsets.all(Spacing.md.r),
          decoration: BoxDecoration(
            color: AppColors.inputBackground.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(
              color: hasContent
                  ? accent.withValues(alpha: 0.2)
                  : AppColors.border.withValues(alpha: 0.3),
            ),
          ),
          child: hasContent
              ? SingleChildScrollView(
                  child: Text(
                    content,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.8),
                      height: 1.6,
                    ),
                    maxLines: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppIcons.document,
                        size: 28.r,
                        color: AppColors.muted.withValues(alpha: 0.4),
                      ),
                      SizedBox(height: Spacing.sm.h),
                      Text(
                        '上传文件后预览内容',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mutedDark,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  // ─────────────────── 上传区 ───────────────────

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AssetSectionLabel('上传文件', accent: accent, required: !isEdit && !_isText),
        SizedBox(height: Spacing.sm.h),
        AssetUploadArea(
          accentColor: accent,
          fileType: _uploadFileType,
          currentUrl: _uploadedUrl.isNotEmpty ? _uploadedUrl : null,
          label: isEdit
              ? (_isVisual ? '点击替换图片' : _isAudio ? '点击替换音频' : '点击替换文件')
              : null,
          height: _isVisual ? 160.h : null,
          textPreview: _textPreview,
          onUploaded: (url) => setState(() => _uploadedUrl = url),
          onFileInfo: _applyFileInfo,
          onTextContent: (content) {
            setState(() => _textPreview = content);
            if (_descCtrl.text.trim().isEmpty) {
              _descCtrl.text = content;
            }
          },
        ),
      ],
    );
  }

  // ─────────────────── 名称 ───────────────────

  Widget _buildNameField() {
    return AssetInputField(
      label: '名称',
      controller: _nameCtrl,
      hint: '输入素材名称',
      accent: accent,
      required: true,
    );
  }

  // ─────────────────── 自定义元数据 ───────────────────

  Widget _buildCustomMetaSection() {
    return ExpansionTile(
      initiallyExpanded: true,
      controlAffinity: ListTileControlAffinity.leading,
      collapsedIconColor: AppColors.muted,
      iconColor: accent,
      tilePadding: EdgeInsets.zero,
      title: Row(
        children: [
          Text(
            '自定义属性',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.mutedLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_customMeta.isNotEmpty) ...[
            SizedBox(width: Spacing.xs.w),
            Text(
              '(${_customMeta.length})',
              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
            ),
          ],
        ],
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: Spacing.md.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._customMeta.entries.map(
                (e) => _CustomMetaRow(
                  key: ValueKey(e.key),
                  fieldKey: e.key,
                  fieldValue: e.value,
                  accentColor: accent,
                  onUpdate: (k, v) {
                    setState(() {
                      _customMeta.remove(e.key);
                      _customMeta[k] = v;
                    });
                  },
                  onRemove: () => setState(() => _customMeta.remove(e.key)),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  final key =
                      'field_${DateTime.now().millisecondsSinceEpoch}';
                  setState(() => _customMeta[key] = '');
                },
                icon: Icon(AppIcons.add, size: 14.r, color: accent),
                label: Text(
                  '添加字段',
                  style: AppTextStyles.bodySmall.copyWith(color: accent),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm.w,
                    vertical: Spacing.xs.h,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

/// 自定义元数据行
class _CustomMetaRow extends StatefulWidget {
  const _CustomMetaRow({
    super.key,
    required this.fieldKey,
    required this.fieldValue,
    required this.accentColor,
    required this.onUpdate,
    required this.onRemove,
  });

  final String fieldKey;
  final String fieldValue;
  final Color accentColor;
  final void Function(String key, String value) onUpdate;
  final VoidCallback onRemove;

  @override
  State<_CustomMetaRow> createState() => _CustomMetaRowState();
}

class _CustomMetaRowState extends State<_CustomMetaRow> {
  late TextEditingController _keyCtrl;
  late TextEditingController _valueCtrl;

  @override
  void initState() {
    super.initState();
    _keyCtrl = TextEditingController(text: widget.fieldKey);
    _valueCtrl = TextEditingController(text: widget.fieldValue);
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    final k = _keyCtrl.text.trim();
    final v = _valueCtrl.text.trim();
    if (k.isNotEmpty && (k != widget.fieldKey || v != widget.fieldValue)) {
      widget.onUpdate(k, v);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.sm.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _keyCtrl,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
              decoration: _deco('Key'),
              onChanged: (_) => _sync(),
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _valueCtrl,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
              decoration: _deco('Value'),
              onChanged: (_) => _sync(),
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.close, size: 16.r, color: AppColors.muted),
            onPressed: widget.onRemove,
            tooltip: '移除',
            style: IconButton.styleFrom(
              padding: EdgeInsets.all(Spacing.xs.r),
              minimumSize: Size(28.r, 28.r),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _deco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDark),
        filled: true,
        fillColor: AppColors.inputBackground.withValues(alpha: 0.6),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w,
          vertical: Spacing.sm.h,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          borderSide: BorderSide(color: widget.accentColor.withValues(alpha: 0.6)),
        ),
      );
}
