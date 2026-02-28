import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// A single QA check item result.
class QACheckItem {
  final String name;
  final int score;
  final String feedback;

  const QACheckItem({
    required this.name,
    required this.score,
    this.feedback = '',
  });

  /// 0-59 fail, 60-79 warn, 80+ pass
  String get status =>
      score >= 80 ? 'pass' : (score >= 60 ? 'warn' : 'fail');
}

/// Displays a list of QA check items with scores, icons, and a total score.
class QAChecklist extends StatelessWidget {
  final List<QACheckItem> items;
  final int? totalScore;
  final VoidCallback? onRerunQA;
  final String title;

  const QAChecklist({
    super.key,
    required this.items,
    this.totalScore,
    this.onRerunQA,
    this.title = 'QA 检查项',
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTotal =
        totalScore ?? (items.isEmpty ? 0 : items.map((e) => e.score).reduce((a, b) => a + b) ~/ items.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const Spacer(),
            Text('$effectiveTotal/100',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _scoreColor(effectiveTotal))),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in items) _buildItem(item),
        if (onRerunQA != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRerunQA,
              icon: const Icon(AppIcons.magicStick, size: 14),
              label: const Text('重新 AI 审核'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItem(QACheckItem item) {
    final color = _statusColor(item.status);
    final icon = _statusIcon(item.status);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(item.name,
                    style: TextStyle(fontSize: 12, color: Colors.grey[300])),
              ),
              Text('${item.score}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
          if (item.feedback.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 2),
              child: Text(item.feedback,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ),
        ],
      ),
    );
  }

  static Color _scoreColor(int score) =>
      score >= 80 ? Colors.green : (score >= 60 ? Colors.orange : Colors.red);

  static Color _statusColor(String status) {
    switch (status) {
      case 'pass':
        return Colors.green;
      case 'warn':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  static IconData _statusIcon(String status) {
    switch (status) {
      case 'pass':
        return AppIcons.check;
      case 'warn':
        return AppIcons.warning;
      default:
        return AppIcons.error;
    }
  }
}
