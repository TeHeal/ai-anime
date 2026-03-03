import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/generation_center/batch_action_bar.dart';
import 'package:anime_ui/pub/widgets/text_gen/text_gen_config.dart';
import 'package:anime_ui/pub/widgets/text_gen/text_gen_trigger.dart';
import 'package:anime_ui/pub/widgets/voice_gen/voice_gen_config.dart';
import 'package:anime_ui/pub/widgets/voice_gen/voice_gen_trigger.dart';

import '../models/resource_category.dart';
import '../providers/provider.dart';
import '../dialogs/resource_detail_dialog.dart';
import '../dialogs/resource_form_dialog.dart';
import 'resource_card.dart';
import 'resource_filter_bar.dart';

/// 素材库文本生成配置（提示词库/风格指令库）
TextGenConfig _textGenConfigForLibrary(
  ResourceLibraryType lib,
  Color accentColor,
  Future<void> Function() onReload,
) {
  Future<void> onComplete(String result) async => onReload();
  if (lib == ResourceLibraryType.styleGuide) {
    return TextGenConfig.styleGuide(
      accentColor: accentColor,
      onComplete: onComplete,
    );
  }
  return TextGenConfig.newPrompt(
    accentColor: accentColor,
    category: lib.name,
    onComplete: onComplete,
  );
}

/// 素材库音色生成配置
VoiceGenConfig _voiceGenConfigForLibrary(Color accentColor, WidgetRef ref) {
  return VoiceGenConfig.voiceLibrary(
    accentColor: accentColor,
    onSaved: (_) async {
      await ref.read(resourceListProvider.notifier).load();
    },
  );
}

/// 内容区：资源网格（风格已合并到顶级 Tab，此处仅展示素材库资源）
class ContentArea extends ConsumerStatefulWidget {
  const ContentArea({super.key, required this.modality});

  final ResourceModality modality;

  @override
  ConsumerState<ContentArea> createState() => _ContentAreaState();
}

class _ContentAreaState extends ConsumerState<ContentArea> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(resourceListProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final libraryType = ref.watch(selectedLibraryTypeProvider);
    final resources = ref.watch(filteredResourceListProvider);
    final viewMode = ref.watch(viewModeProvider);
    final batchMode = ref.watch(batchModeProvider);
    final selectedIds = ref.watch(selectedResourceIdsProvider);
    final color = widget.modality.color;
    final isTextOrAudio = widget.modality == ResourceModality.text ||
        widget.modality == ResourceModality.audio;
    final cardAspectRatio = isTextOrAudio ? 1.0 : 3 / 2;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          ResourceFilterBar(accentColor: color),
          _ContentToolbar(
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
                  _BatchMoveButton(
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
            child: resources.isEmpty
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
                if (hasUpload)
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
                    config: _voiceGenConfigForLibrary(color, ref),
                    label: '创建音色',
                    icon: AppIcons.mic,
                    style: FilledButton.styleFrom(backgroundColor: color),
                  ),
                if (hasAiGen && isText)
                  TextGenTrigger(
                    config: _textGenConfigForLibrary(
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

/// 内容工具栏：数量、视图切换、批量模式、添加按钮
class _ContentToolbar extends ConsumerWidget {
  const _ContentToolbar({
    required this.totalCount,
    required this.accentColor,
    required this.libraryType,
    required this.viewMode,
    required this.batchMode,
    required this.selectedCount,
  });

  final int totalCount;
  final Color accentColor;
  final ResourceLibraryType libraryType;
  final ViewMode viewMode;
  final bool batchMode;
  final int selectedCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modes = libraryType.availableAddModes;
    final hasUpload = modes.contains(AddMode.upload);
    final hasAiGen = modes.contains(AddMode.aiGenerate);
    final isVisual = libraryType.modality == ResourceModality.visual;
    final isAudio = libraryType.modality == ResourceModality.audio;
    final isText = libraryType.modality == ResourceModality.text;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.mid.w,
        vertical: Spacing.xs.h,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            '$totalCount 个素材',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.muted,
            ),
          ),
          SizedBox(width: Spacing.lg.w),
          IconButton(
            onPressed: () =>
                ref.read(viewModeProvider.notifier).set(ViewMode.grid),
            icon: Icon(
              AppIcons.gallery,
              size: 18.r,
              color: viewMode == ViewMode.grid
                  ? accentColor
                  : AppColors.muted,
            ),
            tooltip: '网格',
          ),
          IconButton(
            onPressed: () =>
                ref.read(viewModeProvider.notifier).set(ViewMode.list),
            icon: Icon(
              AppIcons.list,
              size: 18.r,
              color: viewMode == ViewMode.list
                  ? accentColor
                  : AppColors.muted,
            ),
            tooltip: '列表',
          ),
          IconButton(
            onPressed: () =>
                ref.read(viewModeProvider.notifier).set(ViewMode.preview),
            icon: Icon(
              Icons.grid_view_rounded,
              size: 18.r,
              color: viewMode == ViewMode.preview
                  ? accentColor
                  : AppColors.muted,
            ),
            tooltip: '预览',
          ),
          SizedBox(width: Spacing.sm.w),
          IconButton(
            onPressed: () {
              ref.read(batchModeProvider.notifier).set(!batchMode);
              if (batchMode) {
                ref.read(selectedResourceIdsProvider.notifier).clear();
              }
            },
            icon: Icon(
              AppIcons.checkOutline,
              size: 18.r,
              color: batchMode ? accentColor : AppColors.muted,
            ),
            tooltip: batchMode ? '退出批量' : '批量选择',
          ),
          const Spacer(),
          if (hasUpload)
            TextButton.icon(
              onPressed: () => showResourceUploadDialog(
                context,
                ref,
                libraryType: libraryType,
                accentColor: accentColor,
              ),
              icon: Icon(AppIcons.upload, size: 16.r),
              label: const Text('上传'),
              style: TextButton.styleFrom(foregroundColor: accentColor),
            ),
          if (hasUpload && hasAiGen) SizedBox(width: Spacing.sm.w),
          if (hasAiGen && isVisual)
            FilledButton.icon(
              onPressed: () => showResourceAiGenerateDialog(
                context,
                ref,
                libraryType: libraryType,
                accentColor: accentColor,
              ),
              icon: Icon(AppIcons.magicStick, size: 16.r),
              label: const Text('AI 生成'),
              style: FilledButton.styleFrom(backgroundColor: accentColor),
            ),
          if (hasAiGen && isAudio)
            VoiceGenTrigger(
              config: _voiceGenConfigForLibrary(accentColor, ref),
              label: '创建音色',
              icon: AppIcons.mic,
              style: FilledButton.styleFrom(backgroundColor: accentColor),
            ),
          if (hasAiGen && isText)
            TextGenTrigger(
              config: _textGenConfigForLibrary(
                libraryType,
                accentColor,
                () => ref.read(resourceListProvider.notifier).load(),
              ),
              label: libraryType == ResourceLibraryType.styleGuide
                  ? 'AI 生成风格指令'
                  : 'AI 生成提示词',
              icon: AppIcons.magicStick,
              style: FilledButton.styleFrom(backgroundColor: accentColor),
            ),
        ],
      ),
    );
  }
}

/// 批量移动按钮：选择目标子库后执行移动
class _BatchMoveButton extends ConsumerWidget {
  const _BatchMoveButton({
    required this.selectedCount,
    required this.selectedIds,
    required this.libraryType,
    required this.accentColor,
    required this.onComplete,
  });

  final int selectedCount;
  final Set<String> selectedIds;
  final ResourceLibraryType libraryType;
  final Color accentColor;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetLibs = ResourceLibraryType.forModalityInResources(
      libraryType.modality,
    ).where((lib) => lib != libraryType).toList();

    if (targetLibs.isEmpty) return const SizedBox.shrink();

    return OutlinedButton.icon(
      onPressed: selectedCount == 0
          ? null
          : () => _showMoveDialog(context, ref, targetLibs),
      icon: Icon(Icons.drive_file_move_outline, size: 16.r),
      label: Text('批量移动 ($selectedCount)'),
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: BorderSide(color: accentColor.withValues(alpha: 0.6)),
      ),
    );
  }

  Future<void> _showMoveDialog(
    BuildContext context,
    WidgetRef ref,
    List<ResourceLibraryType> targetLibs,
  ) async {
    final target = await showDialog<ResourceLibraryType>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('移动到子库'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '将选中的 $selectedCount 个素材移动到：',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.muted,
              ),
            ),
            SizedBox(height: Spacing.md.h),
            ...targetLibs.map((lib) => ListTile(
                  leading: Icon(lib.icon, size: 20.r, color: accentColor),
                  title: Text(lib.label),
                  onTap: () => Navigator.pop(ctx, lib),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    if (target != null && context.mounted) {
      await ref.read(resourceListProvider.notifier).batchMoveToLibrary(
            selectedIds,
            target.name,
            target.modality.name,
          );
      if (context.mounted) onComplete();
    }
  }
}
