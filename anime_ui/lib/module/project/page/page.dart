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
import 'package:anime_ui/main.dart';
import 'package:anime_ui/pub/models/project.dart';
import 'package:anime_ui/pub/providers/lock_provider.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/project_svc.dart';
import 'package:anime_ui/pub/widgets/user_menu.dart';

/// 项目列表页 — 新建、打开、编辑、删除项目，仪表盘入口
class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(projectListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leadingWidth: 280.w,
        leading: Padding(
          padding: EdgeInsets.only(left: Spacing.lg.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.movieFilter, color: AppColors.primary, size: 24.r),
              SizedBox(width: Spacing.sm.w),
              Text(
                projectsBrand,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          '我的项目',
          style: AppTextStyles.h2.copyWith(color: AppColors.onSurface),
        ),
        centerTitle: true,
        bottom: const GradientAppBarBottom(),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: Spacing.md.w),
            child: const UserMenu(),
          ),
        ],
      ),
      body: Stack(
        children: [
          StarfieldBackground(
            particleCount: 55,
            overlayGradient: RadialGradient(
              center: const Alignment(0, -0.3),
              radius: 1.2,
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
          listAsync.when(
            data: (projects) {
              final totalItems = projects.length + 1;
              final cards = List<Widget>.generate(totalItems, (i) {
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
                      offset: Offset(0, 16.h * (1 - value)),
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
              });

              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(Spacing.xxl.r),
                  child: Wrap(
                    spacing: Spacing.mid.w,
                    runSpacing: Spacing.mid.h,
                    alignment: WrapAlignment.center,
                    children: cards
                        .map(
                          (card) => SizedBox(
                            width: 280.w,
                            height: 267.h,
                            child: card,
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                '加载失败: $e',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createProject(BuildContext context, WidgetRef ref) async {
    ref.read(currentProjectProvider.notifier).clear();
    ref.read(lockProvider.notifier).clear();
    await storageService.clearCurrentProjectId();
    if (context.mounted) context.go(Routes.storyImport);
  }

  Future<void> _openProject(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    storageService.setCurrentProjectId(project.id!);
    await ref.read(currentProjectProvider.notifier).load(project.id!);
    if (context.mounted) context.go(Routes.dashboard);
  }

  Future<void> _editProject(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => _EditProjectDialog(initialName: project.name),
    );
    if (name != null && name.trim().isNotEmpty && context.mounted) {
      try {
        await ProjectService().update(project.id!, name: name.trim());
        ref.invalidate(projectListProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('项目名称已更新')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('更新失败: $e')));
        }
      }
    }
  }

  Future<void> _deleteProject(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _DeleteConfirmDialog(projectName: project.name),
    );
    if (confirmed == true) {
      try {
        await ProjectService().delete(project.id!);
        ref.invalidate(projectListProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('项目「${project.name}」已删除')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
        }
      }
    }
  }
}

/// 新建项目卡片 — 虚线边框 + 脉冲动画
class _NewProjectCard extends StatelessWidget {
  const _NewProjectCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: AppColors.mutedDarker,
            borderRadius: RadiusTokens.xxxl,
            dashLength: 8,
            gapLength: 5,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(RadiusTokens.xxxl.r),
              color: AppColors.surface.withValues(alpha: 0.3),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PulseWidget(
                    pulseColor: AppColors.primary,
                    ringPadding: 16.r,
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        AppIcons.add,
                        size: 28.r,
                        color: AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  SizedBox(height: Spacing.lg.h),
                  Text(
                    '新建项目',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.7),
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
}

/// 项目卡片 — GlowCard 包裹
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
    return '${dt.year}/${dt.month}/${dt.day} 更新';
  }

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Spacing.sm.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                ),
                child: Icon(
                  AppIcons.movieFilter,
                  color: AppColors.primary.withValues(alpha: 0.7),
                  size: 20.r,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Icon(
                  AppIcons.moreVert,
                  color: AppColors.mutedDark,
                  size: 20.r,
                ),
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
                        Icon(
                          AppIcons.editOutline,
                          size: 18.r,
                          color: AppColors.muted,
                        ),
                        SizedBox(width: Spacing.sm.w),
                        Text(
                          '编辑名称',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.mutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.delete,
                          size: 18.r,
                          color: AppColors.error,
                        ),
                        SizedBox(width: Spacing.sm.w),
                        Text(
                          '删除',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: Text(
              project.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.h4.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Text(
            _formatDate(project.updatedAt),
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// 编辑项目名称对话框
class _EditProjectDialog extends StatefulWidget {
  const _EditProjectDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<_EditProjectDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initialName.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        '编辑项目名称',
        style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: '输入项目名称',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mutedDark,
          ),
          filled: true,
          fillColor: AppColors.surfaceMutedDarker,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        onSubmitted: (v) {
          if (v.trim().isNotEmpty) Navigator.pop(context, v.trim());
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '取消',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
          ),
        ),
        FilledButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) Navigator.pop(context, name);
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

/// 删除确认对话框（需输入确认文字）
class _DeleteConfirmDialog extends StatefulWidget {
  const _DeleteConfirmDialog({required this.projectName});

  final String projectName;

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  final _controller = TextEditingController();
  static const _confirmText = '确认';

  bool get _canConfirm => _controller.text.trim() == _confirmText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        '确认删除',
        style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '确定要删除项目「${widget.projectName}」吗？此操作不可撤销。',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedLight,
              height: 1.5,
            ),
          ),
          SizedBox(height: Spacing.mid.h),
          Text(
            '请输入「$_confirmText」以确认删除：',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
          ),
          SizedBox(height: Spacing.sm.h),
          TextField(
            controller: _controller,
            autofocus: true,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: _confirmText,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedDarker,
              ),
              filled: true,
              fillColor: AppColors.surfaceMutedDarker,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            '取消',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
          ),
        ),
        FilledButton(
          onPressed: _canConfirm ? () => Navigator.pop(context, true) : null,
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('删除'),
        ),
      ],
    );
  }
}
