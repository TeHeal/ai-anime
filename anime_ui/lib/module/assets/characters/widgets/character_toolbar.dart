import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/dashboard.dart';
import 'package:anime_ui/pub/widgets/app_search_field.dart';
import 'package:anime_ui/module/dashboard/providers/provider.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';
import 'package:anime_ui/module/assets/characters/providers/selection.dart';

/// 角色工具栏：搜索、筛选（状态/重要性/角色类型/一致性/集数）、导入小传、创建角色、AI 生成
class CharacterToolbar extends ConsumerStatefulWidget {
  const CharacterToolbar({
    super.key,
    required this.onImportProfile,
    required this.onAdd,
    this.onAiGenerate,
  });

  final VoidCallback onImportProfile;
  final VoidCallback onAdd;
  final VoidCallback? onAiGenerate;

  @override
  ConsumerState<CharacterToolbar> createState() => _CharacterToolbarState();
}

class _CharacterToolbarState extends ConsumerState<CharacterToolbar> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(
      text: ref.read(charNameSearchProvider),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusFilter = ref.watch(charStatusFilterProvider);
    final importanceFilter = ref.watch(charImportanceFilterProvider);
    final roleTypeFilter = ref.watch(charRoleTypeFilterProvider);
    final consistencyFilter = ref.watch(charConsistencyFilterProvider);
    final episodeFilter = ref.watch(assetEpisodeFilterProvider);
    final nameSearch = ref.watch(charNameSearchProvider);

    if (nameSearch.isEmpty && _searchCtrl.text.isNotEmpty) {
      _searchCtrl.clear();
    }

    final hasFilter = statusFilter != null ||
        importanceFilter != null ||
        roleTypeFilter != null ||
        consistencyFilter != null ||
        episodeFilter != null ||
        nameSearch.isNotEmpty;

    // 从项目 Dashboard 获取集列表
    final episodes = _getEpisodes();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.lg.w,
        vertical: Spacing.sm.h,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          AppSearchField(
            controller: _searchCtrl,
            hintText: '搜索角色名称…',
            width: 200.w,
            height: 34.h,
            onChanged: (v) => ref.read(charNameSearchProvider.notifier).set(v),
          ),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Wrap(
              spacing: Spacing.sm.w,
              runSpacing: Spacing.sm.h,
              children: [
                if (episodes.isNotEmpty)
                  _buildEpisodeFilter(episodeFilter, episodes),
                _buildStatusFilter(statusFilter),
                _buildImportanceFilter(importanceFilter),
                _buildRoleTypeFilter(roleTypeFilter),
                _buildConsistencyFilter(consistencyFilter),
                if (hasFilter)
                  TextButton(
                    onPressed: _resetAll,
                    child: Text(
                      '重置',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          FilledButton.icon(
            onPressed: widget.onImportProfile,
            icon: Icon(AppIcons.upload, size: 16.r),
            label: const Text('导入小传'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh,
              foregroundColor: AppColors.onSurface.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          FilledButton.icon(
            onPressed: widget.onAdd,
            icon: Icon(AppIcons.add, size: 16.r),
            label: const Text('创建角色'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              foregroundColor: AppColors.primary,
            ),
          ),
          if (widget.onAiGenerate != null) ...[
            SizedBox(width: Spacing.sm.w),
            FilledButton.icon(
              onPressed: widget.onAiGenerate,
              icon: Icon(AppIcons.magicStick, size: 16.r),
              label: const Text('AI 生成'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  void _resetAll() {
    ref.read(charStatusFilterProvider.notifier).set(null);
    ref.read(charImportanceFilterProvider.notifier).set(null);
    ref.read(charRoleTypeFilterProvider.notifier).set(null);
    ref.read(charConsistencyFilterProvider.notifier).set(null);
    ref.read(assetEpisodeFilterProvider.notifier).set(null);
    ref.read(charNameSearchProvider.notifier).set('');
  }

  /// 从 Dashboard 获取项目集列表
  List<DashboardEpisode> _getEpisodes() {
    final dash = ref.watch(dashboardProvider);
    return dash.value?.episodes ?? [];
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T?>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          hint: Text(
            hint,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          dropdownColor: AppColors.surfaceContainer,
          icon: Icon(
            AppIcons.expandMore,
            size: 16.r,
            color: AppColors.onSurface.withValues(alpha: 0.55),
          ),
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          isDense: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildEpisodeFilter(int? current, List<DashboardEpisode> episodes) {
    return _buildDropdown<int>(
      value: current,
      hint: '全部集',
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('全部集')),
        ...episodes.map(
          (ep) => DropdownMenuItem<int?>(
            value: ep.sortIndex + 1,
            child: Text('第${ep.sortIndex + 1}集'),
          ),
        ),
      ],
      onChanged: (v) => ref.read(assetEpisodeFilterProvider.notifier).set(v),
    );
  }

  Widget _buildStatusFilter(String? current) {
    return _buildDropdown<String>(
      value: current,
      hint: '全部状态',
      items: const [
        DropdownMenuItem(value: null, child: Text('全部状态')),
        DropdownMenuItem(value: 'skeleton', child: Text('骨架')),
        DropdownMenuItem(value: 'draft', child: Text('待确认')),
        DropdownMenuItem(value: 'confirmed', child: Text('已确认')),
      ],
      onChanged: (v) => ref.read(charStatusFilterProvider.notifier).set(v),
    );
  }

  Widget _buildImportanceFilter(String? current) {
    return _buildDropdown<String>(
      value: current,
      hint: '重要程度',
      items: const [
        DropdownMenuItem(value: null, child: Text('重要程度')),
        DropdownMenuItem(value: 'main', child: Text('主角')),
        DropdownMenuItem(value: 'support', child: Text('配角')),
        DropdownMenuItem(value: 'functional', child: Text('功能')),
        DropdownMenuItem(value: 'extra', child: Text('路人')),
      ],
      onChanged: (v) =>
          ref.read(charImportanceFilterProvider.notifier).set(v),
    );
  }

  Widget _buildRoleTypeFilter(String? current) {
    return _buildDropdown<String>(
      value: current,
      hint: '角色类型',
      items: const [
        DropdownMenuItem(value: null, child: Text('角色类型')),
        DropdownMenuItem(value: 'human', child: Text('人类')),
        DropdownMenuItem(value: 'nonhuman', child: Text('非人')),
        DropdownMenuItem(value: 'personified', child: Text('拟人')),
        DropdownMenuItem(value: 'narrator', child: Text('旁白')),
      ],
      onChanged: (v) => ref.read(charRoleTypeFilterProvider.notifier).set(v),
    );
  }

  Widget _buildConsistencyFilter(String? current) {
    return _buildDropdown<String>(
      value: current,
      hint: '一致性要求',
      items: const [
        DropdownMenuItem(value: null, child: Text('一致性要求')),
        DropdownMenuItem(value: 'strong', child: Text('强')),
        DropdownMenuItem(value: 'medium', child: Text('中')),
        DropdownMenuItem(value: 'weak', child: Text('弱')),
      ],
      onChanged: (v) =>
          ref.read(charConsistencyFilterProvider.notifier).set(v),
    );
  }
}
