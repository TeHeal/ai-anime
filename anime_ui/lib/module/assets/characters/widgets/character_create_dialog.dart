import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/asset_form_shell.dart';
import 'package:anime_ui/pub/widgets/asset_input_field.dart';
import 'package:anime_ui/pub/widgets/asset_section_label.dart';
import 'package:anime_ui/pub/widgets/asset_upload_area.dart';
import 'package:anime_ui/pub/widgets/option_chips.dart';

/// 两步骤角色创建对话框
///
/// Step 0：基本信息（名称、类型、重要度、简述）
/// Step 1：外貌描述（上传参考图 + 外貌文本）
class CharacterCreateDialog extends StatefulWidget {
  const CharacterCreateDialog({
    super.key,
    required this.onCreated,
  });

  final void Function(Map<String, dynamic> data) onCreated;

  @override
  State<CharacterCreateDialog> createState() => _CharacterCreateDialogState();
}

class _CharacterCreateDialogState extends State<CharacterCreateDialog> {
  int _step = 0;

  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _appearanceCtrl = TextEditingController();

  String _roleType = 'human';
  String _importance = 'main';

  String? _uploadedImageUrl;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _appearanceCtrl.dispose();
    super.dispose();
  }

  bool get _canProceed => _nameCtrl.text.trim().isNotEmpty;

  void _handleCreate() {
    widget.onCreated({
      'name': _nameCtrl.text.trim(),
      'roleType': _roleType,
      'importance': _importance,
      'description': _descriptionCtrl.text.trim(),
      'appearance': _appearanceCtrl.text.trim(),
      if (_uploadedImageUrl != null) 'imageUrl': _uploadedImageUrl,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AssetFormShell(
      title: '新建角色',
      icon: AppIcons.person,
      accent: AppColors.primary,
      primaryLabel: _step == 0 ? '下一步 →' : '创建角色',
      onPrimary: _step == 0
          ? (_canProceed ? () => setState(() => _step = 1) : null)
          : _handleCreate,
      maxWidth: 520.w,
      maxHeight: 560.h,
      secondaryActions: [
        if (_step > 0)
          TextButton(
            onPressed: () => setState(() => _step = 0),
            child: const Text('← 上一步'),
          ),
        if (_step == 1) ...[
          const Spacer(),
          OutlinedButton(
            onPressed: _handleCreate,
            child: const Text('跳过，直接创建'),
          ),
          SizedBox(width: Spacing.sm.w),
        ],
      ],
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.xl.w,
                vertical: Spacing.lg.h,
              ),
              child: _step == 0 ? _buildStep0() : _buildStep1(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          Spacing.xl.w, Spacing.md.h, Spacing.xl.w, 0),
      child: Row(
        children: [
          _stepDot(0, '基本信息'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
              child: const Divider(color: AppColors.border, thickness: 1),
            ),
          ),
          _stepDot(1, '外貌描述'),
        ],
      ),
    );
  }

  Widget _stepDot(int index, String label) {
    final isActive = _step == index;
    final isDone = _step > index;
    final color = isDone
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.border;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22.r,
          height: 22.r,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Center(
            child: isDone
                ? Icon(AppIcons.check, size: 12.r, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: AppTextStyles.tiny.copyWith(
                      color: isActive ? Colors.white : AppColors.mutedDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        SizedBox(width: Spacing.xs.w),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isActive ? AppColors.onSurface : AppColors.mutedDark,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ─── Step 0：基本信息 ────────────────────────────────

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AssetInputField(
          label: '角色名称',
          controller: _nameCtrl,
          hint: '请输入角色名称',
          required: true,
          onChanged: (_) => setState(() {}),
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
            'main': '主要角色',
            'support': '次要角色',
            'functional': '功能角色',
            'extra': '群演',
          },
          selected: _importance,
          onSelected: (v) => setState(() => _importance = v),
        ),
        SizedBox(height: Spacing.lg.h),
        AssetInputField(
          label: '简要描述',
          controller: _descriptionCtrl,
          hint: '一句话描述这个角色（可选）',
          maxLines: 2,
          labelHint: '可选',
        ),
      ],
    );
  }

  // ─── Step 1：外貌描述 ────────────────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AssetSectionLabel('参考图', accent: AppColors.primary, hint: '可选'),
        SizedBox(height: Spacing.sm.h),
        AssetUploadArea(
          fileType: UploadFileType.image,
          accentColor: AppColors.primary,
          currentUrl: _uploadedImageUrl,
          height: 160.h,
          uploadCategory: 'character_reference',
          onUploaded: (url) => setState(() => _uploadedImageUrl = url),
        ),
        SizedBox(height: Spacing.lg.h),
        AssetInputField(
          label: '外貌描述',
          controller: _appearanceCtrl,
          hint: '描述角色的外观特征，如性别、年龄、发型、服装等',
          maxLines: 8,
          labelHint: '可选',
        ),
        SizedBox(height: Spacing.md.h),
        Container(
          padding: EdgeInsets.all(Spacing.sm.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          ),
          child: Row(
            children: [
              Icon(AppIcons.info, size: 16.r, color: AppColors.primary),
              SizedBox(width: Spacing.sm.w),
              Expanded(
                child: Text(
                  '以上均为可选项，留空后续可在详情面板中补充或使用 AI 补全',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedDark,
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
