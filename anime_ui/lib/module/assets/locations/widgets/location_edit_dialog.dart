import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/location.dart';

/// 场景编辑对话框
class LocationEditDialog extends StatefulWidget {
  const LocationEditDialog({
    super.key,
    required this.title,
    this.initial,
    required this.onSave,
  });

  final String title;
  final Location? initial;
  final void Function(Location) onSave;

  @override
  State<LocationEditDialog> createState() => _LocationEditDialogState();
}

class _LocationEditDialogState extends State<LocationEditDialog> {
  late final TextEditingController _name;
  late final TextEditingController _time;
  late final TextEditingController _ie;
  late final TextEditingController _atmosphere;
  late final TextEditingController _colorTone;
  late final TextEditingController _styleNote;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _name = TextEditingController(text: i?.name ?? '');
    _time = TextEditingController(text: i?.time ?? '');
    _ie = TextEditingController(text: i?.interiorExterior ?? '');
    _atmosphere = TextEditingController(text: i?.atmosphere ?? '');
    _colorTone = TextEditingController(text: i?.colorTone ?? '');
    _styleNote = TextEditingController(text: i?.styleNote ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _time.dispose();
    _ie.dispose();
    _atmosphere.dispose();
    _colorTone.dispose();
    _styleNote.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) return;
    widget.onSave(
      Location(
        id: widget.initial?.id,
        projectId: widget.initial?.projectId,
        name: _name.text.trim(),
        time: _time.text.trim(),
        interiorExterior: _ie.text.trim(),
        atmosphere: _atmosphere.text.trim(),
        colorTone: _colorTone.text.trim(),
        styleNote: _styleNote.text.trim(),
        imageUrl: widget.initial?.imageUrl ?? '',
        taskId: widget.initial?.taskId ?? '',
        imageStatus: widget.initial?.imageStatus ?? 'none',
      ),
    );
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
        width: 440.w,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field('场景名称', _name, required: true),
              _field('时间', _time, hint: '白天 / 夜晚 / 黄昏…'),
              _field('内外景', _ie, hint: '内景 / 外景 / 内外结合'),
              _field('氛围', _atmosphere, hint: '温馨、紧张、压抑…'),
              _field('色调', _colorTone, hint: '暖色调 / 冷色调 / 灰蓝…'),
              _field('风格备注', _styleNote, maxLines: 3),
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
