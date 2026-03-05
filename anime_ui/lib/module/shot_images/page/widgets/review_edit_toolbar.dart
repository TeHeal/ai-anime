import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/shot.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 镜图审核：提示词编辑工具栏
class ReviewEditToolbar extends StatefulWidget {
  const ReviewEditToolbar({
    super.key,
    required this.shot,
    required this.onToast,
    this.onPromptChanged,
  });

  final StoryboardShot shot;
  final void Function(String) onToast;
  final ValueChanged<String>? onPromptChanged;

  @override
  State<ReviewEditToolbar> createState() => _ReviewEditToolbarState();
}

class _ReviewEditToolbarState extends State<ReviewEditToolbar> {
  late final TextEditingController _ctrl;
  String _original = '';

  @override
  void initState() {
    super.initState();
    _original = widget.shot.prompt;
    _ctrl = TextEditingController(text: _original);
  }

  @override
  void didUpdateWidget(covariant ReviewEditToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shot.id != widget.shot.id) {
      _original = widget.shot.prompt;
      _ctrl.text = _original;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isDirty => _ctrl.text != _original;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '提示词编辑',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: Spacing.md.h),
          TextField(
            controller: _ctrl,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: '编辑提示词…',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedDarker,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              contentPadding: EdgeInsets.all(Spacing.md.r),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: Spacing.md.h),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () {
                  final text = _ctrl.text.trim();
                  if (text.isEmpty) {
                    widget.onToast('提示词不能为空');
                    return;
                  }
                  widget.onPromptChanged?.call(text);
                  widget.onToast('重新生成功能开发中');
                },
                icon: Icon(AppIcons.magicStick, size: 14.r),
                label: Text('生成', style: AppTextStyles.caption),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.md.w,
                    vertical: Spacing.sm.h,
                  ),
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              FilledButton.icon(
                onPressed: _isDirty
                    ? () {
                        _ctrl.text = _original;
                        setState(() {});
                        widget.onToast('已恢复原始提示词');
                      }
                    : null,
                icon: Icon(AppIcons.refresh, size: 14.r),
                label: Text('恢复原始', style: AppTextStyles.caption),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.md.w,
                    vertical: Spacing.sm.h,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
