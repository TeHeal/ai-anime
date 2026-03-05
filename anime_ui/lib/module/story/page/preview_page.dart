import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/module/story/providers/import_provider.dart';
import 'package:anime_ui/module/story/widgets/preview_unconfirmed_panel.dart';
import 'package:anime_ui/module/story/widgets/preview_widgets.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/providers/project_provider.dart';
import 'package:anime_ui/module/script/providers/script.dart';
import 'package:anime_ui/pub/services/script_parse_svc.dart';
import 'package:anime_ui/pub/widgets/story_action_bar.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';

/// 剧本解析预览页 — 检查并修正识别结果，确认后导入（Story 流程）
class StoryPreviewPage extends ConsumerStatefulWidget {
  const StoryPreviewPage({super.key});

  @override
  ConsumerState<StoryPreviewPage> createState() => _StoryPreviewPageState();
}

class _StoryPreviewPageState extends ConsumerState<StoryPreviewPage> {
  int _selectedEpisodeIdx = 0;
  int _selectedSceneIdx = 0;
  bool _showUnconfirmedPanel = false;

  @override
  Widget build(BuildContext context) {
    final parseState = ref.watch(parseStateProvider);
    final result = parseState.result;

    if (result == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.info, size: 48.r, color: AppColors.mutedDarker),
            SizedBox(height: Spacing.lg.h),
            Text(
              '无解析结果',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.muted),
            ),
            SizedBox(height: Spacing.sm.h),
            Text(
              '请先在「导入」页面上传并解析剧本',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedDarker,
              ),
            ),
          ],
        ),
      );
    }

    final script = result.script;
    final meta = script.metadata;
    final liveUnknown = _countUnknownBlocks(script);
    final isConfirming = parseState.phase == ParsePhase.confirming;

    return Column(
      children: [
        const PreviewReviewHintBar(),
        PreviewStatsBar(
          meta: meta,
          issueCount: result.issues.length,
          liveUnknownCount: liveUnknown,
          episodes: script.episodes,
        ),
        PreviewDynamicIssuesBar(
          liveUnknownCount: liveUnknown,
          originalTotal: meta.unknownBlocks,
          isPanelOpen: _showUnconfirmedPanel,
          onTogglePanel: () {
            setState(() => _showUnconfirmedPanel = !_showUnconfirmedPanel);
          },
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 280.w,
                child: PreviewEpisodeTree(
                  episodes: script.episodes,
                  selectedEpisodeIdx: _selectedEpisodeIdx,
                  selectedSceneIdx: _selectedSceneIdx,
                  onSelect: (epIdx, scIdx) {
                    setState(() {
                      _selectedEpisodeIdx = epIdx;
                      _selectedSceneIdx = scIdx;
                      _showUnconfirmedPanel = false;
                    });
                  },
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _showUnconfirmedPanel
                    ? PreviewUnconfirmedPanel(
                        episodes: script.episodes,
                        onChanged: () => setState(() {}),
                        onLocate: (epIdx, scIdx) {
                          setState(() {
                            _selectedEpisodeIdx = epIdx;
                            _selectedSceneIdx = scIdx;
                            _showUnconfirmedPanel = false;
                          });
                        },
                        onAllConfirmed: () {
                          setState(() => _showUnconfirmedPanel = false);
                        },
                      )
                    : PreviewSceneDetail(
                        episode: script.episodes.isNotEmpty
                            ? script.episodes[_selectedEpisodeIdx]
                            : null,
                        sceneIdx: _selectedSceneIdx,
                        onBlockChanged: () => setState(() {}),
                      ),
              ),
            ],
          ),
        ),
        StoryActionBar(
          leading: TextButton.icon(
            onPressed: () {
              ref.read(parseStateProvider.notifier).reset();
              context.go(Routes.storyImport);
            },
            icon: Icon(AppIcons.refresh, size: 16.r),
            label: const Text('重新解析'),
            style: TextButton.styleFrom(foregroundColor: AppColors.muted),
          ),
          trailing: ElevatedButton.icon(
            onPressed: isConfirming ? null : _confirmImport,
            icon: isConfirming
                ? SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onSurface,
                    ),
                  )
                : Icon(AppIcons.check, size: 18.r),
            label: Text(isConfirming ? '导入中...' : '确认导入'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _countUnknownBlocks(ParsedScript script) {
    var count = 0;
    for (final ep in script.episodes) {
      for (final sc in ep.scenes) {
        for (final b in sc.blocks) {
          if (b.type == 'unknown' || b.isLowConfidence) count++;
        }
      }
    }
    return count;
  }

  Future<void> _confirmImport() async {
    final projectId = ref.read(currentProjectProvider).value?.id;
    if (projectId == null) return;

    await ref.read(parseStateProvider.notifier).confirm(projectId);

    if (!mounted) return;

    final state = ref.read(parseStateProvider);
    if (state.phase == ParsePhase.done) {
      await ref.read(currentProjectProvider.notifier).refresh();
      ref.invalidate(episodesProvider);
      if (mounted) {
        context.go(Routes.storyEdit);
      }
    } else if (state.phase == ParsePhase.error) {
      showToast(context, '导入失败: ${state.errorMessage}', isError: true);
    }
  }
}
