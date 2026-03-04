import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/services/model_catalog_svc.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

import '../models/resource_meta_schema.dart';
import 'combobox_select.dart';

/// 按 [MetaFieldDef] 渲染单个元数据字段
/// select 支持 modelCatalog 动态加载；allowCustom 时支持自定义输入
class MetaFieldEditor extends StatefulWidget {
  const MetaFieldEditor({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    required this.accentColor,
    this.extraOptions,
  });

  final MetaFieldDef field;
  final String value;
  final ValueChanged<String> onChanged;
  final Color accentColor;
  final List<String>? extraOptions;

  @override
  State<MetaFieldEditor> createState() => _MetaFieldEditorState();
}

class _MetaFieldEditorState extends State<MetaFieldEditor> {
  List<String>? _dynamicOptions;
  late TextEditingController _textCtrl;
  late TextEditingController _numberCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.value);
    _numberCtrl = TextEditingController(text: widget.value);
    if (widget.field.isDynamic) _loadDynamicOptions();
  }

  @override
  void didUpdateWidget(MetaFieldEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _textCtrl.text = widget.value;
      _numberCtrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDynamicOptions() async {
    try {
      final items =
          await ModelCatalogService().list(service: widget.field.serviceType);
      if (mounted) {
        setState(() {
          _dynamicOptions = items.map((m) => m.displayName).toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _dynamicOptions = []);
    }
  }

  List<String> get _allOptions {
    final preset = widget.field.isDynamic
        ? (_dynamicOptions ?? [])
        : (widget.field.options ?? []);
    final extra = widget.extraOptions ?? [];
    final merged = <String>{...preset, ...extra};
    return merged.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.formGap.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.field.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.mutedLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.field.required)
                Padding(
                  padding: EdgeInsets.only(left: Spacing.xxs.w),
                  child: Text(
                    '*',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: Spacing.xs.h),
          if (widget.field.readOnly) _buildReadOnly() else _buildEditable(),
        ],
      ),
    );
  }

  Widget _buildReadOnly() {
    if (widget.value.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedDark,
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        widget.value,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
      ),
    );
  }

  Widget _buildEditable() {
    if (widget.field.isDynamic && _dynamicOptions == null) {
      return Container(
        height: 38.h,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 14.r,
              height: 14.r,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.muted,
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Text(
              '加载中…',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      );
    }

    return switch (widget.field.type) {
      MetaFieldType.select => widget.field.allowCustom
          ? ComboboxSelect(
              options: _allOptions,
              value: widget.value,
              hint: '选择${widget.field.label}',
              accentColor: widget.accentColor,
              onChanged: widget.onChanged,
            )
          : _buildFixedSelect(),
      MetaFieldType.multiSelect => _buildMultiSelect(),
      MetaFieldType.number => _buildNumber(),
      MetaFieldType.text => _buildText(),
    };
  }

  Widget _buildFixedSelect() {
    final options = _allOptions;
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: options.contains(widget.value) ? widget.value : null,
          hint: Text(
            '选择${widget.field.label}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
          ),
          isDense: true,
          dropdownColor: AppColors.surfaceContainer,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (v) {
            if (v != null) widget.onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildMultiSelect() {
    final options = _allOptions;
    final selected = widget.value.isEmpty
        ? <String>{}
        : widget.value.split(',').map((s) => s.trim()).toSet();
    return Wrap(
      spacing: Spacing.xs.w,
      runSpacing: Spacing.xs.h,
      children: options.map((opt) {
        final active = selected.contains(opt);
        return FilterChip(
          selected: active,
          label: Text(opt, style: AppTextStyles.caption),
          backgroundColor: AppColors.surfaceMutedDark,
          selectedColor: widget.accentColor.withValues(alpha: 0.2),
          side: BorderSide(
            color: active ? widget.accentColor : AppColors.border,
          ),
          checkmarkColor: widget.accentColor,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onSelected: (_) {
            final next = Set<String>.from(selected);
            active ? next.remove(opt) : next.add(opt);
            widget.onChanged(next.join(', '));
          },
        );
      }).toList(),
    );
  }

  Widget _buildNumber() {
    return SizedBox(
      height: 38.h,
      child: TextField(
        controller: _numberCtrl,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDecoration(widget.field.hint ?? '输入数字'),
        onChanged: widget.onChanged,
      ),
    );
  }

  Widget _buildText() {
    final isLong =
        widget.field.key == 'prompt' || widget.field.key == 'negativePrompt';
    return TextField(
      controller: _textCtrl,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
      maxLines: isLong ? 3 : 1,
      decoration: _inputDecoration(
        widget.field.hint ?? '输入${widget.field.label}',
      ),
      onChanged: widget.onChanged,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Spacing.md.w,
        vertical: Spacing.sm.h,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        borderSide: BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        borderSide: BorderSide(color: widget.accentColor),
      ),
    );
  }
}
