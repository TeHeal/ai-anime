import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/models/dashboard.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

/// 资产概况卡片
class AssetOverview extends StatelessWidget {
  const AssetOverview({super.key, required this.summary});

  final AssetSummary? summary;

  @override
  Widget build(BuildContext context) {
    if (summary == null) return const SizedBox.shrink();
    final s = summary!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.category,
                size: 16,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              const Text(
                '资产概况',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => context.go(Routes.assets),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '管理资产',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 4),
                    Icon(AppIcons.chevronRight, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _assetItem(
                    AppIcons.person, '角色',
                    s.charactersConfirmed, s.charactersTotal),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _assetItem(
                    AppIcons.landscape, '场景',
                    s.locationsConfirmed, s.locationsTotal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _assetItem(
      IconData icon, String label, int confirmed, int total) {
    final allDone = confirmed == total && total > 0;
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          '$label ',
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
        Text(
          '$confirmed',
          style: TextStyle(
            color: allDone
                ? const Color(0xFF22C55E)
                : AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '/$total',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }
}
