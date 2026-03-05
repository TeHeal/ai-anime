import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 骨架屏卡片：带脉冲动画的加载占位
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({
    super.key,
    required this.accentColor,
    this.delay = 0,
  });

  final Color accentColor;
  final int delay;

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final opacity = 0.04 + _ctrl.value * 0.08;
        return Container(
          decoration: BoxDecoration(
            color: widget.accentColor.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        widget.accentColor.withValues(alpha: opacity * 0.5),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(RadiusTokens.lg.r),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMutedDark,
                          borderRadius:
                              BorderRadius.circular(RadiusTokens.xs.r),
                        ),
                      ),
                      SizedBox(height: Spacing.sm.h),
                      Container(
                        height: 8.h,
                        width: 50.w,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMutedDark
                              .withValues(alpha: 0.5),
                          borderRadius:
                              BorderRadius.circular(RadiusTokens.xs.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
