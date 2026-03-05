import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/app_search_field.dart';

/// 资产工具栏：搜索 + 状态筛选 + 重置 + 新建按钮 + 可选 AI 生成按钮
///
/// 通过回调与父组件状态同步，父组件负责 Provider 绑定
class AssetToolbar extends StatefulWidget {
  const AssetToolbar({
    super.key,
    required this.searchHint,
    required this.addLabel,
    required this.searchValue,
    required this.onSearchChanged,
    required this.statusFilter,
    required this.onStatusFilterChanged,
    required this.onAdd,
    this.onAiGenerate,
    this.aiGenerateLabel = 'AI 生成',
  });

  final String searchHint;
  final String addLabel;
  final String searchValue;
  final ValueChanged<String> onSearchChanged;
  final String? statusFilter;
  final ValueChanged<String?> onStatusFilterChanged;
  final VoidCallback onAdd;

  /// 非 null 时在新建按钮右侧显示 AI 生成按钮
  final VoidCallback? onAiGenerate;
  final String aiGenerateLabel;

  @override
  State<AssetToolbar> createState() => _AssetToolbarState();
}

class _AssetToolbarState extends State<AssetToolbar> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.searchValue);
  }

  @override
  void didUpdateWidget(AssetToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchValue.isEmpty && _searchCtrl.text.isNotEmpty) {
      _searchCtrl.clear();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter =
        widget.statusFilter != null || widget.searchValue.isNotEmpty;

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
            hintText: widget.searchHint,
            width: 200.w,
            height: 34.h,
            onChanged: widget.onSearchChanged,
          ),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Wrap(
              spacing: Spacing.sm.w,
              runSpacing: Spacing.sm.h,
              children: [
                _buildStatusFilter(widget.statusFilter),
                if (hasFilter)
                  TextButton(
                    onPressed: () {
                      widget.onStatusFilterChanged(null);
                      widget.onSearchChanged('');
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
          FilledButton.icon(
            onPressed: widget.onAdd,
            icon: Icon(AppIcons.add, size: 16.r),
            label: Text(widget.addLabel),
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
              label: Text(widget.aiGenerateLabel),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusFilter(String? current) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: current,
          hint: Text(
            '全部状态',
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
          items: const [
            DropdownMenuItem(value: null, child: Text('全部状态')),
            DropdownMenuItem(value: 'skeleton', child: Text('骨架')),
            DropdownMenuItem(value: 'draft', child: Text('待确认')),
            DropdownMenuItem(value: 'confirmed', child: Text('已确认')),
          ],
          onChanged: (v) => widget.onStatusFilterChanged(v),
        ),
      ),
    );
  }
}
