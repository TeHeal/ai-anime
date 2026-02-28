import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/colors.dart';

/// 资产列表项：左侧缩略图、名称、副标题、状态芯片、尾部操作
class AssetListItem extends StatelessWidget {
  const AssetListItem({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
    this.thumbnail,
    this.statusChip,
    this.subtitle,
    this.trailing,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? thumbnail;
  final Widget? statusChip;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                if (thumbnail != null) ...[
                  thumbnail!,
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[300],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (statusChip != null) ...[
                  const SizedBox(width: 6),
                  statusChip!,
                ],
                if (trailing != null) ...[
                  const SizedBox(width: 6),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
