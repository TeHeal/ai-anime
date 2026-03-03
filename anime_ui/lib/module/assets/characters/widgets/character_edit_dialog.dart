import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/widgets/form_field_helpers.dart';
import 'package:anime_ui/pub/widgets/option_chips.dart';

/// 角色新建/编辑对话框
class CharacterEditDialog extends StatefulWidget {
  const CharacterEditDialog({
    super.key,
    required this.title,
    this.initial,
    required this.onSave,
  });

  final String title;
  final Character? initial;
  final void Function(Character c) onSave;

  @override
  State<CharacterEditDialog> createState() => _CharacterEditDialogState();
}

class _CharacterEditDialogState extends State<CharacterEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _appearanceController;
  late final TextEditingController _personalityController;
  late final TextEditingController _tagController;

  late String _roleType;
  late String _importance;
  late String _consistency;
  late List<String> _tags;

  Character? get initial => widget.initial;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: initial?.name ?? '');
    _appearanceController =
        TextEditingController(text: initial?.appearance ?? '');
    _personalityController =
        TextEditingController(text: initial?.personality ?? '');
    _tagController = TextEditingController();
    _roleType = initial?.roleType.isNotEmpty == true ? initial!.roleType : 'human';
    _importance =
        initial?.importance.isNotEmpty == true ? initial!.importance : 'main';
    _consistency =
        initial?.consistency.isNotEmpty == true ? initial!.consistency : 'strong';
    _tags = List<String>.from(initial?.tags ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _appearanceController.dispose();
    _personalityController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final tagsJson =
        _tags.isEmpty ? '[]' : '[${_tags.map((t) => '"$t"').join(',')}]';

    final c = (initial ?? const Character()).copyWith(
      name: name,
      appearance: _appearanceController.text.trim(),
      personality: _personalityController.text.trim(),
      roleType: _roleType,
      importance: _importance,
      consistency: _consistency,
      tagsJson: tagsJson,
    );
    widget.onSave(c);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceMutedDarker,
      title: Text(
        widget.title,
        style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
      ),
      content: SizedBox(
        width: 480.w,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DarkFieldLabel('角色名称', required: true),
              SizedBox(height: Spacing.xs.h),
              TextField(
                controller: _nameController,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
                decoration: darkInputDecoration('请输入角色名称'),
              ),
              SizedBox(height: Spacing.md.h),
              const DarkFieldLabel('角色类型'),
              SizedBox(height: Spacing.xs.h),
              OptionChips<String>(
                options: const {
                  'human': '人类',
                  'nonhuman': '非人',
                  'personified': '拟人',
                  'narrator': '旁白',
                },
                selected: _roleType,
                onSelected: (v) => setState(() => _roleType = v),
              ),
              SizedBox(height: Spacing.md.h),
              const DarkFieldLabel('重要程度'),
              SizedBox(height: Spacing.xs.h),
              OptionChips<String>(
                options: const {
                  'main': '主角',
                  'support': '配角',
                  'functional': '功能',
                  'extra': '路人',
                },
                selected: _importance,
                onSelected: (v) => setState(() => _importance = v),
              ),
              SizedBox(height: Spacing.md.h),
              const DarkFieldLabel('一致性要求'),
              SizedBox(height: Spacing.xs.h),
              OptionChips<String>(
                options: const {
                  'strong': '强',
                  'medium': '中',
                  'weak': '弱',
                },
                selected: _consistency,
                onSelected: (v) => setState(() => _consistency = v),
              ),
              SizedBox(height: Spacing.md.h),
              const DarkFieldLabel('标签'),
              SizedBox(height: Spacing.xs.h),
              _buildTagEditor(),
              SizedBox(height: Spacing.md.h),
              const DarkFieldLabel('外貌描述'),
              SizedBox(height: Spacing.xs.h),
              TextField(
                controller: _appearanceController,
                maxLines: 3,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
                decoration: darkInputDecoration('描述角色的外观特征'),
              ),
              SizedBox(height: Spacing.md.h),
              const DarkFieldLabel('性格描述'),
              SizedBox(height: Spacing.xs.h),
              TextField(
                controller: _personalityController,
                maxLines: 2,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
                decoration: darkInputDecoration('描述角色的性格特点'),
              ),
            ],
          ),
        ),
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
          onPressed: _handleSave,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('保存'),
        ),
      ],
    );
  }

  Widget _buildTagEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Spacing.sm.w,
          runSpacing: Spacing.xs.h,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag, style: AppTextStyles.tiny),
              deleteIcon: Icon(AppIcons.close, size: 14.r),
              onDeleted: () => setState(() => _tags.remove(tag)),
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              side: BorderSide.none,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
        SizedBox(height: Spacing.sm.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
                decoration: darkInputDecoration('添加标签后按回车'),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            IconButton(
              onPressed: _addTag,
              icon: Icon(AppIcons.add, size: 20.r, color: AppColors.muted),
              tooltip: '添加标签',
            ),
          ],
        ),
      ],
    );
  }
}
