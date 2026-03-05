import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/generation_center/batch_action_bar.dart';
import 'package:anime_ui/pub/widgets/image_lightbox.dart';
import 'package:anime_ui/pub/widgets/text_gen/text_gen_dialog.dart';
import 'package:anime_ui/pub/widgets/voice_gen/voice_gen_dialog.dart';

import '../models/resource_category.dart';
import '../providers/provider.dart';
import '../dialogs/resource_detail_dialog.dart';
import '../dialogs/resource_form_dialog.dart';
import 'content_toolbar.dart';
import 'resource_card.dart' show isAudioResource, isTextResource;
import 'resource_grid_card.dart';
import 'resource_list_tile.dart';
import 'resource_preview_card.dart';
import 'audio_grid_card.dart';
import 'audio_list_tile.dart';
import 'audio_preview_card.dart';
import 'text_grid_card.dart';
import 'text_list_tile.dart';
import 'text_preview_card.dart';
import 'empty_guide_card.dart';
import 'resource_filter_bar.dart';
import 'skeleton_card.dart';

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
                ? _buildLoadingSkeleton(color)
                : resources.isEmpty
                    ? _buildEmpty(context, libraryType, color)
                    : _buildContent(
                        context,
                        resources,
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
  Widget _buildLoadingSkeleton(Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = Breakpoints.columnCountForWidth(
          constraints.maxWidth,
          maxCols: 6,
        );
        return GridView.builder(
          padding: EdgeInsets.all(Spacing.mid.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: Spacing.gridGap.w,
            mainAxisSpacing: Spacing.gridGap.h,
            childAspectRatio: 3 / 4,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            return SkeletonCard(
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
    Color color,
    ViewMode viewMode,
    bool batchMode,
    Set<String> selectedIds,
  ) {
    return switch (viewMode) {
      ViewMode.grid => _buildGrid(
          context, resources, color, batchMode, selectedIds),
      ViewMode.list => _buildList(
          context, resources, color, batchMode, selectedIds),
      ViewMode.preview => _buildPreview(
          context, resources, color, batchMode, selectedIds),
    };
  }

  Widget _buildEmpty(
    BuildContext context,
    ResourceLibraryType libraryType,
    Color color,
  ) {
    final modes = libraryType.availableAddModes;
    final hasUpload = modes.contains(AddMode.upload);
    final hasBatchUpload = modes.contains(AddMode.batchUpload);
    final hasAiGen = modes.contains(AddMode.aiGenerate);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Spacing.xl.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(Spacing.xl.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.02),
                ]),
              ),
              child: Icon(libraryType.icon, size: 36.r,
                  color: color.withValues(alpha: 0.4)),
            ),
            SizedBox(height: Spacing.lg.h),
            Text('${libraryType.label}暂无素材',
              style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.muted, fontWeight: FontWeight.w600)),
            SizedBox(height: Spacing.xs.h),
            Text('选择一种方式添加第一个素材',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mutedDark)),
            if (hasUpload || hasBatchUpload || hasAiGen) ...[
              SizedBox(height: Spacing.xl.h),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Spacing.md.w,
                runSpacing: Spacing.md.h,
                children: [
                  if (hasUpload)
                    EmptyGuideCard(
                      icon: AppIcons.upload, label: '上传文件', accent: color,
                      onTap: () => showResourceUploadDialog(context, ref,
                          libraryType: libraryType, accentColor: color)),
                  if (hasBatchUpload)
                    EmptyGuideCard(
                      icon: AppIcons.upload, label: '批量导入', accent: color,
                      onTap: () => showResourceBatchUploadDialog(context, ref,
                          libraryType: libraryType, accentColor: color)),
                  if (hasAiGen)
                    EmptyGuideCard(
                      icon: AppIcons.magicStick, label: 'AI 生成',
                      accent: color, filled: true,
                      onTap: () => _openAiGenerate(libraryType, color)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openAiGenerate(ResourceLibraryType libraryType, Color color) {
    switch (libraryType.modality) {
      case ResourceModality.visual:
        showResourceAiGenerateDialog(context, ref,
            libraryType: libraryType, accentColor: color);
      case ResourceModality.audio:
        VoiceGenDialog.show(context, ref,
            config: voiceGenConfigForLibrary(color, ref));
      case ResourceModality.text:
        TextGenDialog.show(context, ref,
            config: textGenConfigForLibrary(libraryType, color,
                () => ref.read(resourceListProvider.notifier).load()));
    }
  }

  /// Grid 灵感墙：纯图卡片，4~6 列，3:4 竖向比例
  Widget _buildGrid(
    BuildContext context,
    List<Resource> resources,
    Color color,
    bool batchMode,
    Set<String> selectedIds,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = Breakpoints.columnCountForWidth(
          constraints.maxWidth,
          maxCols: 6,
        );
        return GridView.builder(
          padding: EdgeInsets.all(Spacing.mid.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: Spacing.gridGap.w,
            mainAxisSpacing: Spacing.gridGap.h,
            childAspectRatio: 3 / 4,
          ),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final res = resources[index];
            final resId = res.id ?? '';
            final isSelected = batchMode && selectedIds.contains(resId);
            if (isAudioResource(res)) {
              return AudioGridCard(
                resource: res,
                accentColor: color,
                isSelected: isSelected,
                isBatchMode: batchMode,
                onTap: _onTap(res, resId, color, batchMode),
                onViewDetail: () => _openDetail(res, color),
                onEdit: () => _openEdit(res, color),
                onDelete: _onDelete(res),
              );
            }
            if (isTextResource(res)) {
              return TextGridCard(
                resource: res,
                accentColor: color,
                isSelected: isSelected,
                isBatchMode: batchMode,
                onTap: _onTap(res, resId, color, batchMode),
                onViewDetail: () => _openDetail(res, color),
                onEdit: () => _openEdit(res, color),
                onCopy: () => _doCopy(res),
                onDelete: _onDelete(res),
              );
            }
            return ResourceGridCard(
              resource: res,
              accentColor: color,
              isSelected: isSelected,
              isBatchMode: batchMode,
              onTap: _onTap(res, resId, color, batchMode),
              onViewLargeImage: _onViewLargeImage(res),
              onEdit: () => _openEdit(res, color),
              onDelete: _onDelete(res),
            );
          },
        );
      },
    );
  }

  /// List 工作台：横向表格行，用分割线分隔
  Widget _buildList(
    BuildContext context,
    List<Resource> resources,
    Color color,
    bool batchMode,
    Set<String> selectedIds,
  ) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
      itemCount: resources.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.divider,
      ),
      itemBuilder: (context, index) {
        final res = resources[index];
        final resId = res.id ?? '';
        final isSelected = batchMode && selectedIds.contains(resId);
        if (isAudioResource(res)) {
          return AudioListTile(
            resource: res,
            accentColor: color,
            isSelected: isSelected,
            isBatchMode: batchMode,
            onTap: _onTap(res, resId, color, batchMode),
            onViewDetail: () => _openDetail(res, color),
            onEdit: () => _openEdit(res, color),
            onCopy: () => _doCopy(res),
            onDelete: _onDelete(res),
          );
        }
        if (isTextResource(res)) {
          return TextListTile(
            resource: res,
            accentColor: color,
            isSelected: isSelected,
            isBatchMode: batchMode,
            onTap: _onTap(res, resId, color, batchMode),
            onViewDetail: () => _openDetail(res, color),
            onEdit: () => _openEdit(res, color),
            onCopy: () => _doCopy(res),
            onDelete: _onDelete(res),
          );
        }
        return ResourceListTile(
          resource: res,
          accentColor: color,
          isSelected: isSelected,
          isBatchMode: batchMode,
          onTap: _onTap(res, resId, color, batchMode),
          onViewLargeImage: _onViewLargeImage(res),
          onViewDetail: () => _openDetail(res, color),
          onEdit: () => _openEdit(res, color),
          onCopy: () => _doCopy(res),
          onDelete: _onDelete(res),
        );
      },
    );
  }

  /// Preview 审阅：2 列大图 + 详情
  Widget _buildPreview(
    BuildContext context,
    List<Resource> resources,
    Color color,
    bool batchMode,
    Set<String> selectedIds,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = Breakpoints.columnCountForWidth(
          constraints.maxWidth,
          maxCols: 2,
        );
        return GridView.builder(
          padding: EdgeInsets.all(Spacing.mid.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: Spacing.lg.w,
            mainAxisSpacing: Spacing.lg.h,
            childAspectRatio: 0.62,
          ),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final res = resources[index];
            final resId = res.id ?? '';
            final isSelected = batchMode && selectedIds.contains(resId);
            if (isAudioResource(res)) {
              return AudioPreviewCard(
                resource: res,
                accentColor: color,
                isSelected: isSelected,
                isBatchMode: batchMode,
                onTap: _onTap(res, resId, color, batchMode),
                onViewDetail: () => _openDetail(res, color),
                onEdit: () => _openEdit(res, color),
                onCopy: () => _doCopy(res),
                onDelete: _onDelete(res),
              );
            }
            if (isTextResource(res)) {
              return TextPreviewCard(
                resource: res,
                accentColor: color,
                isSelected: isSelected,
                isBatchMode: batchMode,
                onTap: _onTap(res, resId, color, batchMode),
                onViewDetail: () => _openDetail(res, color),
                onEdit: () => _openEdit(res, color),
                onCopy: () => _doCopy(res),
                onDelete: _onDelete(res),
              );
            }
            return ResourcePreviewCard(
              resource: res,
              accentColor: color,
              isSelected: isSelected,
              isBatchMode: batchMode,
              onTap: _onTap(res, resId, color, batchMode),
              onViewLargeImage: _onViewLargeImage(res),
              onViewDetail: () => _openDetail(res, color),
              onEdit: () => _openEdit(res, color),
              onCopy: () => _doCopy(res),
              onDelete: _onDelete(res),
            );
          },
        );
      },
    );
  }

  // ── 回调工厂 ──

  VoidCallback _onTap(
    Resource res,
    String resId,
    Color color,
    bool batchMode,
  ) {
    if (batchMode) {
      return () {
        if (resId.isNotEmpty) {
          ref.read(selectedResourceIdsProvider.notifier).toggle(resId);
        }
      };
    }
    return () => _openDetail(res, color);
  }

  VoidCallback? _onViewLargeImage(Resource res) {
    if (res.hasThumbnail && res.modality == 'visual') {
      return () => showImageLightbox(context, imageUrl: res.thumbnailUrl);
    }
    return null;
  }

  void _openDetail(Resource res, Color color) {
    showResourceDetailDialog(context, ref, resource: res, accentColor: color);
  }

  void _openEdit(Resource res, Color color) {
    showResourceFormDialog(
      context,
      ref,
      libraryType: ResourceLibraryType.values.firstWhere(
        (t) => t.name == res.libraryType,
        orElse: () => ResourceLibraryType.character,
      ),
      accentColor: color,
      initial: res,
    );
  }

  void _doCopy(Resource res) {
    ref
        .read(resourceListProvider.notifier)
        .addResource(res.copyWith(id: null, name: '${res.name}(副本)'));
  }

  VoidCallback? _onDelete(Resource res) {
    if (res.id != null && res.id!.isNotEmpty) {
      return () =>
          ref.read(resourceListProvider.notifier).removeResource(res.id!);
    }
    return null;
  }
}
