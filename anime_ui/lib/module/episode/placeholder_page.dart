import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/task.dart';
import 'package:anime_ui/pub/services/task_svc.dart';

/// 成片子页占位：可选的时间线模式
class EpisodePlaceholderPage extends ConsumerStatefulWidget {
  const EpisodePlaceholderPage({
    super.key,
    required this.title,
    required this.subtitle,
    this.showTimeline = false,
  });

  final String title;
  final String subtitle;
  final bool showTimeline;

  @override
  ConsumerState<EpisodePlaceholderPage> createState() =>
      _EpisodePlaceholderPageState();
}

class _EpisodePlaceholderPageState
    extends ConsumerState<EpisodePlaceholderPage> {
  List<Task>? _tasks;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.showTimeline) _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await TaskService().list(type: 'composite', limit: 30);
      if (mounted) setState(() => _tasks = tasks);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showTimeline) {
      return _buildGenericPlaceholder();
    }
    return _buildTimelineView();
  }

  /// 通用占位模式
  Widget _buildGenericPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.movie, size: 56, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '功能开发中...',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  /// 时间线模式：展示合成任务进度
  Widget _buildTimelineView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTimelineHeader(),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.error, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 12),
                  Text('加载失败: $_error',
                      style: TextStyle(color: Colors.red[400])),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _loadTasks,
                    icon: const Icon(AppIcons.refresh, size: 16),
                    label: const Text('重试'),
                  ),
                ],
              ),
            ),
          )
        else if (_tasks == null || _tasks!.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.video, size: 56, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    '暂无合成任务',
                    style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '完成镜头审核后可在此查看时间线',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(child: _buildTaskTimeline()),
      ],
    );
  }

  Widget _buildTimelineHeader() {
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
          const Icon(AppIcons.video, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (_tasks != null) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${_tasks!.length} 个任务',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            icon: const Icon(AppIcons.refresh, size: 18),
            tooltip: '刷新',
            onPressed: _loadTasks,
          ),
        ],
      ),
    );
  }

  /// 时间线列表
  Widget _buildTaskTimeline() {
    final tasks = _tasks!;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tasks.length,
      itemBuilder: (context, i) => _TimelineTaskItem(
        task: tasks[i],
        isFirst: i == 0,
        isLast: i == tasks.length - 1,
      ),
    );
  }
}

/// 时间线任务项：带连接线的卡片
class _TimelineTaskItem extends StatelessWidget {
  const _TimelineTaskItem({
    required this.task,
    required this.isFirst,
    required this.isLast,
  });

  final Task task;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 时间线指示器
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(child: Center(child: _line()))
                else
                  const Expanded(child: SizedBox.shrink()),
                _dot(),
                if (!isLast)
                  Expanded(child: Center(child: _line()))
                else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 任务卡片
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _statusIcon(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _readableType(task.type),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      _statusLabel(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (task.isRunning && task.progress > 0) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: task.progress / 100,
                        backgroundColor: AppColors.surfaceVariant,
                        color: AppColors.primary,
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '进度 ${task.progress}%',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                  if (task.provider.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${task.provider}${task.model.isNotEmpty ? ' / ${task.model}' : ''}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ),
                  if (task.error != null && task.error!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        task.error!,
                        style: TextStyle(fontSize: 11, color: Colors.red[400]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    final color = _statusColor();
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.3),
        border: Border.all(color: color, width: 2),
      ),
    );
  }

  Widget _line() {
    return Container(width: 2, color: AppColors.border);
  }

  Widget _statusIcon() {
    if (task.isRunning) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: task.progress > 0 ? task.progress / 100 : null,
          color: AppColors.primary,
        ),
      );
    }
    if (task.isPending) {
      return Icon(AppIcons.hourglassEmpty, size: 18, color: Colors.amber[600]);
    }
    if (task.isCompleted) {
      return const Icon(AppIcons.check, size: 18, color: Colors.green);
    }
    if (task.isFailed) {
      return Icon(AppIcons.error, size: 18, color: Colors.red[400]);
    }
    return Icon(AppIcons.circleOutline, size: 18, color: Colors.grey[600]);
  }

  Widget _statusLabel() {
    final color = _statusColor();
    final label = switch (task.status) {
      'running' => '运行中',
      'pending' => '等待中',
      'completed' => '已完成',
      'failed' => '失败',
      'cancelled' => '已取消',
      _ => task.status,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Color _statusColor() {
    if (task.isRunning) return AppColors.primary;
    if (task.isPending) return Colors.amber;
    if (task.isCompleted) return Colors.green;
    if (task.isFailed) return Colors.red;
    return Colors.grey;
  }

  String _readableType(String type) {
    return switch (type) {
      'shot_image' => '镜图生成',
      'shot_video' => '镜头生成',
      'character_image' => '角色形象生成',
      'script_generate' => '脚本生成',
      'composite' => '合成任务',
      'voice' => '配音生成',
      'export' => '导出任务',
      _ => type,
    };
  }
}
