import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// Status option for the review panel radio selector.
class ReviewOption {
  final String value;
  final String label;
  final Color color;

  const ReviewOption({
    required this.value,
    required this.label,
    required this.color,
  });
}

/// Default review options shared across modules.
const kDefaultReviewOptions = [
  ReviewOption(value: 'pending', label: '待审核', color: Colors.grey),
  ReviewOption(value: 'approved', label: '确认通过', color: Colors.green),
  ReviewOption(value: 'needsRevision', label: '需修改', color: Colors.orange),
];

/// Right-panel section showing review status radios + approve/reject buttons.
class ReviewStatusPanel extends StatelessWidget {
  final String currentStatus;
  final List<ReviewOption> options;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final String approveLabel;
  final String rejectLabel;

  const ReviewStatusPanel({
    super.key,
    required this.currentStatus,
    this.options = kDefaultReviewOptions,
    this.onApprove,
    this.onReject,
    this.approveLabel = '确认通过',
    this.rejectLabel = '标记需修改',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('审核状态',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 12),
        for (final opt in options) _radio(opt),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed:
                currentStatus == 'approved' ? null : onApprove,
            icon: const Icon(AppIcons.check, size: 16),
            label: Text(approveLabel),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 10),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                currentStatus == 'needsRevision' ? null : onReject,
            icon:
                const Icon(AppIcons.warning, size: 16, color: Colors.orange),
            label: Text(rejectLabel,
                style: const TextStyle(color: Colors.orange)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 10),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _radio(ReviewOption opt) {
    final isActive = currentStatus == opt.value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? opt.color : Colors.transparent,
              border:
                  Border.all(color: isActive ? opt.color : Colors.grey[600]!, width: 2),
            ),
          ),
          const SizedBox(width: 8),
          Text(opt.label,
              style: TextStyle(
                  fontSize: 12,
                  color: isActive ? opt.color : Colors.grey[500])),
        ],
      ),
    );
  }
}
