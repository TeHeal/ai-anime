import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/generation_center/batch_action_bar.dart';
import 'package:anime_ui/pub/widgets/image_lightbox.dart';
import 'package:anime_ui/pub/widgets/text_gen/text_gen_trigger.dart';
import 'package:anime_ui/pub/widgets/voice_gen/voice_gen_trigger.dart';

import '../models/resource_category.dart';
import '../providers/provider.dart';
import '../dialogs/resource_detail_dialog.dart';
import '../dialogs/resource_form_dialog.dart';
import 'content_toolbar.dart';
import 'resource_card.dart';
import 'resource_filter_bar.dart';

/// 内容区：资源网格（风格已合并到顶级 Tab，此处仅展示素材库资源）
class ContentArea extends ConsumerStatefulWidget {
  const ContentArea({super.key, required this.modality});

  final ResourceModality modality;

  @override
  ConsumerState<ContentArea> createState() => _ContentAreaState();
}

class _ContentAreaState extends ConsumerState<ContentArea> {
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(resourceListProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ResourceLibraryType>(selectedLibraryTypeProvider, (prev, next) {
      if (prev != null && prev != next) {
        ref.read(resourceListProvider.notifier).load();
      }
    });
    ref.listen<ResourceSort>(resourceSortProvider, (prev, next) {
      if (prev != null && prev != next) {
        ref.read(resourceListProvider.notifier).load();
      }
    });
    ref.listen<String>(resourceSearchProvider, (prev, next) {
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          ref.read(resourceListProvider.notifier).load();
        }
      });
    });

    final libraryType = ref.watch(selectedLibraryTypeProvider);
    final asyncList = ref.watch(resourceListProvider);
    final resources = ref.watch(filteredResourceListProvider);
    final viewMode = ref.watch(viewModeProvider);
    final batchMode = ref.watch(batchModeProvider);
    final selectedIds = ref.watch(selectedResourceIdsProvider);
    final color = widget.modality.color;
    final isTextOrAudio = widget.modality == ResourceModality.text ||
        widget.modality == ResourceModality.audio;
    final cardAspectRatio = isTextOrAudio ? 1.0 : 3 / 2;
    final isLoading = asyncList is AsyncLoading;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          ResourceFilterBar(accentColor: color),
          ContentToolbar(
            totalCount: resources.length,
            accentColor: color,
            libraryType: libraryType,
            viewMode: viewMode,
            batchMode: batchMode,
            selectedCount: selectedIds.length,
          ),
          if (batchMode)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.mid.w,
                vertical: Spacing.sm.h,
              ),
              child: Row(
                children: [
                  BatchActionBar(
                    totalCount: resources.length,
                    selectedCount: selectedIds.length,
                    allSelected: selectedIds.length == resources.length &&
                        resources.isNotEmpty,
                    onToggleSelectAll: () {
                      if (selectedIds.length == resources.length) {
                        ref.read(selectedResourceIdsProvider.notifier).clear();
                      } else {
                        ref.read(selectedResourceIdsProvider.notifier).setAll(
                              resources
                                  .map((r) => r.id ?? '')
                                  .where((id) => id.isNotEmpty),
                            );
                      }
                    },
                    batchLabel: '批量删除',
                    batchIcon: AppIcons.delete,
                    batchEnabled: true,
                    onBatchAction: () async {
                      if (selectedIds.isEmpty) return;
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('确认删除'),
                          content: Text(
                            '确定要删除选中的 ${selectedIds.length} 个素材吗？',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('取消'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('删除'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await ref
                            .read(resourceListProvider.notifier)
                            .batchRemove(selectedIds);
                        if (context.mounted) {
                          ref
                              .read(selectedResourceIdsProvider.notifier)
                              .clear();
                          ref.read(batchModeProvider.notifier).set(false);
                        }
                      }
                    },
                  ),
                  SizedBox(width: Spacing.sm.w),
                  BatchMoveButton(
                    selectedCount: selectedIds.length,
                    selectedIds: selectedIds,
                    libraryType: libraryType,
                    accentColor: color,
                    onComplete: () {
                      ref.read(selectedResourceIdsProvider.notifier).clear();
                      ref.read(batchModeProvider.notifier).set(false);
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: isLoading
                ? _buildLoadingSkeleton(color, cardAspectRatio)
                : resources.isEmpty
                    ? _buildEmpty(context, libraryType, color)
                    : _buildContent(
                        context,
                        resources,
                        cardAspectRatio,
                        color,
                        viewMode,
                        batchMode,
                        selectedIds,
                      ),
          ),
        ],
      ),
    );
  }

  /// 骨架屏加载态
  Widget _buildLoadingSkeleton(Color color, double cardAspectRatio) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            Breakpoints.columnCountForWidth(constraints.maxWidth, maxCols: 5);
        return GridView.builder(
          padding: EdgeInsets.all(Spacing.mid.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: Spacing.gridGap.w,
            mainAxisSpacing: Spacing.gridGap.h,
            childAspectRatio: _cardAspectRatio(cardAspectRatio),
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            return _SkeletonCard(
              accentColor: color,
              delay: index * 80,
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Resource> resources,
    double cardAspectRatio,
    Color color,
    ViewMode viewMode,
    bool batchMode,
    Set<String> selectedIds,
  ) {
    return switch (viewMode) {
      ViewMode.grid => _buildGrid(
          context, resources, cardAspectRatio, color, batchMode, selectedIds),
      ViewMode.list => _buildList(
          context, resources, color, batchMode, selectedIds),
      ViewMode.preview => _buildGrid(
          context, resources, cardAspectRatio, color, batchMode, selectedIds,
          isPreview: true),
    };
  }

  Widget _buildEmpty(
    BuildContext context,
    ResourceLibraryType libraryType,
    Color color,
  ) {
    final modes = libraryType.availableAddModes;
    final hasUpload = modes.contains(AddMode.upload);
    final hasAiGen = modes.contains(AddMode.aiGenerate);
    final isVisual = libraryType.modality == ResourceModality.visual;
    final isAudio = libraryType.modality == ResourceModality.audio;
    final isText = libraryType.modality == ResourceModality.text;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            libraryType.icon,
            size: 48.r,
            color: color.withValues(alpha: 0.3),
          ),
          SizedBox(height: Spacing.md.h),
          Text(
            '${libraryType.label}暂无素材',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Spacing.xs.h),
          Text(
            '添加第一个素材开始创作',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDark),
          ),
          if (hasUpload || hasAiGen) ...[
            SizedBox(height: Spacing.lg.h),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: Spacing.sm.w,
              runSpacing: Spacing.sm.h,
              children: [
                if (hasUpload) ...[
                  TextButton.icon(
                    onPressed: () => showResourceUploadDialog(
                      context,
                      ref,
                      libraryType: libraryType,
                      accentColor: color,
                    ),
                    icon: Icon(AppIcons.upload, size: 18.r),
                    label: const Text('上传'),
                    style: TextButton.styleFrom(foregroundColor: color),
                  ),
                  TextButton.icon(
                    onPressed: () => showResourceBatchUploadDialog(
                      context,
                      ref,
                      libraryType: libraryType,
                      accentColor: color,
                    ),
                    icon: Icon(AppIcons.upload, size: 18.r),
                    label: const Text('批量上传'),
                    style: TextButton.styleFrom(foregroundColor: color),
                  ),
                ],
                if (hasAiGen && isVisual)
                  FilledButton.icon(
                    onPressed: () => showResourceAiGenerateDialog(
                      context,
                      ref,
                      libraryType: libraryType,
                      accentColor: color,
                    ),
                    icon: Icon(AppIcons.magicStick, size: 18.r),
                    label: const Text('AI 生成'),
                    style: FilledButton.styleFrom(backgroundColor: color),
                  ),
                if (hasAiGen && isAudio)
                  VoiceGenTrigger(
                    config: voiceGenConfigForLibrary(color, ref),
                    label: '创建音色',
                    icon: AppIcons.mic,
                    style: FilledButton.styleFrom(backgroundColor: color),
                  ),
                if (hasAiGen && isText)
                  TextGenTrigger(
                    config: textGenConfigForLibrary(
                      libraryType,
                      color,
                      () => ref.read(resourceListProvider.notifier).load(),
                    ),
                    label: libraryType == ResourceLibraryType.styleGuide
                        ? 'AI 生成风格指令'
                        : 'AI 生成提示词',
                    icon: AppIcons.magicStick,
                    style: FilledButton.styleFrom(backgroundColor: color),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<Resource> resources,
    double cardAspectRatio,
    Color color,
    bool batchMode,
    Set<String> selectedIds, {
    bool isPreview = false,
  }) {
    final crossCols = isPreview ? 2 : 5;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            Breakpoints.columnCountForWidth(constraints.maxWidth, maxCols: crossCols);
        return GridView.builder(
          padding: EdgeInsets.all(Spacing.mid.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: Spacing.gridGap.w,
            mainAxisSpacing: Spacing.gridGap.h,
            childAspectRatio: _cardAspectRatio(
              isPreview ? 4 / 3 : cardAspectRatio,
            ),
          ),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final res = resources[index];
            final resId = res.id ?? '';
            final isSelected = batchMode && selectedIds.contains(resId);
            return ResourceCard(
              resource: res,
              accentColor: color,
              aspectRatio: isPreview ? 4 / 3 : cardAspectRatio,
              isSelected: isSelected,
              isBatchMode: batchMode,
              onTap: batchMode
                  ? () {
                      if (resId.isNotEmpty) {
                        ref
                            .read(selectedResourceIdsProvider.notifier)
                            .toggle(resId);
                      }
                    }
                  : () => showResourceDetailDialog(
                        context,
                        ref,
                        resource: res,
                        accentColor: color,
                      ),
              onViewLargeImage: res.hasThumbnail && res.modality == 'visual'
                  ? () => showImageLightbox(context, imageUrl: res.thumbnailUrl)
                  : null,
              onViewDetail: () => showResourceDetailDialog(
                context,
                ref,
                resource: res,
                accentColor: color,
              ),
              onEdit: () => showResourceFormDialog(
                context,
                ref,
                libraryType: ResourceLibraryType.values
                    .firstWhere(
                      (t) => t.name == res.libraryType,
                      orElse: () => ResourceLibraryType.character,
                    ),
                accentColor: color,
                initial: res,
              ),
              onCopy: () => ref.read(resourceListProvider.notifier).addResource(
                    res.copyWith(id: null, name: '${res.name}(副本)'),
                  ),
              onDelete: res.id != null && res.id!.isNotEmpty
                  ? () => ref.read(resourceListProvider.notifier).removeResource(res.id!)
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Resource> resources,
    Color color,
    bool batchMode,
    Set<String> selectedIds,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(Spacing.mid.r),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final res = resources[index];
        final resId = res.id ?? '';
        final isSelected = batchMode && selectedIds.contains(resId);
        return Padding(
          padding: EdgeInsets.only(bottom: Spacing.sm.h),
          child: ResourceCard(
            resource: res,
            accentColor: color,
            aspectRatio: 16 / 5,
            isSelected: isSelected,
            isBatchMode: batchMode,
            onTap: batchMode
                ? () {
                    if (resId.isNotEmpty) {
                      ref
                          .read(selectedResourceIdsProvider.notifier)
                          .toggle(resId);
                    }
                  }
                : () => showResourceDetailDialog(
                      context,
                      ref,
                      resource: res,
                      accentColor: color,
                    ),
            onViewLargeImage: res.hasThumbnail && res.modality == 'visual'
                ? () => showImageLightbox(context, imageUrl: res.thumbnailUrl)
                : null,
            onViewDetail: () => showResourceDetailDialog(
              context,
              ref,
              resource: res,
              accentColor: color,
            ),
            onEdit: () => showResourceFormDialog(
              context,
              ref,
              libraryType: ResourceLibraryType.values
                  .firstWhere(
                    (t) => t.name == res.libraryType,
                    orElse: () => ResourceLibraryType.character,
                  ),
              accentColor: color,
              initial: res,
            ),
            onCopy: () => ref.read(resourceListProvider.notifier).addResource(
                  res.copyWith(id: null, name: '${res.name}(副本)'),
                ),
            onDelete: res.id != null && res.id!.isNotEmpty
                ? () => ref.read(resourceListProvider.notifier).removeResource(res.id!)
                : null,
          ),
        );
      },
    );
  }

  double _cardAspectRatio(double thumbAspect) {
    if (thumbAspect >= 1.0) return thumbAspect * 0.55;
    return thumbAspect * 0.42;
  }
}

/// 骨架屏卡片：带脉冲动画的加载占位
class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard({
    required this.accentColor,
    this.delay = 0,
  });

  final Color accentColor;
  final int delay;

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final opacity = 0.04 + _ctrl.value * 0.08;
        return Container(
          decoration: BoxDecoration(
            color: widget.accentColor.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: opacity * 0.5),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(RadiusTokens.lg.r),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(Spacing.md.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMutedDark,
                          borderRadius:
                              BorderRadius.circular(RadiusTokens.xs.r),
                        ),
                      ),
                      SizedBox(height: Spacing.sm.h),
                      Container(
                        height: 8.h,
                        width: 50.w,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMutedDark
                              .withValues(alpha: 0.5),
                          borderRadius:
                              BorderRadius.circular(RadiusTokens.xs.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
