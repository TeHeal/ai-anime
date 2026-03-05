import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/prop.dart';
import 'package:anime_ui/pub/widgets/asset_form_shell.dart';
import 'package:anime_ui/pub/widgets/asset_input_field.dart';
import 'package:anime_ui/pub/widgets/asset_section_label.dart';

/// 道具新建/编辑对话框
class PropEditDialog extends StatefulWidget {
  const PropEditDialog({
    super.key,
    required this.title,
    this.initial,
    required this.onSave,
  });

  final String title;
  final Prop? initial;
  final void Function(Prop) onSave;

  @override
  State<PropEditDialog> createState() => _PropEditDialogState();
}

class _PropEditDialogState extends State<PropEditDialog> {
  late final TextEditingController _name;
  late final TextEditingController _appearance;
  late bool _isKeyProp;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _appearance =
        TextEditingController(text: widget.initial?.appearance ?? '');
    _isKeyProp = widget.initial?.isKeyProp ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _appearance.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) return;
    final prop = (widget.initial ?? const Prop()).copyWith(
      name: _name.text.trim(),
      appearance: _appearance.text.trim(),
      isKeyProp: _isKeyProp,
    );
    widget.onSave(prop);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AssetFormShell(
      title: widget.title,
      icon: AppIcons.tag,
      primaryLabel: widget.initial != null ? '保存' : '创建',
      onPrimary: _submit,
      maxWidth: 440.w,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.xl.w,
          vertical: Spacing.lg.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AssetInputField(
              label: '道具名称',
              controller: _name,
              required: true,
            ),
            SizedBox(height: Spacing.md.h),
            AssetInputField(
              label: '外观描述',
              controller: _appearance,
              maxLines: 3,
            ),
            SizedBox(height: Spacing.md.h),
            const AssetSectionLabel('道具属性'),
            SizedBox(height: Spacing.xs.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
              decoration: BoxDecoration(
                color: AppColors.inputBackground.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              child: SwitchListTile(
                title: Text(
                  '关键道具',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mutedLight,
                  ),
                ),
                subtitle: Text(
                  '标记为关键道具会在总览中优先提示',
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.mutedDarker,
                  ),
                ),
                value: _isKeyProp,
                onChanged: (v) => setState(() => _isKeyProp = v),
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
