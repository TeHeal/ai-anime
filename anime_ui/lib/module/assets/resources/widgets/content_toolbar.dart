import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/text_gen/text_gen_config.dart';
import 'package:anime_ui/pub/widgets/text_gen/text_gen_trigger.dart';
import 'package:anime_ui/pub/widgets/voice_gen/voice_gen_config.dart';
import 'package:anime_ui/pub/widgets/voice_gen/voice_gen_trigger.dart';

import '../models/resource_category.dart';
import '../providers/provider.dart';
import '../dialogs/resource_form_dialog.dart';

/// 素材库文本生成配置（提示词库/风格指令库）
TextGenConfig textGenConfigForLibrary(
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
VoiceGenConfig voiceGenConfigForLibrary(Color accentColor, WidgetRef ref) {
  return VoiceGenConfig.voiceLibrary(
    accentColor: accentColor,
    onSaved: (_) async {
      await ref.read(resourceListProvider.notifier).load();
    },
  );
}

/// 内容工具栏：数量、视图切换、批量模式、添加按钮
class ContentToolbar extends ConsumerWidget {
  const ContentToolbar({
    super.key,
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
    final hasBatchUpload = modes.contains(AddMode.batchUpload);
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
          if (hasBatchUpload)
            TextButton.icon(
              onPressed: () => showResourceBatchUploadDialog(
                context,
                ref,
                libraryType: libraryType,
                accentColor: accentColor,
              ),
              icon: Icon(AppIcons.upload, size: 16.r),
              label: const Text('批量导入'),
              style: TextButton.styleFrom(foregroundColor: accentColor),
            ),
          if ((hasUpload || hasBatchUpload) && hasAiGen)
            SizedBox(width: Spacing.sm.w),
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
              config: voiceGenConfigForLibrary(accentColor, ref),
              label: 'AI 生成',
              icon: AppIcons.magicStick,
              style: FilledButton.styleFrom(backgroundColor: accentColor),
            ),
          if (hasAiGen && isText)
            TextGenTrigger(
              config: textGenConfigForLibrary(
                libraryType,
                accentColor,
                () => ref.read(resourceListProvider.notifier).load(),
              ),
              label: 'AI 生成',
              icon: AppIcons.magicStick,
              style: FilledButton.styleFrom(backgroundColor: accentColor),
            ),
        ],
      ),
    );
  }
}

/// 批量移动按钮：选择目标子库后执行移动
class BatchMoveButton extends ConsumerWidget {
  const BatchMoveButton({
    super.key,
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
