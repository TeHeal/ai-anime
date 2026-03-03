import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/app_const.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/dashed_border_painter.dart';
import 'package:anime_ui/pub/widgets/gradient_app_bar_bottom.dart';
import 'package:anime_ui/pub/widgets/starfield_background.dart';
import 'package:anime_ui/pub/models/project.dart';
import 'package:anime_ui/pub/providers/storage_provider.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/project_svc.dart';
import 'package:anime_ui/pub/widgets/user_menu.dart';
import 'dialogs.dart';

/// 项目列表页 — 新建、打开、编辑、删除项目，仪表盘入口
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(projectListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          StarfieldBackground(
            particleCount: 60,
            overlayGradient: RadialGradient(
              center: const Alignment(0, -0.5),
              radius: 1.3,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildHeroAppBar(context, ref),
              listAsync.when(
                data: (projects) => _buildCenteredGrid(context, ref, projects),
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      '加载失败: $e',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildHeroAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 180.h,
      pinned: true,
      toolbarHeight: 56.h,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      title: Row(
        children: [
          SizedBox(width: Spacing.lg.w),
          Icon(AppIcons.movieFilter, color: AppColors.primary, size: 24.r),
          SizedBox(width: Spacing.sm.w),
          Text(
            projectsBrand,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: Spacing.md.w),
          child: const UserMenu(),
        ),
      ],
      bottom: const GradientAppBarBottom(),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface.withValues(alpha: 0.95),
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.surface.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.xxl.w * 2,
                56.h + Spacing.xl.h,
                Spacing.xxl.w,
                Spacing.xl.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppColors.onSurface,
                        AppColors.primary.withValues(alpha: 0.9),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      '我的项目',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: Spacing.sm.h),
                  Text(
                    '选择一个项目继续创作，或创建新项目开始你的故事',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 居中网格布局：卡片上下左右均居中，Wrap 自动换行
  Widget _buildCenteredGrid(
    BuildContext context,
    WidgetRef ref,
    List<Project> projects,
  ) {
    const double cardWidth = 240;
    const double cardHeight = 200;
    const double spacing = 24;

    final cards = <Widget>[
      SizedBox(
        width: cardWidth.w,
        height: cardHeight.h,
        child: _NewProjectCard(onTap: () => _createProject(context, ref)),
      ),
      ...List.generate(projects.length, (i) {
        return TweenAnimationBuilder<double>(
          key: ValueKey(projects[i].id),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + i * 100),
          curve: Curves.easeOutBack,
          builder: (_, value, child) => Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 30.h * (1 - value)),
              child: Transform.scale(
                scale: 0.85 + 0.15 * value,
                child: child,
              ),
            ),
          ),
          child: SizedBox(
            width: cardWidth.w,
            height: cardHeight.h,
            child: _ProjectCard(
              project: projects[i],
              onTap: () => _openProject(context, ref, projects[i]),
              onEdit: () => _editProject(context, ref, projects[i]),
              onDelete: () => _deleteProject(context, ref, projects[i]),
            ),
          ),
        );
      }),
    ];

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.xxl.w,
            vertical: Spacing.xl.h,
          ),
          child: Wrap(
            spacing: spacing.w,
            runSpacing: spacing.h,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: cards,
          ),
        ),
      ),
    );
  }

  Future<void> _createProject(BuildContext context, WidgetRef ref) async {
    ref.read(currentProjectProvider.notifier).clear();
    ref.read(lockProvider.notifier).clear();
    await ref.read(storageServiceProvider).clearCurrentProjectId();
    if (context.mounted) context.go(Routes.storyImport);
  }

  Future<void> _openProject(
    BuildContext context, WidgetRef ref, Project project,
  ) async {
    await ref.read(storageServiceProvider).setCurrentProjectId(project.id!);
    await ref.read(currentProjectProvider.notifier).load(project.id!);
    if (context.mounted) context.go(Routes.dashboard);
  }

  Future<void> _editProject(
    BuildContext context, WidgetRef ref, Project project,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => EditProjectDialog(initialName: project.name),
    );
    if (name != null && name.trim().isNotEmpty && context.mounted) {
      try {
        await ProjectService().update(project.id!, name: name.trim());
        ref.invalidate(projectListProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('项目名称已更新')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('更新失败: $e')));
        }
      }
    }
  }

  Future<void> _deleteProject(
    BuildContext context, WidgetRef ref, Project project,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => DeleteConfirmDialog(projectName: project.name),
    );
    if (confirmed == true) {
      try {
        await ProjectService().delete(project.id!);
        ref.invalidate(projectListProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('项目「${project.name}」已删除')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('删除失败: $e')));
        }
      }
    }
  }
}

/// 新建项目卡片 — 动漫风格：霓虹虚线边框 + 脉冲光环 + 悬浮光晕 + 渐变底色
class _NewProjectCard extends StatefulWidget {
  const _NewProjectCard({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_NewProjectCard> createState() => _NewProjectCardState();
}

class _NewProjectCardState extends State<_NewProjectCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, child) {
            final glowVal = _glowAnim.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              transform: _hovered
                  ? (Matrix4.translationValues(0, -6, 0)
                      ..setEntry(0, 0, 1.03)
                      ..setEntry(1, 1, 1.03)
                      ..setEntry(2, 2, 1.03))
                  : Matrix4.identity(),
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: _hovered
                      ? AppColors.primary
                      : Color.lerp(
                          AppColors.mutedDarker,
                          AppColors.primary.withValues(alpha: 0.5),
                          glowVal,
                        )!,
                  borderRadius: RadiusTokens.xxl,
                  dashLength: 10,
                  gapLength: 6,
                  strokeWidth: _hovered ? 2.0 : 1.5,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.3),
                      radius: 1.2,
                      colors: _hovered
                          ? [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.primary.withValues(alpha: 0.03),
                              AppColors.surface.withValues(alpha: 0.15),
                            ]
                          : [
                              AppColors.surface.withValues(alpha: 0.25),
                              AppColors.surface.withValues(alpha: 0.1),
                            ],
                    ),
                    boxShadow: [
                      if (_hovered)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 32.r,
                          spreadRadius: 4.r,
                        ),
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: 0.04 + 0.06 * glowVal,
                        ),
                        blurRadius: 16.r,
                        spreadRadius: 1.r,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 带脉冲光环的加号图标
                        _buildPulsingIcon(glowVal),
                        SizedBox(height: Spacing.md.h),
                        Text(
                          '新建项目',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: _hovered
                                ? AppColors.primary
                                : AppColors.onSurface.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '开始全新创作',
                          style: AppTextStyles.caption.copyWith(
                            color: _hovered
                                ? AppColors.primary.withValues(alpha: 0.6)
                                : AppColors.mutedDark,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPulsingIcon(double glowVal) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 外层呼吸光环
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: (_hovered ? 72 : 64).w,
          height: (_hovered ? 72 : 64).h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1 + 0.15 * glowVal),
              width: 1.5.r,
            ),
          ),
        ),
        // 内层图标容器
        Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: _hovered ? 0.25 : 0.12),
                AppColors.info.withValues(alpha: _hovered ? 0.15 : 0.06),
              ],
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12.r,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            AppIcons.add,
            size: 24.r,
            color: _hovered
                ? AppColors.primary
                : AppColors.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

/// 项目卡片 — 动漫风格：霓虹顶部渐变条 + 悬浮光晕 + 角标装饰 + 彩色阴影
class _ProjectCard extends StatefulWidget {
  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Project project;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovered = false;

  /// 根据项目名生成稳定的主题色
  Color get _themeColor {
    final hash = widget.project.name.hashCode.abs();
    final hues = [
      AppColors.primary,
      AppColors.info,
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
      const Color(0xFFF59E0B),
    ];
    return hues[hash % hues.length];
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
                // 顶部霓虹渐变条
                AnimatedContainer(
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
                ),
                // 内容区
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
                        // 项目名称（居中显示）
                        Center(
                          child: Text(
                            widget.project.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h4.copyWith(
                              color: _hovered
                                  ? AppColors.onSurface
                                  : AppColors.onSurface.withValues(alpha: 0.9),
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

  Widget _buildHeader(Color accent) {
    return Row(
      children: [
        // 项目图标（带渐变背景）
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
        // 菜单按钮
        SizedBox(
          width: 28.w,
          height: 28.h,
          child: PopupMenuButton<String>(
            icon: Icon(
              AppIcons.moreVert,
              color: _hovered
                  ? AppColors.mutedLight
                  : AppColors.mutedDark,
              size: 16.r,
            ),
            padding: EdgeInsets.zero,
            color: AppColors.surface,
            onSelected: (v) {
              if (v == 'edit') widget.onEdit();
              if (v == 'delete') widget.onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(AppIcons.editOutline, size: 16.r, color: AppColors.muted),
                    SizedBox(width: Spacing.sm.w),
                    Text('编辑名称',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.mutedLight)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(AppIcons.delete, size: 16.r, color: AppColors.error),
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
        // 悬浮箭头指示
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
