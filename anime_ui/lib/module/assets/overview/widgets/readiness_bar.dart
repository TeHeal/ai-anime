import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/module/assets/overview/providers/overview.dart';

/// 资产就绪度进度条（可点击刷新，悬停有反馈，进度条数值平滑过渡）
class ReadinessBar extends StatefulWidget {
  const ReadinessBar({
    super.key,
    required this.data,
    this.onRefresh,
  });

  final AssetOverviewData data;
  final VoidCallback? onRefresh;

  @override
  State<ReadinessBar> createState() => _ReadinessBarState();
}

class _ReadinessBarState extends State<ReadinessBar> {
  bool _hovered = false;
  double _prevProgress = 0;

  @override
  void didUpdateWidget(ReadinessBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.data.isLoading &&
        oldWidget.data.readinessPct != widget.data.readinessPct) {
      _prevProgress = oldWidget.data.readinessPct / 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final targetProgress = data.isLoading ? 0.0 : data.readinessPct / 100;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onRefresh != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onRefresh,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.mid.w,
            vertical: Spacing.lg.h,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered && widget.onRefresh != null
                  ? [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.primary.withValues(alpha: 0.05),
                    ]
                  : [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.primary.withValues(alpha: 0.03),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
            border: Border.all(
              color: _hovered && widget.onRefresh != null
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '资产就绪度',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  SizedBox(width: Spacing.md.w),
                  if (!data.isLoading)
                    Text(
                      '${data.totalConfirmed} / ${data.totalAssets}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  const Spacer(),
                  if (!data.isLoading)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Text(
                        '${data.readinessPct}%',
                        key: ValueKey(data.readinessPct),
                        style: AppTextStyles.displayLarge.copyWith(
                          color: data.readinessPct >= 100
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: Spacing.md.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                child: data.isLoading
                    ? LinearProgressIndicator(
                        value: null,
                        minHeight: 6.h,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        color: AppColors.primary,
                      )
                    : TweenAnimationBuilder<double>(
                        tween: Tween(begin: _prevProgress, end: targetProgress),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        onEnd: () =>
                            setState(() => _prevProgress = targetProgress),
                        builder: (context, value, _) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final w = constraints.maxWidth *
                                  value.clamp(0.0, 1.0);
                              return SizedBox(
                                height: 6.h,
                                child: Stack(
                                  clipBehavior: Clip.hardEdge,
                                  children: [
                                    Container(
                                      color:
                                          AppColors.surfaceContainerHighest,
                                    ),
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      width: w,
                                      child: Container(
                                        color: data.readinessPct >= 100
                                            ? AppColors.success
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              SizedBox(height: Spacing.md.h),
              Row(
                children: [
                  _chip(
                    AppIcons.person,
                    '角色',
                    data.charConfirmed,
                    data.charTotal,
                    AppColors.categoryCharacter,
                  ),
                  SizedBox(width: Spacing.lg.w),
                  _chip(
                    AppIcons.landscape,
                    '场景',
                    data.locConfirmed,
                    data.locTotal,
                    AppColors.categoryLocation,
                  ),
                  SizedBox(width: Spacing.lg.w),
                  _chip(
                    AppIcons.category,
                    '道具',
                    data.propConfirmed,
                    data.propTotal,
                    AppColors.categoryProp,
                  ),
                  SizedBox(width: Spacing.lg.w),
                  _chip(
                    AppIcons.mic,
                    '音色',
                    data.voiceConfigured,
                    data.voiceNeeded,
                    AppColors.categoryVoice,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, int done, int total, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.r, color: color.withValues(alpha: 0.7)),
        SizedBox(width: Spacing.xs.w),
        Text(
          '$label ',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.55),
          ),
        ),
        Text(
          '$done',
          style: AppTextStyles.caption.copyWith(
            color: done == total && total > 0 ? AppColors.success : color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '/$total',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
