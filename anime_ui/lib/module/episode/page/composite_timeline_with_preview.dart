import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'composite_timeline_page.dart';
import 'timeline_preview.dart';

/// 时间线 Tab 组合页：上部可视化预览 + 下部按集列表
class CompositeTimelineWithPreview extends StatefulWidget {
  const CompositeTimelineWithPreview({super.key});

  @override
  State<CompositeTimelineWithPreview> createState() =>
      _CompositeTimelineWithPreviewState();
}

class _CompositeTimelineWithPreviewState
    extends State<CompositeTimelineWithPreview> {
  bool _showPreview = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 切换栏
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.xl.w,
            vertical: Spacing.sm.h,
          ),
          child: Row(
            children: [
              _ViewToggle(
                label: '可视化预览',
                isActive: _showPreview,
                onTap: () => setState(() => _showPreview = true),
              ),
              SizedBox(width: Spacing.sm.w),
              _ViewToggle(
                label: '按集列表',
                isActive: !_showPreview,
                onTap: () => setState(() => _showPreview = false),
              ),
            ],
          ),
        ),
        // 内容区
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showPreview
                ? const TimelinePreview(key: ValueKey('preview'))
                : const CompositeTimelinePage(key: ValueKey('list')),
          ),
        ),
      ],
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.lg.w,
            vertical: Spacing.sm.h,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: isActive ? AppColors.primary : AppColors.mutedDark,
            ),
          ),
        ),
      ),
    );
  }
}
