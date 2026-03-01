import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/empty.dart';

import 'providers/task_center.dart';
import 'widgets/task_card.dart';

/// 任务中心页 — 展示活跃/近期任务，按类型分组，WebSocket 实时更新
class TaskCenterPage extends ConsumerWidget {
  const TaskCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(taskCenterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainer,
        title: Row(
          children: [
            Icon(AppIcons.list, size: 20.r, color: AppColors.primary),
            SizedBox(width: Spacing.sm.w),
            Text(
              '任务中心',
              style: AppTextStyles.h3.copyWith(color: AppColors.onSurface),
            ),
            SizedBox(width: Spacing.md.w),
            _CountBadge(label: '运行中', count: st.runningCount, color: AppColors.primary),
            SizedBox(width: Spacing.sm.w),
            _CountBadge(label: '排队', count: st.pendingCount, color: AppColors.warning),
          ],
        ),
        actions: [
          // 类型筛选
          _FilterChipRow(
            selected: st.typeFilter,
            onChanged: (v) => ref.read(taskCenterProvider.notifier).setTypeFilter(v),
          ),
          SizedBox(width: Spacing.sm.w),
          // 状态筛选
          PopupMenuButton<String>(
            icon: Icon(AppIcons.tune, size: 20.r),
            tooltip: '按状态筛选',
            onSelected: (v) {
              final notifier = ref.read(taskCenterProvider.notifier);
              notifier.setStatusFilter(v == st.statusFilter ? null : v);
            },
            itemBuilder: (_) => [
              for (final e in _statusFilters)
                PopupMenuItem(
                  value: e.value,
                  child: Text(
                    e.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: e.value == st.statusFilter
                          ? AppColors.primary
                          : AppColors.onSurface,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(AppIcons.refresh, size: 20.r),
            tooltip: '刷新',
            onPressed: () => ref.read(taskCenterProvider.notifier).refresh(),
          ),
          SizedBox(width: Spacing.sm.w),
        ],
      ),
      body: _buildBody(st, ref),
    );
  }

  Widget _buildBody(TaskCenterState st, WidgetRef ref) {
    if (st.loading) {
      return Center(
        child: CircularProgressIndicator(strokeWidth: 2.r),
      );
    }
    if (st.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.warning, size: 48.r, color: AppColors.error),
            SizedBox(height: Spacing.md.h),
            Text(
              '加载失败',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
            SizedBox(height: Spacing.sm.h),
            FilledButton.icon(
              onPressed: () => ref.read(taskCenterProvider.notifier).refresh(),
              icon: Icon(AppIcons.refresh, size: 16.r),
              label: const Text('重试'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    final grouped = st.groupedByType;
    if (grouped.isEmpty) {
      return const EmptyState(
        message: '暂无任务',
        icon: AppIcons.list,
      );
    }

    final typeOrder = grouped.keys.toList();
    return ListView.builder(
      padding: EdgeInsets.all(Spacing.lg.r),
      itemCount: typeOrder.length,
      itemBuilder: (context, index) {
        final type = typeOrder[index];
        final tasks = grouped[type]!;
        return _TaskGroup(type: type, tasks: tasks);
      },
    );
  }
}

/// 任务分组标题 + 卡片列表
class _TaskGroup extends StatelessWidget {
  final String type;
  final List<dynamic> tasks;
  const _TaskGroup({required this.type, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
          child: Row(
            children: [
              Text(
                _typeGroupLabel(type),
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.85),
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.sm.w,
                  vertical: Spacing.xxs.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                ),
                child: Text(
                  '${tasks.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...tasks.map((t) => TaskCard(task: t)),
        SizedBox(height: Spacing.md.h),
      ],
    );
  }
}

String _typeGroupLabel(String type) {
  const labels = {
    'image': '镜图生成',
    'video': '镜头生成',
    'script': '脚本生成',
    'export': '导出',
    'package': '打包',
  };
  return labels[type] ?? type;
}

/// 数量徽章
class _CountBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _CountBadge({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
      ),
      child: Text(
        '$label $count',
        style: AppTextStyles.labelTiny.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 类型筛选芯片行
class _FilterChipRow extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  const _FilterChipRow({required this.selected, required this.onChanged});

  static const _types = [
    ('image', '镜图'),
    ('video', '镜头'),
    ('script', '脚本'),
    ('export', '导出'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (value, label) in _types)
          Padding(
            padding: EdgeInsets.only(right: Spacing.xs.w),
            child: FilterChip(
              label: Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: selected == value ? AppColors.onPrimary : AppColors.muted,
                ),
              ),
              selected: selected == value,
              onSelected: (sel) => onChanged(sel ? value : null),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceVariant,
              side: BorderSide.none,
              padding: EdgeInsets.symmetric(horizontal: Spacing.xs.w),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
    );
  }
}

const _statusFilters = [
  (value: 'pending', label: '排队中'),
  (value: 'running', label: '运行中'),
  (value: 'completed', label: '已完成'),
  (value: 'failed', label: '失败'),
];
