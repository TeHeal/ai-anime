import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';

/// AI 资产提取对话框
class AssetExtractDialog extends ConsumerWidget {
  const AssetExtractDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assetExtractProvider);

    return AlertDialog(
      backgroundColor: AppColors.surfaceMutedDarker,
      title: Text(
        'AI 资产提取',
        style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
      ),
      content: SizedBox(
        width: 560.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.error != null && state.result == null)
              Padding(
                padding: EdgeInsets.only(bottom: Spacing.md.h),
                child: Text(
                  state.error!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            if (state.isLoading && state.result == null)
              _buildLoadingState()
            else if (state.result != null)
              _buildResultState(state, ref)
            else
              _buildIdleState(),
          ],
        ),
      ),
      actions: _buildActions(context, state, ref),
    );
  }

  Widget _buildIdleState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '从剧本中自动提取角色、场景、道具设定。',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
        ),
        SizedBox(height: Spacing.md.h),
        _featureRow(AppIcons.bolt, '结构化预提取', '从已解析剧本直接提取角色名、场景列表'),
        SizedBox(height: Spacing.sm.h),
        _featureRow(AppIcons.sync, '并行 AI 补全', '角色/场景/道具分 3 路同时生成，速度提升 3x'),
        SizedBox(height: Spacing.sm.h),
        _featureRow(AppIcons.mergeType, '智能合并', '自动与已有数据去重，增量更新'),
        SizedBox(height: Spacing.lg.h),
        Text(
          '提取完成后可逐一审核、编辑，确认后写入项目数据。',
          style: AppTextStyles.caption.copyWith(color: AppColors.mutedDark),
        ),
      ],
    );
  }

  Widget _featureRow(IconData icon, String title, String desc) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: AppColors.primary),
        SizedBox(width: Spacing.sm.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title  ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: desc,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        SizedBox(height: Spacing.sm.h),
        _categoryProgress('角色设定', 'pending', null),
        SizedBox(height: Spacing.sm.h),
        _categoryProgress('场景设定', 'pending', null),
        SizedBox(height: Spacing.sm.h),
        _categoryProgress('道具识别', 'pending', null),
        SizedBox(height: Spacing.lg.h),
        Text(
          '3 个 AI 任务并行处理中...',
          style: AppTextStyles.caption.copyWith(color: AppColors.mutedDark),
        ),
        SizedBox(height: Spacing.sm.h),
        const LinearProgressIndicator(),
      ],
    );
  }

  Widget _buildResultState(ExtractState state, WidgetRef ref) {
    final result = state.result!;
    final status = result.status;

    return SizedBox(
      height: 340.h,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (status != null) ...[
              _categoryProgress(
                '角色设定',
                status.characters,
                status.charError,
                count: result.characters.length,
              ),
              SizedBox(height: Spacing.sm.h),
              _categoryProgress(
                '场景设定',
                status.locations,
                status.locError,
                count: result.locations.length,
              ),
              SizedBox(height: Spacing.sm.h),
              _categoryProgress(
                '道具识别',
                status.props,
                status.propError,
                count: result.props.length,
              ),
              SizedBox(height: Spacing.md.h),
              Divider(color: AppColors.onSurface.withValues(alpha: 0.12)),
              SizedBox(height: Spacing.sm.h),
            ],

            if (result.characters.isNotEmpty) ...[
              _sectionTitle('角色', result.characters.length),
              SizedBox(height: Spacing.xs.h),
              ...result.characters.map(
                (c) => _itemTile(
                  icon: AppIcons.person,
                  title: c.name,
                  subtitle: c.appearance.isNotEmpty
                      ? c.appearance
                      : c.personality,
                ),
              ),
              SizedBox(height: Spacing.md.h),
            ],

            if (result.locations.isNotEmpty) ...[
              _sectionTitle('场景', result.locations.length),
              SizedBox(height: Spacing.xs.h),
              ...result.locations.map(
                (l) => _itemTile(
                  icon: AppIcons.landscape,
                  title: '${l.name}（${l.interiorExterior}/${l.time}）',
                  subtitle: l.atmosphere,
                ),
              ),
              SizedBox(height: Spacing.md.h),
            ],

            if (result.props.isNotEmpty) ...[
              _sectionTitle('道具', result.props.length),
              SizedBox(height: Spacing.xs.h),
              ...result.props.map(
                (p) => _itemTile(
                  icon: AppIcons.category,
                  title: p.name,
                  subtitle: p.appearance,
                ),
              ),
            ],

            if (state.error != null)
              Padding(
                padding: EdgeInsets.only(top: Spacing.sm.h),
                child: Text(
                  state.error!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _categoryProgress(
    String label,
    String status,
    String? error, {
    int count = 0,
  }) {
    IconData icon;
    Color color;
    String text;
    Widget? trailing;

    switch (status) {
      case 'done':
        icon = AppIcons.check;
        color = AppColors.success;
        text = '完成（$count 项）';
      case 'error':
        icon = AppIcons.errorOutline;
        color = AppColors.error;
        text = error?.isNotEmpty == true ? '失败: $error' : '失败';
      default: // pending
        icon = AppIcons.hourglassEmpty;
        color = AppColors.warning;
        text = '处理中...';
        trailing = SizedBox(
          width: 14.r,
          height: 14.r,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
    }

    return Row(
      children: [
        Icon(icon, size: 16.r, color: color),
        SizedBox(width: Spacing.sm.w),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
        ),
        const Spacer(),
        if (trailing != null) ...[trailing, SizedBox(width: Spacing.sm.w)],
        Text(
          text,
          style: AppTextStyles.caption.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(width: Spacing.sm.w),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w,
            vertical: Spacing.xxs.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.tiny.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _itemTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: Spacing.xs.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.r, color: AppColors.mutedDarker),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: AppTextStyles.tiny.copyWith(
                      color: AppColors.mutedDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    ExtractState state,
    WidgetRef ref,
  ) {
    final hasResult = state.result != null;
    final status = state.result?.status;
    final hasErrors =
        status != null &&
        (status.characters == 'error' ||
            status.locations == 'error' ||
            status.props == 'error');

    return [
      TextButton(
        onPressed: state.isLoading
            ? null
            : () {
                ref.read(assetExtractProvider.notifier).reset();
                Navigator.of(context).pop();
              },
        child: Text(
          '取消',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
        ),
      ),
      if (hasResult && hasErrors)
        TextButton(
          onPressed: state.isLoading
              ? null
              : () => ref.read(assetExtractProvider.notifier).extract(),
          child: Text(
            '重新提取',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning),
          ),
        ),
      if (hasResult)
        FilledButton(
          onPressed: state.isLoading
              ? null
              : () async {
                  await ref
                      .read(assetExtractProvider.notifier)
                      .confirmAndApply();
                  if (context.mounted) Navigator.of(context).pop();
                },
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('确认导入'),
        )
      else
        FilledButton(
          onPressed: state.isLoading
              ? null
              : () => ref.read(assetExtractProvider.notifier).extract(),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('开始提取'),
        ),
    ];
  }
}
