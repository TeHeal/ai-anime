import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/task.dart';
import 'package:anime_ui/module/task_center/providers/task_center_provider.dart';

/// 任务中心页：按状态分组展示任务列表
class TaskCenterPage extends ConsumerWidget {
  const TaskCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskCenterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(ref, state),
        if (state.loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (state.error != null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.error, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 12),
                  Text(
                    '加载失败: ${state.error}',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => ref.invalidate(taskCenterProvider),
                    icon: const Icon(AppIcons.refresh, size: 16),
                    label: const Text('重试'),
                  ),
                ],
              ),
            ),
          )
        else if (state.tasks.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.check, size: 64, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    '暂无任务',
                    style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '所有生成任务将在此显示',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(child: _TaskGroupList(tasks: state.tasks)),
      ],
    );
  }

  Widget _buildHeader(WidgetRef ref, TaskCenterState state) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.inProgress, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          const Text(
            '任务中心',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          _StatChip(
            label: '运行中',
            count: state.runningCount,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: '等待中',
            count: state.pendingCount,
            color: Colors.amber,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(AppIcons.refresh, size: 18),
            tooltip: '刷新',
            onPressed: () => ref.invalidate(taskCenterProvider),
          ),
        ],
      ),
    );
  }
}

/// 统计芯片
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 按状态分组的任务列表
class _TaskGroupList extends StatelessWidget {
  const _TaskGroupList({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final running = tasks.where((t) => t.isRunning).toList();
    final pending = tasks.where((t) => t.isPending).toList();
    final completed = tasks.where((t) => t.isFinished).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (running.isNotEmpty) ...[
          _GroupHeader(
            label: '运行中',
            count: running.length,
            color: AppColors.primary,
            icon: AppIcons.inProgress,
          ),
          const SizedBox(height: 8),
          ...running.map((t) => _TaskTile(task: t)),
          const SizedBox(height: 20),
        ],
        if (pending.isNotEmpty) ...[
          _GroupHeader(
            label: '等待中',
            count: pending.length,
            color: Colors.amber,
            icon: AppIcons.hourglassEmpty,
          ),
          const SizedBox(height: 8),
          ...pending.map((t) => _TaskTile(task: t)),
          const SizedBox(height: 20),
        ],
        if (completed.isNotEmpty) ...[
          _GroupHeader(
            label: '已完成',
            count: completed.length,
            color: Colors.green,
            icon: AppIcons.check,
          ),
          const SizedBox(height: 8),
          ...completed.map((t) => _TaskTile(task: t)),
        ],
      ],
    );
  }
}

/// 分组标题
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// 单个任务行
class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _statusIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _readableType(task.type),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${task.taskId}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                if (task.error != null && task.error!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.error!,
                    style: TextStyle(fontSize: 11, color: Colors.red[400]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (task.isRunning || task.isPending) _progressWidget(),
          if (task.provider.isNotEmpty) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                task.model.isNotEmpty ? task.model : task.provider,
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusIcon() {
    if (task.isRunning) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: task.progress > 0 ? task.progress / 100 : null,
          color: AppColors.primary,
        ),
      );
    }
    if (task.isPending) {
      return Icon(AppIcons.hourglassEmpty, size: 20, color: Colors.amber[600]);
    }
    if (task.isCompleted) {
      return const Icon(AppIcons.check, size: 20, color: Colors.green);
    }
    if (task.isFailed) {
      return Icon(AppIcons.error, size: 20, color: Colors.red[400]);
    }
    return Icon(AppIcons.circleOutline, size: 20, color: Colors.grey[600]);
  }

  Widget _progressWidget() {
    if (task.progress <= 0) return const SizedBox.shrink();
    return SizedBox(
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${task.progress}%',
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: task.progress / 100,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.primary,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// 将任务类型转换为可读标签
  String _readableType(String type) {
    return switch (type) {
      'shot_image' => '镜图生成',
      'shot_video' => '镜头生成',
      'character_image' => '角色形象生成',
      'script_generate' => '脚本生成',
      'composite' => '合成任务',
      'voice' => '配音生成',
      'export' => '导出任务',
      'bio_extract' => '人物传记提取',
      _ => type,
    };
  }
}
