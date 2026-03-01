import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/app_const.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/dashed_border_painter.dart';
import 'package:anime_ui/pub/widgets/glow_card.dart';
import 'package:anime_ui/pub/widgets/gradient_app_bar_bottom.dart';
import 'package:anime_ui/pub/widgets/pulse.dart';
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
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.xxl.w,
                  vertical: Spacing.xl.h,
                ),
                sliver: listAsync.when(
                  data: (projects) => _buildGrid(context, ref, projects),
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
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

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    List<Project> projects,
  ) {
    final totalItems = projects.length + 1;

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            Breakpoints.columnCountForWidth(
              constraints.crossAxisExtent, maxCols: 4,
            );

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: Spacing.mid.h,
            crossAxisSpacing: Spacing.mid.w,
            childAspectRatio: 1.05,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              if (i == 0) {
                return _NewProjectCard(
                  onTap: () => _createProject(context, ref),
                );
              }
              final index = i - 1;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 350 + index * 80),
                curve: Curves.easeOutCubic,
                builder: (_, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20.h * (1 - value)),
                    child: child,
                  ),
                ),
                child: _ProjectCard(
                  project: projects[index],
                  onTap: () => _openProject(context, ref, projects[index]),
                  onEdit: () => _editProject(context, ref, projects[index]),
                  onDelete: () =>
                      _deleteProject(context, ref, projects[index]),
                ),
              );
            },
            childCount: totalItems,
          ),
        );
      },
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

/// 新建项目卡片 — 渐变虚线边框 + 脉冲动画 + 悬浮发光
class _NewProjectCard extends StatefulWidget {
  const _NewProjectCard({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_NewProjectCard> createState() => _NewProjectCardState();
}

class _NewProjectCardState extends State<_NewProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: _hovered ? AppColors.primary : AppColors.mutedDarker,
              borderRadius: RadiusTokens.xxxl,
              dashLength: 8,
              gapLength: 5,
              strokeWidth: _hovered ? 2.0 : 1.5,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(RadiusTokens.xxxl.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _hovered
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : AppColors.surface.withValues(alpha: 0.2),
                    _hovered
                        ? AppColors.primary.withValues(alpha: 0.03)
                        : AppColors.surface.withValues(alpha: 0.15),
                  ],
                ),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 24.r,
                          spreadRadius: 2.r,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PulseWidget(
                      pulseColor: AppColors.primary,
                      ringPadding: 16.r,
                      child: Container(
                        width: 52.w,
                        height: 52.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.info.withValues(alpha: 0.08),
                            ],
                          ),
                        ),
                        child: Icon(
                          AppIcons.add,
                          size: 28.r,
                          color: _hovered
                              ? AppColors.primary
                              : AppColors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    SizedBox(height: Spacing.lg.h),
                    Text(
                      '新建项目',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: _hovered
                            ? AppColors.primary
                            : AppColors.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Spacing.xs.h),
                    Text(
                      '开始全新创作',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 项目卡片 — GlowCard 包裹，渐变边框 + 状态指示 + 日期显示
class _ProjectCard extends StatelessWidget {
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

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return '刚刚更新';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';
    return '${dt.month}月${dt.day}日';
  }

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Spacer(),
          Center(
            child: Text(
              project.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const Spacer(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(Spacing.sm.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.info.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
          ),
          child: Icon(
            AppIcons.movieFilter,
            color: AppColors.primary.withValues(alpha: 0.85),
            size: 20.r,
          ),
        ),
        const Spacer(),
        PopupMenuButton<String>(
          icon: Icon(AppIcons.moreVert, color: AppColors.mutedDark, size: 20.r),
          color: AppColors.surface,
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(AppIcons.editOutline, size: 18.r, color: AppColors.muted),
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
                  Icon(AppIcons.delete, size: 18.r, color: AppColors.error),
                  SizedBox(width: Spacing.sm.w),
                  Text('删除',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(AppIcons.inProgress, size: 12.r, color: AppColors.mutedDarker),
        SizedBox(width: Spacing.xs.w),
        Text(
          _formatDate(project.updatedAt),
          style: AppTextStyles.caption.copyWith(color: AppColors.mutedDark),
        ),
        const Spacer(),
        Icon(AppIcons.chevronRight, size: 14.r, color: AppColors.mutedDarker),
      ],
    );
  }
}
