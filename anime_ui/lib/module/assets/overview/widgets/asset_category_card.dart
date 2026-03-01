import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 资产分类卡片
class AssetCategoryCard extends StatefulWidget {
  const AssetCategoryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.confirmed,
    required this.total,
    this.pending = 0,
    this.nextAction,
    this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int confirmed;
  final int total;
  final int pending;
  final String? nextAction;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  State<AssetCategoryCard> createState() => _AssetCategoryCardState();
}

class _AssetCategoryCardState extends State<AssetCategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final allDone = widget.total > 0 && widget.confirmed == widget.total;
    final pending = widget.total - widget.confirmed;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          padding: EdgeInsets.all(Spacing.lg.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _hovered
                  ? [
                      widget.iconColor.withValues(alpha: 0.08),
                      widget.iconColor.withValues(alpha: 0.03),
                    ]
                  : [
                      AppColors.surfaceContainerHigh,
                      AppColors.surfaceContainerHighest,
                    ],
            ),
            borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
            border: Border.all(
              color: _hovered
                  ? widget.iconColor.withValues(alpha: 0.4)
                  : widget.iconColor.withValues(alpha: 0.1),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.iconColor.withValues(alpha: 0.15),
                      blurRadius: 16.r,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Spacing.sm.r),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                    ),
                    child: Icon(widget.icon, size: 16.r, color: widget.iconColor),
                  ),
                  SizedBox(width: Spacing.md.w),
                  Text(
                    widget.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _hovered
                          ? widget.iconColor
                          : AppColors.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (!widget.isLoading)
                    Text(
                      '${widget.confirmed}/${widget.total}',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                ],
              ),
              SizedBox(height: Spacing.md.h),
              if (!widget.isLoading && widget.total > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                  child: LinearProgressIndicator(
                    value: widget.confirmed / widget.total,
                    minHeight: 3.h,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    color: allDone ? AppColors.success : widget.iconColor,
                  ),
                ),
              if (widget.isLoading)
                SizedBox(
                  height: 16.r,
                  width: 16.r,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              SizedBox(height: Spacing.md.h),
              Row(
                children: [
                  Expanded(
                    child: widget.nextAction != null
                        ? Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '下一步: ',
                                  style: AppTextStyles.tiny.copyWith(
                                    color: AppColors.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: widget.nextAction,
                                  style: AppTextStyles.tiny.copyWith(
                                    color: widget.iconColor.withValues(
                                      alpha: 0.9,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            allDone
                                ? '✓ 全部就绪'
                                : widget.total == 0
                                ? '暂无数据'
                                : widget.confirmed == 0 && widget.pending > 0
                                ? '已识别 ${widget.pending} 个，待确认'
                                : '$pending 个待处理',
                            style: AppTextStyles.tiny.copyWith(
                              color: allDone
                                  ? AppColors.success
                                  : pending > 0
                                  ? AppColors.warning.withValues(alpha: 0.9)
                                  : AppColors.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                  ),
                  if (widget.onTap != null)
                    Text(
                      '前往 →',
                      style: AppTextStyles.tiny.copyWith(
                        color: _hovered
                            ? widget.iconColor
                            : AppColors.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
