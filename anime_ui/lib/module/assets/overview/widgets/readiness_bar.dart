import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/module/assets/overview/providers/overview_provider.dart';

/// 资产就绪度进度条
class ReadinessBar extends StatelessWidget {
  const ReadinessBar({super.key, required this.data});

  final AssetOverviewData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('资产就绪度',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[300])),
              const SizedBox(width: 12),
              if (!data.isLoading)
                Text('${data.totalConfirmed} / ${data.totalAssets}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const Spacer(),
              if (!data.isLoading)
                Text('${data.readinessPct}%',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: data.readinessPct >= 100
                            ? const Color(0xFF22C55E)
                            : AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: data.isLoading ? null : data.readinessPct / 100,
              minHeight: 6,
              backgroundColor: Colors.grey[800],
              color: data.readinessPct >= 100
                  ? const Color(0xFF22C55E)
                  : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip(AppIcons.person, '角色', data.charConfirmed, data.charTotal,
                  const Color(0xFF8B5CF6)),
              const SizedBox(width: 16),
              _chip(AppIcons.landscape, '场景', data.locConfirmed, data.locTotal,
                  const Color(0xFF3B82F6)),
              const SizedBox(width: 16),
              _chip(AppIcons.category, '道具', data.propConfirmed, data.propTotal,
                  const Color(0xFFF97316)),
              const SizedBox(width: 16),
              _chip(AppIcons.mic, '音色', data.voiceConfigured, data.voiceNeeded,
                  const Color(0xFF06B6D4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(
      IconData icon, String label, int done, int total, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text('$label ',
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        Text('$done',
            style: TextStyle(
                color: done == total && total > 0
                    ? const Color(0xFF22C55E)
                    : color,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        Text('/$total',
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
