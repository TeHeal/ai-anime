import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/project.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/composite_svc.dart';
import 'package:anime_ui/pub/services/package_svc.dart';
import 'package:anime_ui/pub/services/download_svc.dart';
import 'package:anime_ui/pub/services/episode_svc.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/primary_btn.dart';

/// 成片导出页：任务列表、进度展示、下载入口（README 2.1.4、2.2.4）
class CompositeExportPage extends ConsumerStatefulWidget {
  const CompositeExportPage({super.key});

  @override
  ConsumerState<CompositeExportPage> createState() =>
      _CompositeExportPageState();
}

class _CompositeExportPageState extends ConsumerState<CompositeExportPage> {
  final _compositeSvc = CompositeService();
  final _packageSvc = PackageService();
  final _downloadSvc = DownloadService();

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(currentProjectProvider).value;
    if (project == null || project.id == null) {
      return _buildEmpty('请先选择项目');
    }

    return FutureBuilder<({List<CompositeTask> composites, List<PackageTask> packages})>(
      future: _loadTasks(project.id!, project),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }
        if (snap.hasError) {
          return _buildError(snap.error);
        }
        final data = snap.data!;

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  '成片导出',
                  data.composites,
                  (t) => _TaskRow(
                    label: '成片 ${t.episodeId}',
                    status: t.status,
                    outputUrl: t.outputUrl,
                    errorMsg: t.errorMsg,
                    onDownload: t.outputUrl != null
                        ? () => _download(t.outputUrl!, 'composite_${t.id}.mp4')
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  '按集打包',
                  data.packages,
                  (t) => _TaskRow(
                    label: '打包 ${t.episodeId}',
                    status: t.status,
                    outputUrl: t.outputUrl,
                    errorMsg: t.errorMsg,
                    onDownload: t.outputUrl != null
                        ? () => _download(t.outputUrl!, 'package_${t.id}.zip')
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<({List<CompositeTask> composites, List<PackageTask> packages})> _loadTasks(
    int projectIdInt,
    Project project,
  ) async {
    final projectId = projectIdInt.toString();
    final composites = await _compositeSvc.listByProject(projectId);
    final episodes = await EpisodeService().list(projectIdInt);
    final packages = <PackageTask>[];
    for (final ep in episodes) {
      if (ep.id == null) continue;
      final list = await _packageSvc.listByEpisode(projectId, ep.id.toString());
      packages.addAll(list);
    }
    packages.sort((a, b) => b.id.compareTo(a.id));
    return (composites: composites, packages: packages);
  }

  Future<void> _download(String url, String filename) async {
    final projectId = ref.read(currentProjectProvider).value?.id?.toString();
    if (projectId == null) return;
    try {
      await _downloadSvc.triggerDownload(
        projectId,
        url: url,
        filename: filename,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('下载已开始')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('下载失败: $e')),
        );
      }
    }
  }

  Widget _buildSection<T>(
    String title,
    List<T> items,
    Widget Function(T) itemBuilder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '暂无任务',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
          )
        else
          ...items.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: itemBuilder(t),
              )),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '加载任务列表…',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.folderOpen, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildError(Object? e) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.error, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            '加载失败: $e',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.label,
    required this.status,
    this.outputUrl,
    this.errorMsg,
    this.onDownload,
  });

  final String label;
  final String status;
  final String? outputUrl;
  final String? errorMsg;
  final VoidCallback? onDownload;

  String get _statusText {
    switch (status) {
      case 'done':
        return '已完成';
      case 'failed':
        return '失败';
      case 'exporting':
      case 'packaging':
        return '处理中';
      default:
        return '等待中';
    }
  }

  Color get _statusColor {
    switch (status) {
      case 'done':
        return const Color(0xFF22C55E);
      case 'failed':
        return AppColors.error;
      case 'exporting':
      case 'packaging':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusText,
                          style: TextStyle(
                            color: _statusColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (errorMsg != null && errorMsg!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMsg!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (onDownload != null)
              PrimaryBtn(
                label: '下载',
                onPressed: onDownload,
              ),
          ],
        ),
      ),
    );
  }
}
