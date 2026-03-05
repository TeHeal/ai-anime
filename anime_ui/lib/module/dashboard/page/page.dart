import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/models/dashboard.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/error_state.dart';
import 'package:anime_ui/pub/widgets/gradient_app_bar_bottom.dart';
import 'package:anime_ui/pub/widgets/pulse.dart';
import 'package:anime_ui/pub/widgets/starfield_background.dart';
import 'package:anime_ui/module/dashboard/providers/provider.dart';
import 'package:anime_ui/module/dashboard/widgets/asset_overview.dart';
import 'package:anime_ui/module/dashboard/widgets/dashboard_helpers.dart';
import 'package:anime_ui/module/dashboard/widgets/episode_group.dart';
import 'package:anime_ui/module/dashboard/widgets/progress_overview.dart';

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
            width: 40.w,
            height: 40.h,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: Spacing.lg.h),
          AnimatedTextKit(
            animatedTexts: [
              FadeAnimatedText(
                '加载项目数据…',
                textStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            isRepeatingAnimation: true,
            repeatForever: true,
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object e) {
    return ErrorState(
      message: '加载失败',
      detail: '$e',
      onRetry: () => ref.read(dashboardProvider.notifier).load(),
    );
  }

  Widget _buildBody(Dashboard dash, String projectName) {
    if (dash.totalEpisodes == 0) return _buildEmpty(projectName);

    // status 为空时视为 not_started（兼容旧数据）
    String statusVal(String s) => s.isEmpty ? 'not_started' : s;
    final inProgress =
        dash.episodes.where((e) => statusVal(e.status) == 'in_progress').toList()
          ..sort(_compareByActive);
    final notStarted =
        dash.episodes.where((e) => statusVal(e.status) == 'not_started').toList()
          ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    final completed =
        dash.episodes.where((e) => statusVal(e.status) == 'completed').toList()
          ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));

    // totalEpisodes > 0 但 episodes 为空：数据不同步，提示刷新
    final hasEpisodeGroups =
        inProgress.isNotEmpty || notStarted.isNotEmpty || completed.isNotEmpty;
    if (!hasEpisodeGroups) {
      return _buildBodyWithScrollbar(
        slivers: [
          _buildAppBar(projectName, dash),
          SliverPadding(padding: EdgeInsets.only(top: Spacing.sm.h)),
          _buildStatsBar(dash),
          _buildOverviewRow(dash),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '集列表暂未加载完成',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.mutedDark,
                    ),
                  ),
                  SizedBox(height: Spacing.md.h),
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(dashboardProvider.notifier).load(),
                    icon: Icon(AppIcons.refresh, size: 16.r),
                    label: const Text('刷新'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _buildBodyWithScrollbar(
      slivers: [
        _buildAppBar(projectName, dash),
        SliverPadding(padding: EdgeInsets.only(top: Spacing.sm.h)),
        _buildStatsBar(dash),
        _buildOverviewRow(dash),
        if (inProgress.isNotEmpty)
          EpisodeGroup(
            title: '进行中',
            titleColor: AppColors.info,
            titleIcon: AppIcons.inProgress,
            episodes: inProgress,
            onEpisodeTap: _enterEpisode,
            defaultExpanded: true,
          ),
        if (notStarted.isNotEmpty)
          EpisodeGroup(
            title: '待开始',
            titleColor: AppColors.mutedDark,
            titleIcon: AppIcons.circleOutline,
            episodes: notStarted,
            onEpisodeTap: _enterEpisode,
            expandFirstGroup: true,
            compact: true,
          ),
        if (completed.isNotEmpty)
          EpisodeGroup(
            title: '已完成',
            titleColor: AppColors.success,
            titleIcon: AppIcons.check,
            episodes: completed,
            onEpisodeTap: _enterEpisode,
            compact: true,
          ),
        SliverPadding(
          padding: EdgeInsets.only(bottom: (Spacing.xl + Spacing.lg).h),
        ),
      ],
    );
  }

  /// 使用 Scrollbar 包裹，Web 端便于发现可滚动内容
  Widget _buildBodyWithScrollbar({required List<Widget> slivers}) {
    return Scrollbar(
      thumbVisibility: true,
      child: CustomScrollView(
        slivers: slivers,
      ),
    );
  }

  Widget _buildOverviewRow(Dashboard dash) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xxl.w,
        vertical: Spacing.sm.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (Breakpoints.isNarrow(constraints.maxWidth)) {
                  return Column(
                    children: [
                      ProgressOverview(dash: dash),
                      SizedBox(height: Spacing.md.h),
                      AssetOverview(summary: dash.assetSummary),
                    ],
                  );
                }
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: ProgressOverview(dash: dash)),
                      SizedBox(width: Spacing.lg.w),
                      Expanded(
                        child: AssetOverview(summary: dash.assetSummary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar(Dashboard dash) {
    final done = dash.statusCounts['completed'] ?? 0;
    final inProg = dash.statusCounts['in_progress'] ?? 0;
    final total = dash.totalEpisodes;

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xxl.w,
        vertical: Spacing.sm.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000.w),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 8.h * (1 - value)),
                  child: child,
                ),
              ),
              child: Row(
                children: [
                  StatChip(
                    icon: AppIcons.movie,
                    label: '总集数',
                    value: '$total',
                    color: AppColors.primary,
                  ),
                  SizedBox(width: Spacing.md.w),
                  StatChip(
                    icon: AppIcons.inProgress,
                    label: '进行中',
                    value: '$inProg',
                    color: AppColors.info,
                  ),
                  SizedBox(width: Spacing.md.w),
                  StatChip(
                    icon: AppIcons.check,
                    label: '已完成',
                    value: '$done',
                    color: AppColors.success,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
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
                ringPadding: 20.r,
                maxScale: 1.1,
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.movie,
                    size: 36.r,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
              SizedBox(height: (Spacing.xxl + Spacing.xs).h),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    AppColors.onSurface,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ).createShader(bounds),
                child: Text(
                  projectName.isNotEmpty ? projectName : '项目驾驶舱',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: Spacing.sm.h),
              Text(
                '导入剧本后，这里将显示所有集的制作进度',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedDark,
                ),
              ),
              SizedBox(height: Spacing.xl.h),
              GradientActionButton(
                onTap: () => context.go(Routes.storyImport),
                icon: AppIcons.book,
                label: '去导入剧本',
              ),
              SizedBox(height: Spacing.lg.h),
              _buildQuickStartHints(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStartHints() {
    final steps = [
      ('导入剧本', AppIcons.book, '上传或编写你的故事'),
      ('生成资产', AppIcons.people, '角色、场景自动生成'),
      ('制作成片', AppIcons.movie, '一键生成动漫短片'),
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(opacity: value, child: child),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
                child: Icon(
                  AppIcons.chevronRight,
                  size: 14.r,
                  color: AppColors.mutedDarker,
                ),
              ),
            QuickStepChip(
              icon: steps[i].$2,
              label: steps[i].$1,
              subtitle: steps[i].$3,
            ),
          ],
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(String projectName, Dashboard dash) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      pinned: true,
      expandedHeight: 74.h,
      toolbarHeight: 72.h,
      leadingWidth: 56.w,
      leading: Center(
        child: IconButton(
          icon: Icon(AppIcons.chevronLeft, color: AppColors.muted, size: 20.r),
          onPressed: () => context.go(Routes.projects),
          tooltip: '返回项目列表',
        ),
      ),
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.movie, color: AppColors.primary, size: 22.r),
          SizedBox(width: RadiusTokens.lg.w),
          Flexible(
            child: Text(
              projectName,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: RadiusTokens.lg.w),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w,
              vertical: Spacing.progressBarHeight.h,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.info.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            ),
            child: Text(
              '${dash.totalEpisodes}集',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      bottom: const GradientAppBarBottom(),
      actions: [
        IconButton(
          icon: Icon(AppIcons.refresh, color: AppColors.muted, size: 18.r),
          onPressed: () => ref.read(dashboardProvider.notifier).load(),
          tooltip: '刷新',
        ),
        SizedBox(width: Spacing.sm.w),
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
