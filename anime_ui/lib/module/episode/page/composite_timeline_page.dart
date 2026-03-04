import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/episode.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/services/composite_svc.dart';
import 'package:anime_ui/pub/services/episode_svc.dart';
import 'package:anime_ui/pub/services/package_svc.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/const/actions.dart' show AppActions;
import 'package:anime_ui/pub/widgets/permission_gate.dart';
import 'package:anime_ui/pub/widgets/secondary_btn.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';

/// 成片时间线页：按集展示、导出入口、打包入口（README 2.1.4）
class CompositeTimelinePage extends ConsumerStatefulWidget {
  const CompositeTimelinePage({super.key});

  @override
  ConsumerState<CompositeTimelinePage> createState() =>
      _CompositeTimelinePageState();
}

class _CompositeTimelinePageState extends ConsumerState<CompositeTimelinePage> {
  final _compositeSvc = CompositeService();
  final _packageSvc = PackageService();

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(currentProjectProvider).value;
    if (project?.id == null) {
      return _buildEmpty('请先选择项目');
    }

    return FutureBuilder<List<Episode>>(
      future: EpisodeService().list(project!.id!),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }
        if (snap.hasError) {
          return _buildError(snap.error);
        }
        final episodes = snap.data ?? [];
        if (episodes.isEmpty) {
          return _buildEmpty('暂无集，请先在剧本中创建');
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(Spacing.xl.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '成片时间线',
                style: AppTextStyles.h2.copyWith(color: AppColors.onSurface),
              ),
              SizedBox(height: Spacing.sm.h),
              Text(
                '按集导出成片或打包生成物',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedDark,
                ),
              ),
              SizedBox(height: Spacing.xl.h),
              ...episodes.where((ep) => ep.id != null).map((ep) => _EpisodeRow(
                    projectId: project.id!,
                    episode: ep,
                    compositeSvc: _compositeSvc,
                    packageSvc: _packageSvc,
                    onRefresh: () => setState(() {}),
                  )),
            ],
          ),
        );
      },
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
            '加载集中…',
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

class _EpisodeRow extends StatefulWidget {
  const _EpisodeRow({
    required this.projectId,
    required this.episode,
    required this.compositeSvc,
    required this.packageSvc,
    required this.onRefresh,
  });

  final String projectId;
  final Episode episode;
  final CompositeService compositeSvc;
  final PackageService packageSvc;
  final VoidCallback onRefresh;

  @override
  State<_EpisodeRow> createState() => _EpisodeRowState();
}

class _EpisodeRowState extends State<_EpisodeRow> {
  bool _exporting = false;
  bool _packaging = false;
  String? _error;

  String get _episodeId => widget.episode.id ?? '';
  String get _episodeTitle =>
      widget.episode.title.isNotEmpty
          ? widget.episode.title
          : '第${widget.episode.sortIndex + 1}集';

  Future<void> _createExport() async {
    if (_episodeId.isEmpty) return;
    setState(() {
      _exporting = true;
      _error = null;
    });
    try {
      await widget.compositeSvc.createExport(
        widget.projectId,
        _episodeId,
      );
      if (mounted) {
        showToast(context, '导出任务已创建');

        widget.onRefresh();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _requestPackage() async {
    if (_episodeId.isEmpty) return;
    setState(() {
      _packaging = true;
      _error = null;
    });
    try {
      await widget.packageSvc.requestPackage(
        widget.projectId,
        _episodeId,
      );
      if (mounted) {
        showToast(context, '打包任务已创建');

        widget.onRefresh();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _packaging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: Spacing.md.h),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(Spacing.lg.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.video, color: AppColors.primary, size: 24.r),
                SizedBox(width: Spacing.md.w),
                Expanded(
                  child: Text(
                    _episodeTitle,
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                PermissionGate(
                  action: AppActions.compositeExport,
                  child: SecondaryBtn(
                    label: _exporting ? '导出中…' : '导出成片',
                    onPressed: _exporting ? null : _createExport,
                  ),
                ),
                SizedBox(width: Spacing.sm.w),
                PermissionGate(
                  action: AppActions.compositeExport,
                  child: SecondaryBtn(
                    label: _packaging ? '打包中…' : '按集打包',
                    onPressed: _packaging ? null : _requestPackage,
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              SizedBox(height: Spacing.sm.h),
              Text(
                _error!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
