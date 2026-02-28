import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/widgets/review_layout/review_status_panel.dart';

/// 审核编辑右侧面板：状态操作 + 分轨汇总 + AI 综合分 + 分轨重跑
class ReviewRightPanel extends StatelessWidget {
  final dynamic shot;

  const ReviewRightPanel({super.key, required this.shot});

  void _toast(BuildContext context, String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.rightPanelBackground,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusPanel(context),
            const Divider(height: 24, color: AppColors.divider),
            _trackSummary(),
            const Divider(height: 24, color: AppColors.divider),
            _aiScore(),
            const Divider(height: 24, color: AppColors.divider),
            _trackRetryActions(context),
            const Divider(height: 24, color: AppColors.divider),
            _batchApprove(context),
          ],
        ),
      ),
    );
  }

  Widget _statusPanel(BuildContext context) {
    return ReviewStatusPanel(
      currentStatus: shot?.reviewStatus ?? 'pending',
      options: const [
        ReviewOption(value: 'pending', label: '待审核', color: Colors.grey),
        ReviewOption(
            value: 'approved', label: '确认通过', color: Colors.green),
        ReviewOption(
            value: 'needsRevision', label: '需修改', color: Colors.orange),
        ReviewOption(
            value: 'rejected', label: '退回重生成', color: Colors.red),
      ],
      onApprove: () => _toast(context, '已确认通过'),
      onReject: () => _toast(context, '已标记需修改'),
    );
  }

  Widget _trackSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('分轨审核汇总',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 8),
        _trackSummaryRow('🎬 视频', '✅', 92, Colors.green),
        _trackSummaryRow('🎤 VO', '✅', 88, Colors.green),
        _trackSummaryRow('🎵 BGM', '✅', 90, Colors.green),
        _trackSummaryRow('🔊 音效', '⚠️', 72, Colors.orange),
        _trackSummaryRow('👄 口型', '✅', 85, Colors.green),
        _trackSummaryRow('🎯 整体', '✅', 87, Colors.green),
      ],
    );
  }

  Widget _trackSummaryRow(
      String label, String statusEmoji, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
              width: 70,
              child: Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]))),
          Text(statusEmoji, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text('$score',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _aiScore() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI 综合分',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text('84/100',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.green[400])),
      ],
    );
  }

  Widget _trackRetryActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('分轨操作',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 8),
        for (final track in ['视频', 'VO', 'BGM', '音效', '口型同步'])
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _toast(context, '重跑 $track'),
                icon: const Icon(AppIcons.refresh, size: 14),
                label: Text('重跑 $track'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  textStyle: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _toast(context, '仅重跑未通过项'),
            icon: const Icon(AppIcons.refresh, size: 14),
            label: const Text('仅重跑未通过项'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 8),
              textStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _batchApprove(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _toast(context, '一键全部通过'),
        icon: const Icon(AppIcons.check, size: 16),
        label: const Text('一键全部通过'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 10),
          textStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
