import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/app_const.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/gradient_app_bar_bottom.dart';
import 'package:anime_ui/pub/widgets/starfield_background.dart';
import 'package:anime_ui/pub/models/project.dart';
import 'package:anime_ui/pub/providers/storage_provider.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/project_svc.dart';
import 'package:anime_ui/pub/widgets/user_menu.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/module/project/widgets/new_project_card.dart';
import 'package:anime_ui/module/project/dialogs/project_members_dialog.dart';
import 'package:anime_ui/module/project/widgets/project_card.dart';
import 'package:anime_ui/pub/widgets/app_dialog.dart';
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
                        color: AppColors.onPrimary,
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
        child: NewProjectCard(onTap: () => _createProject(context, ref)),
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
            child: ProjectCard(
              project: projects[i],
              onTap: () => _openProject(context, ref, projects[i]),
              onEdit: () => _editProject(context, ref, projects[i]),
              onDelete: () => _deleteProject(context, ref, projects[i]),
              onMembers: () => _manageMembers(context, projects[i]),
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
          showToast(context, '项目名称已更新');
        }
      } catch (e) {
        if (context.mounted) {
          showToast(context, '更新失败: $e', isError: true);
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
          showToast(context, '项目「${project.name}」已删除');
        }
      } catch (e) {
        if (context.mounted) {
          showToast(context, '删除失败: $e', isError: true);
        }
      }
    }
  }

  void _manageMembers(BuildContext context, Project project) {
    AppDialog.show(
      context,
      builder: (_, close) => ProjectMembersDialog(
        projectId: project.id!,
        onClose: close,
      ),
    );
  }
}
