import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/form_field_helpers.dart';
import 'package:anime_ui/pub/widgets/option_chips.dart';
import 'package:anime_ui/pub/services/file_svc.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;

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
  bool _isUploading = false;

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

  Future<void> _handleUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final Uint8List? bytes = file.bytes;
    if (bytes == null) return;

    setState(() => _isUploading = true);
    try {
      final url = await FileService().upload(
        bytes,
        file.name,
        category: 'character_reference',
      );
      setState(() => _uploadedImageUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('上传失败: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceMutedDarker,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520.w, maxHeight: 540.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  Spacing.xl.w, Spacing.lg.h, Spacing.xl.w, Spacing.sm.h,
                ),
                child: _step == 0 ? _buildStep1() : _buildStep2(),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Spacing.xl.w, Spacing.lg.h, Spacing.lg.w, 0),
      child: Row(
        children: [
          Text(
            '新建角色',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(AppIcons.close, color: AppColors.muted),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Spacing.xl.w, Spacing.md.h, Spacing.xl.w, 0),
      child: Row(
        children: [
          _stepDot(0, '基本信息'),
          _stepLine(),
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

  Widget _stepLine() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
        child: Divider(color: AppColors.border, thickness: 1),
      ),
    );
  }

  // ─── Step 1：基本信息 ────────────────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DarkFieldLabel('角色名称', required: true),
        SizedBox(height: Spacing.xs.h),
        TextField(
          controller: _nameCtrl,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          decoration: darkInputDecoration('请输入角色名称'),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: Spacing.lg.h),
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
        SizedBox(height: Spacing.lg.h),
        const DarkFieldLabel('重要程度'),
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
        const DarkFieldLabel('简要描述', hint: '可选'),
        SizedBox(height: Spacing.xs.h),
        TextField(
          controller: _descriptionCtrl,
          maxLines: 2,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          decoration: darkInputDecoration('一句话描述这个角色（可选）'),
        ),
      ],
    );
  }

  // ─── Step 2：外貌描述 ────────────────────────────────

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadArea(),
            SizedBox(width: Spacing.lg.w),
            Expanded(child: _buildAppearanceField()),
          ],
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

  Widget _buildUploadArea() {
    if (_uploadedImageUrl != null) {
      return Stack(
        children: [
          Container(
            width: 160.w,
            height: 200.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              image: DecorationImage(
                image: NetworkImage(resolveFileUrl(_uploadedImageUrl!)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 4.h,
            right: 4.w,
            child: GestureDetector(
              onTap: () => setState(() => _uploadedImageUrl = null),
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                ),
                child: Icon(AppIcons.close, size: 14.r, color: Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _isUploading ? null : _handleUpload,
      child: Container(
        width: 160.w,
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          border: Border.all(color: AppColors.border),
        ),
        child: _isUploading
            ? Center(
                child: SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.image, size: 32.r, color: AppColors.muted),
                    SizedBox(height: Spacing.sm.h),
                    Text(
                      '上传参考图',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedDark,
                      ),
                    ),
                    Text(
                      '（可选）',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.mutedDarker,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAppearanceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DarkFieldLabel('外貌描述', hint: '可选'),
        SizedBox(height: Spacing.xs.h),
        TextField(
          controller: _appearanceCtrl,
          maxLines: 8,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          decoration: darkInputDecoration('描述角色的外观特征，如性别、年龄、发型、服装等'),
        ),
      ],
    );
  }

  // ─── Footer ──────────────────────────────────────────

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl.w, Spacing.sm.h, Spacing.xl.w, Spacing.lg.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_step > 0)
            TextButton(
              onPressed: () => setState(() => _step = 0),
              child: const Text('← 上一步'),
            ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
            ),
          ),
          SizedBox(width: Spacing.md.w),
          if (_step == 0)
            FilledButton(
              onPressed: _canProceed ? () => setState(() => _step = 1) : null,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('下一步 →'),
            )
          else ...[
            OutlinedButton(
              onPressed: _handleCreate,
              child: const Text('跳过，直接创建'),
            ),
            SizedBox(width: Spacing.sm.w),
            FilledButton(
              onPressed: _handleCreate,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('创建角色'),
            ),
          ],
        ],
      ),
    );
  }
}

