import 'package:flutter/material.dart';
import 'package:anime_ui/pub/theme/colors.dart';

class SelectCard extends StatelessWidget {
  const SelectCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.selected,
    this.onTap,
    this.action,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surface : AppColors.surface.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey[700]!,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: selected ? AppColors.primary : Colors.grey[500],
                  size: 28,
                ),
                const SizedBox(height: 12),
              ],
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 8),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
