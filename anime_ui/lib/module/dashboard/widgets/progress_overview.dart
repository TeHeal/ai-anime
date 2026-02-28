import 'package:flutter/material.dart';

import 'package:anime_ui/pub/models/dashboard.dart';
import 'package:anime_ui/pub/theme/colors.dart';

/// 整体进度概览
class ProgressOverview extends StatelessWidget {
  const ProgressOverview({super.key, required this.dash});

  final Dashboard dash;

  @override
  Widget build(BuildContext context) {
    final total = dash.totalEpisodes;
    final done = dash.statusCounts['completed'] ?? 0;
    final inProg = dash.statusCounts['in_progress'] ?? 0;
    final pending = total - done - inProg;
    final pct = total > 0 ? done / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '整体进度',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(pct * 100).toInt()}%',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, value, _) => Row(
                  children: [
                    if (done > 0)
                      Expanded(
                        flex: done,
                        child: Container(
                          color: const Color(0xFF22C55E)
                              .withValues(alpha: value),
                        ),
                      ),
                    if (inProg > 0)
                      Expanded(
                        flex: inProg,
                        child: Container(
                          color: const Color(0xFF3B82F6)
                              .withValues(alpha: value),
                        ),
                      ),
                    if (pending > 0)
                      Expanded(
                        flex: pending,
                        child: Container(color: Colors.grey[800]),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _legendDot(const Color(0xFF22C55E), '已完成 $done'),
              const SizedBox(width: 20),
              _legendDot(const Color(0xFF3B82F6), '进行中 $inProg'),
              const SizedBox(width: 20),
              _legendDot(Colors.grey[600]!, '待开始 $pending'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }
}
