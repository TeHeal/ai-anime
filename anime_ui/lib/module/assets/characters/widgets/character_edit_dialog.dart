import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/widgets/asset_form_shell.dart';
import 'package:anime_ui/pub/widgets/asset_input_field.dart';
import 'package:anime_ui/pub/widgets/asset_section_label.dart';
import 'package:anime_ui/pub/widgets/asset_tag_editor.dart';
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
  late final TextEditingController _nameCtrl;
  late final TextEditingController _appearanceCtrl;
  late final TextEditingController _personalityCtrl;

  late String _roleType;
  late String _importance;
  late String _consistency;
  late List<String> _tags;

  Character? get initial => widget.initial;
  bool get _isEdit => initial != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: initial?.name ?? '');
    _appearanceCtrl = TextEditingController(text: initial?.appearance ?? '');
    _personalityCtrl = TextEditingController(text: initial?.personality ?? '');
    _roleType =
        initial?.roleType.isNotEmpty == true ? initial!.roleType : 'human';
    _importance =
        initial?.importance.isNotEmpty == true ? initial!.importance : 'main';
    _consistency =
        initial?.consistency.isNotEmpty == true
            ? initial!.consistency
            : 'strong';
    _tags = List<String>.from(initial?.tags ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _appearanceCtrl.dispose();
    _personalityCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final tagsJson =
        _tags.isEmpty ? '[]' : '[${_tags.map((t) => '"$t"').join(',')}]';

    final c = (initial ?? const Character()).copyWith(
      name: name,
      appearance: _appearanceCtrl.text.trim(),
      personality: _personalityCtrl.text.trim(),
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
    return AssetFormShell(
      title: widget.title,
      icon: AppIcons.person,
      accent: AppColors.primary,
      primaryLabel: _isEdit ? '保存' : '创建',
      onPrimary: _handleSave,
      maxWidth: 520.w,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.xl.w,
          vertical: Spacing.lg.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AssetInputField(
              label: '角色名称',
              controller: _nameCtrl,
              hint: '请输入角色名称',
              required: true,
            ),
            SizedBox(height: Spacing.lg.h),
            const AssetSectionLabel('角色类型', accent: AppColors.primary),
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
            SizedBox(height: Spacing.lg.h),
            const AssetSectionLabel('重要程度', accent: AppColors.primary),
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
            SizedBox(height: Spacing.lg.h),
            const AssetSectionLabel('一致性要求', accent: AppColors.primary),
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
            SizedBox(height: Spacing.lg.h),
            AssetTagEditor(
              tags: _tags,
              accent: AppColors.primary,
              onTagAdded: (tag) => setState(() => _tags.add(tag)),
              onTagRemoved: (tag) => setState(() => _tags.remove(tag)),
            ),
            AssetInputField(
              label: '外貌描述',
              controller: _appearanceCtrl,
              hint: '描述角色的外观特征',
              maxLines: 3,
              labelHint: '可选',
            ),
            SizedBox(height: Spacing.md.h),
            AssetInputField(
              label: '性格描述',
              controller: _personalityCtrl,
              hint: '描述角色的性格特点',
              maxLines: 2,
              labelHint: '可选',
            ),
          ],
        ),
      ),
    );
  }
}
