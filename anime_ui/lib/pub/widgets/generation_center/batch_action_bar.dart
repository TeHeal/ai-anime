import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

/// Reusable batch action bar with select-all toggle and a primary action button.
class BatchActionBar extends StatelessWidget {
  final int totalCount;
  final int selectedCount;
  final bool allSelected;
  final VoidCallback onToggleSelectAll;
  final VoidCallback? onBatchAction;
  final String batchLabel;
  final IconData batchIcon;
  final bool batchEnabled;

  const BatchActionBar({
    super.key,
    required this.totalCount,
    required this.selectedCount,
    required this.allSelected,
    required this.onToggleSelectAll,
    this.onBatchAction,
    this.batchLabel = '批量生成',
    this.batchIcon = AppIcons.magicStick,
    this.batchEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildSelectAllChip(),
        const SizedBox(width: 12),
        _buildBatchButton(),
      ],
    );
  }

  Widget _buildSelectAllChip() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onToggleSelectAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: allSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.grey[800]!.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: allSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.grey[700]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                allSelected ? AppIcons.checkOutline : AppIcons.circleOutline,
                size: 14,
                color: allSelected ? AppColors.primary : Colors.grey[400],
              ),
              const SizedBox(width: 6),
              Text(
                allSelected ? '取消全选' : '全选',
                style: TextStyle(
                    fontSize: 12,
                    color:
                        allSelected ? AppColors.primary : Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchButton() {
    final enabled = selectedCount > 0 && batchEnabled;
    return FilledButton.icon(
      onPressed: enabled ? onBatchAction : null,
      icon: Icon(batchIcon, size: 15),
      label: Text('$batchLabel ($selectedCount)'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: Colors.grey[800],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
