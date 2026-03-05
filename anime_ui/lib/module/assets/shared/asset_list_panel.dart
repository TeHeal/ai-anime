import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 资产列表面板：统计行 + 可选多选 + ListView
///
/// 用于 locations、props 等资产列表的通用布局。
/// 当 [onBatchConfirm] 非 null 时启用多选能力。
class AssetListPanel extends StatefulWidget {
  const AssetListPanel({
    super.key,
    required this.totalCount,
    required this.confirmedCount,
    required this.countLabel,
    required this.itemCount,
    required this.itemBuilder,
    this.onBatchConfirm,
    this.allIds = const [],
  });

  final int totalCount;
  final int confirmedCount;

  /// 如 "个场景"、"个道具"
  final String countLabel;
  final int itemCount;
  final Widget Function(BuildContext context, int index, bool multiSelect,
      Set<String> selectedIds) itemBuilder;

  /// 非 null 时在统计行显示「多选」入口，并支持批量确认
  final void Function(List<String> ids)? onBatchConfirm;

  /// 所有可选项的 ID 列表，用于全选
  final List<String> allIds;

  @override
  State<AssetListPanel> createState() => AssetListPanelState();
}

class AssetListPanelState extends State<AssetListPanel> {
  bool _multiSelect = false;
  final Set<String> _selectedIds = {};

  bool get _supportMultiSelect => widget.onBatchConfirm != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatsRow(),
        if (_multiSelect) _buildBatchBar(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
            itemCount: widget.itemCount,
            itemBuilder: (ctx, i) =>
                widget.itemBuilder(ctx, i, _multiSelect, _selectedIds),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.lg.w, Spacing.sm.h, Spacing.lg.w, Spacing.sm.h,
      ),
      child: Row(
        children: [
          Text(
            '${widget.totalCount} ${widget.countLabel}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Icon(AppIcons.check, size: 12.r, color: AppColors.success),
          Text(
            ' ${widget.confirmedCount}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (_multiSelect) ...[
            SizedBox(width: Spacing.md.w),
            Text(
              '已选 ${_selectedIds.length}',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
            const Spacer(),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() {
                  _multiSelect = false;
                  _selectedIds.clear();
                }),
                child: Text(
                  '取消多选',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ] else if (_supportMultiSelect) ...[
            const Spacer(),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _multiSelect = true),
                child: Text(
                  '多选',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBatchBar() {
    final allSelected = widget.allIds.isNotEmpty &&
        widget.allIds.every((id) => _selectedIds.contains(id));

    return Padding(
      padding: EdgeInsets.fromLTRB(
          Spacing.lg.w, 0, Spacing.lg.w, Spacing.sm.h),
      child: Wrap(
        spacing: Spacing.sm.w,
        runSpacing: Spacing.sm.h,
        children: [
          OutlinedButton(
            onPressed: () {
              setState(() {
                if (allSelected) {
                  _selectedIds.removeWhere(widget.allIds.toSet().contains);
                } else {
                  _selectedIds.addAll(widget.allIds);
                }
              });
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.sm.w,
                vertical: Spacing.xs.h,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(allSelected ? '取消选择' : '当前全选'),
          ),
          OutlinedButton.icon(
            onPressed: _selectedIds.isEmpty
                ? null
                : () {
                    widget.onBatchConfirm?.call(_selectedIds.toList());
                    setState(() {
                      _selectedIds.clear();
                      _multiSelect = false;
                    });
                  },
            icon: Icon(AppIcons.check, size: 14.r),
            label: Text(
              _selectedIds.isEmpty
                  ? '确认'
                  : '确认 ${_selectedIds.length}',
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.sm.w,
                vertical: Spacing.xs.h,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  /// 供子组件调用：切换某个 ID 的选中状态
  void toggleId(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }
}
