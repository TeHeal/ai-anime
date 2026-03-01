import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/prop.dart';

/// 道具编辑对话框
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
    _appearance = TextEditingController(text: widget.initial?.appearance ?? '');
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
    return AlertDialog(
      backgroundColor: AppColors.surfaceMutedDarker,
      title: Text(
        widget.title,
        style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
      ),
      content: SizedBox(
        width: 400.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('道具名称', _name, required: true),
            _field('外观描述', _appearance, maxLines: 3),
            SizedBox(height: Spacing.xs.h),
            SwitchListTile(
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
          ],
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
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(widget.initial != null ? '保存' : '创建'),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.md.h),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.mutedDark,
          ),
          hintText: hint,
          hintStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.surfaceMuted,
          ),
          filled: true,
          fillColor: AppColors.surfaceMutedDarker,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.md.h,
          ),
        ),
      ),
    );
  }
}
