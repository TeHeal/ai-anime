import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/module/assets/overview/providers/overview.dart';

/// 关键问题列表
class KeyIssuesList extends StatelessWidget {
  const KeyIssuesList({super.key, required this.issues});

  final List<KeyIssue> issues;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.warning, size: 18, color: Colors.orange),
            const SizedBox(width: 8),
            Text('关键问题',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[300])),
            const SizedBox(width: 8),
            if (issues.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${issues.length}',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.orange)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (issues.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(AppIcons.check,
                    size: 28, color: const Color(0xFF22C55E)),
                const SizedBox(height: 8),
                Text('所有资产已就绪',
                    style: TextStyle(
                        fontSize: 14, color: const Color(0xFF22C55E))),
              ],
            ),
          )
        else
          ...issues.map((issue) => _buildIssueRow(context, issue)),
      ],
    );
  }

  Widget _buildIssueRow(BuildContext context, KeyIssue issue) {
    final color = switch (issue.severity) {
      KeyIssueSeverity.error => Colors.red,
      KeyIssueSeverity.warning => Colors.orange,
      KeyIssueSeverity.info => Colors.blue,
    };

    final icon = switch (issue.icon) {
      'person' => AppIcons.person,
      'landscape' => AppIcons.landscape,
      'mic' => AppIcons.mic,
      'style' => AppIcons.brush,
      _ => AppIcons.warning,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(issue.text,
                style: const TextStyle(fontSize: 13, color: Colors.white)),
          ),
          GestureDetector(
            onTap: () => context.go(issue.route),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('前往',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}
