import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/project.dart';

/// 项目卡片 — 霓虹顶部渐变条 + 悬浮光晕 + 角标装饰 + 彩色阴影
class ProjectCard extends StatefulWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onMembers,
  });

  final Project project;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMembers;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  /// 根据项目名哈希选取一个语义色作为卡片主题色
  static const _themeHues = [
    AppColors.primary,
    AppColors.info,
    AppColors.secondary,
    AppColors.categoryStyle,
    AppColors.categoryVoice,
    AppColors.tagAmber,
  ];

  Color get _themeColor {
    final hash = widget.project.name.hashCode.abs();
    return _themeHues[hash % _themeHues.length];
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${dt.month}月${dt.day}日';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _themeColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          transform: _hovered
              ? (Matrix4.translationValues(0, -6, 0)
                  ..setEntry(0, 0, 1.03)
                  ..setEntry(1, 1, 1.03)
                  ..setEntry(2, 2, 1.03))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _hovered
                  ? [
                      AppColors.surfaceContainerHigh,
                      accent.withValues(alpha: 0.06),
                      AppColors.surfaceContainerHighest,
                    ]
                  : [
                      AppColors.surfaceContainerHigh,
                      AppColors.surfaceContainerHighest,
                    ],
            ),
            border: Border.all(
              color: _hovered
                  ? accent.withValues(alpha: 0.5)
                  : accent.withValues(alpha: 0.1),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: _hovered ? 0.25 : 0.08),
                blurRadius: _hovered ? 28.r : 8.r,
                spreadRadius: _hovered ? 3.r : 0,
              ),
              if (_hovered)
                BoxShadow(
                  color: accent.withValues(alpha: 0.1),
                  blurRadius: 48.r,
                  spreadRadius: -4.r,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNeonStripe(accent),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      Spacing.lg.w,
                      Spacing.md.h,
                      Spacing.lg.w,
                      Spacing.md.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(accent),
                        const Spacer(),
                        Center(
                          child: Text(
                            widget.project.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h4.copyWith(
                              color: _hovered
                                  ? AppColors.onSurface
                                  : AppColors.onSurface
                                      .withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _buildFooter(accent),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 顶部霓虹渐变条
  Widget _buildNeonStripe(Color accent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      height: _hovered ? 4.h : 3.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent,
            accent.withValues(alpha: 0.8),
            AppColors.info,
          ],
        ),
        boxShadow: _hovered
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildHeader(Color accent) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.25),
                accent.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          ),
          child: Icon(
            AppIcons.movieFilter,
            color: accent.withValues(alpha: 0.9),
            size: 16.r,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 28.w,
          height: 28.h,
          child: PopupMenuButton<String>(
            icon: Icon(
              AppIcons.moreVert,
              color: _hovered ? AppColors.mutedLight : AppColors.mutedDark,
              size: 16.r,
            ),
            padding: EdgeInsets.zero,
            color: AppColors.surface,
            onSelected: (v) {
              if (v == 'edit') widget.onEdit();
              if (v == 'members') widget.onMembers?.call();
              if (v == 'delete') widget.onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(AppIcons.editOutline,
                        size: 16.r, color: AppColors.muted),
                    SizedBox(width: Spacing.sm.w),
                    Text('编辑名称',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.mutedLight)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'members',
                child: Row(
                  children: [
                    Icon(AppIcons.people,
                        size: 16.r, color: AppColors.muted),
                    SizedBox(width: Spacing.sm.w),
                    Text('成员管理',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.mutedLight)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(AppIcons.delete,
                        size: 16.r, color: AppColors.error),
                    SizedBox(width: Spacing.sm.w),
                    Text('删除',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(Color accent) {
    return Row(
      children: [
        Icon(
          AppIcons.inProgress,
          size: 11.r,
          color: AppColors.mutedDarker,
        ),
        SizedBox(width: 4.w),
        Text(
          _formatDate(widget.project.updatedAt),
          style: AppTextStyles.tiny.copyWith(
            color: AppColors.mutedDark,
            fontSize: 10.sp,
          ),
        ),
        const Spacer(),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _hovered ? 1.0 : 0.4,
          child: Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: _hovered ? 0.15 : 0.05),
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            ),
            child: Icon(
              AppIcons.chevronRight,
              size: 12.r,
              color: _hovered ? accent : AppColors.mutedDarker,
            ),
          ),
        ),
      ],
    );
  }
}
