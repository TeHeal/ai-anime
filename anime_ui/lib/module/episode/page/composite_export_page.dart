import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/project.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/composite_svc.dart';
import 'package:anime_ui/pub/services/package_svc.dart';
import 'package:anime_ui/pub/services/download_svc.dart';
import 'package:anime_ui/pub/services/episode_svc.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/primary_btn.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';

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

    return FutureBuilder<
      ({List<CompositeTask> composites, List<PackageTask> packages})
    >(
      future: _loadTasks(project),
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
            padding: EdgeInsets.all(Spacing.xl.r),
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
                SizedBox(height: Spacing.xl.h),
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

  Future<({List<CompositeTask> composites, List<PackageTask> packages})>
  _loadTasks(Project project) async {
    final projectId = project.id!;
    final composites = await _compositeSvc.listByProject(projectId);
    final episodes = await EpisodeService().list(projectId);
    final packages = <PackageTask>[];
    for (final ep in episodes) {
      if (ep.id == null) continue;
      final list = await _packageSvc.listByEpisode(projectId, ep.id!);
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
        showToast(context, '下载已开始');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, '下载失败: $e', isError: true);
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
          style: AppTextStyles.h3.copyWith(color: AppColors.onSurface),
        ),
        SizedBox(height: Spacing.md.h),
        if (items.isEmpty)
          Container(
            padding: EdgeInsets.all(Spacing.xl.r),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            ),
            child: Center(
              child: Text(
                '暂无任务',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedDark,
                ),
              ),
            ),
          )
        else
          ...items.map(
            (t) => Padding(
              padding: EdgeInsets.only(bottom: Spacing.sm.h),
              child: itemBuilder(t),
            ),
          ),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40.w,
            height: 40.h,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: Spacing.lg.h),
          Text(
            '加载任务列表…',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedDark,
            ),
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
          Icon(AppIcons.folderOpen, size: 48.r, color: AppColors.mutedDarker),
          SizedBox(height: Spacing.lg.h),
          Text(
            msg,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object? e) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.error, size: 48.r, color: AppColors.mutedDarker),
          SizedBox(height: Spacing.lg.h),
          Text(
            '加载失败: $e',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedDark,
            ),
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
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'exporting':
      case 'packaging':
        return AppColors.primary;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(Spacing.lg.r),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: Spacing.xs.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.sm.w,
                          vertical: Spacing.xxs.h,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                        ),
                        child: Text(
                          _statusText,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: _statusColor,
                          ),
                        ),
                      ),
                      if (errorMsg != null && errorMsg!.isNotEmpty) ...[
                        SizedBox(width: Spacing.sm.w),
                        Expanded(
                          child: Text(
                            errorMsg!,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.error,
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
              PrimaryBtn(label: '下载', onPressed: onDownload),
          ],
        ),
      ),
    );
  }
}
