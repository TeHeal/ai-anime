import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/models/dashboard.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/gradient_app_bar_bottom.dart';
import 'package:anime_ui/pub/widgets/pulse_widget.dart';
import 'package:anime_ui/pub/widgets/starfield_background.dart';
import 'provider.dart';
import 'widgets/asset_overview.dart';
import 'widgets/episode_group.dart';
import 'widgets/progress_overview.dart';

/// 仪表盘页：项目进度、集分组、资产概况
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).load();
    });
  }

  void _enterEpisode(DashboardEpisode ep) {
    final epNum = ep.sortIndex + 1;
    final epParam = '?episode=$epNum';
    final stepRoute = switch (ep.currentStep) {
      0 => '${Routes.assetsCharacters}$epParam',
      1 => '${Routes.assetsCharacters}$epParam',
      2 => '${Routes.scriptCenter}$epParam',
      3 => Routes.shotImagesCenter,
      4 => Routes.shotsCenter,
      5 => Routes.episodeTimeline,
      _ => '${Routes.assetsCharacters}$epParam',
    };
    context.go(stepRoute);
  }

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(dashboardProvider);
    final project = ref.watch(currentProjectProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: dashAsync.when(
        data: (dash) => _buildBody(dash, project?.name ?? ''),
        loading: () => _buildLoading(),
        error: (e, _) => _buildError(e),
      ),
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
            '加载项目数据…',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object e) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.error, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            '$e',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => ref.read(dashboardProvider.notifier).load(),
            icon: const Icon(AppIcons.refresh, size: 16),
            label: const Text('重试'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Dashboard dash, String projectName) {
    if (dash.totalEpisodes == 0) return _buildEmpty(projectName);

    final inProgress = dash.episodes
        .where((e) => e.status == 'in_progress')
        .toList()
      ..sort(_compareByActive);
    final notStarted = dash.episodes
        .where((e) => e.status == 'not_started')
        .toList()
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    final completed = dash.episodes
        .where((e) => e.status == 'completed')
        .toList()
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));

    return CustomScrollView(
      slivers: [
        _buildAppBar(projectName, dash),
        const SliverPadding(padding: EdgeInsets.only(top: 12)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return Column(
                        children: [
                          ProgressOverview(dash: dash),
                          const SizedBox(height: 12),
                          AssetOverview(summary: dash.assetSummary),
                        ],
                      );
                    }
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: ProgressOverview(dash: dash)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: AssetOverview(
                                  summary: dash.assetSummary)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (inProgress.isNotEmpty)
          EpisodeGroup(
            title: '进行中',
            titleColor: const Color(0xFF3B82F6),
            titleIcon: AppIcons.inProgress,
            episodes: inProgress,
            onEpisodeTap: _enterEpisode,
            defaultExpanded: true,
          ),
        if (notStarted.isNotEmpty)
          EpisodeGroup(
            title: '待开始',
            titleColor: Colors.grey[500]!,
            titleIcon: AppIcons.circleOutline,
            episodes: notStarted,
            onEpisodeTap: _enterEpisode,
            expandFirstGroup: true,
            compact: true,
          ),
        if (completed.isNotEmpty)
          EpisodeGroup(
            title: '已完成',
            titleColor: const Color(0xFF22C55E),
            titleIcon: AppIcons.check,
            episodes: completed,
            onEpisodeTap: _enterEpisode,
            compact: true,
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 48)),
      ],
    );
  }

  Widget _buildEmpty(String projectName) {
    return Stack(
      children: [
        StarfieldBackground(
          particleCount: 40,
          speed: 0.15,
          overlayGradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              AppColors.primary.withValues(alpha: 0.06),
              Colors.transparent,
            ],
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulseWidget(
                pulseColor: AppColors.primary,
                ringPadding: 20,
                maxScale: 1.1,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.movie,
                    size: 36,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                projectName.isNotEmpty ? projectName : '项目驾驶舱',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '导入剧本后，这里将显示所有集的制作进度',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go(Routes.storyImport),
                icon: const Icon(AppIcons.book, size: 18),
                label: const Text('去导入剧本'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(String projectName, Dashboard dash) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      pinned: true,
      expandedHeight: 74,
      toolbarHeight: 72,
      leadingWidth: 56,
      leading: Center(
        child: IconButton(
          icon: Icon(AppIcons.chevronLeft,
              color: Colors.grey[400], size: 20),
          onPressed: () => context.go(Routes.projects),
          tooltip: '返回项目列表',
        ),
      ),
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.movie, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              projectName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${dash.totalEpisodes}集',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
      bottom: const GradientAppBarBottom(),
      actions: [
        IconButton(
          icon: Icon(AppIcons.refresh,
              color: Colors.grey[400], size: 18),
          onPressed: () => ref.read(dashboardProvider.notifier).load(),
          tooltip: '刷新',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  int _compareByActive(DashboardEpisode a, DashboardEpisode b) {
    final aTime = a.lastActiveAt;
    final bTime = b.lastActiveAt;
    if (aTime == null && bTime == null) {
      return a.sortIndex.compareTo(b.sortIndex);
    }
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    return bTime.compareTo(aTime);
  }
}
