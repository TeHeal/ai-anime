import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/app_search_field.dart';
import 'package:anime_ui/module/assets/characters/providers/selection.dart';

/// 角色工具栏：搜索、筛选（状态/重要性/角色类型）、AI 提取、导入小传、手动添加
class CharacterToolbar extends ConsumerStatefulWidget {
  const CharacterToolbar({
    super.key,
    required this.onExtract,
    required this.onImportProfile,
    required this.onAdd,
  });

  final VoidCallback onExtract;
  final VoidCallback onImportProfile;
  final VoidCallback onAdd;

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
    final nameSearch = ref.watch(charNameSearchProvider);

    if (nameSearch.isEmpty && _searchCtrl.text.isNotEmpty) {
      _searchCtrl.clear();
    }

    final hasFilter = statusFilter != null ||
        importanceFilter != null ||
        roleTypeFilter != null ||
        nameSearch.isNotEmpty;

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
                _buildStatusFilter(statusFilter),
                _buildImportanceFilter(importanceFilter),
                _buildRoleTypeFilter(roleTypeFilter),
                if (hasFilter)
                  TextButton(
                    onPressed: () {
                      ref.read(charStatusFilterProvider.notifier).set(null);
                      ref.read(charImportanceFilterProvider.notifier).set(null);
                      ref.read(charRoleTypeFilterProvider.notifier).set(null);
                      ref.read(charNameSearchProvider.notifier).set('');
                    },
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
          OutlinedButton.icon(
            onPressed: widget.onImportProfile,
            icon: Icon(AppIcons.upload, size: 16.r),
            label: const Text('导入小传'),
          ),
          SizedBox(width: Spacing.sm.w),
          FilledButton.icon(
            onPressed: widget.onExtract,
            icon: Icon(AppIcons.autoAwesome, size: 16.r),
            label: const Text('AI 提取'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
          SizedBox(width: Spacing.sm.w),
          IconButton(
            icon: Icon(AppIcons.add, size: 20.r, color: AppColors.primary),
            tooltip: '手动添加',
            onPressed: widget.onAdd,
          ),
        ],
      ),
    );
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
}
