import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/colors.dart';

/// 解析进度面板 — 展示进度百分比和步骤标签
class ParseProgressPanel extends StatelessWidget {
  const ParseProgressPanel({
    super.key,
    required this.progress,
    required this.stepLabel,
  });

  final int progress;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    final pct = progress.clamp(0, 100);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stepLabel.isEmpty ? '解析中…' : stepLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[200],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct / 100),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: Colors.grey[800],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
