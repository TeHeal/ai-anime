import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 进度总览条，显示在生成中心配置区和任务区之间，让用户一眼掌握全局进度。
class ProgressSummaryBar extends StatelessWidget {
  const ProgressSummaryBar({
    super.key,
    required this.total,
    required this.completed,
    required this.generating,
    required this.failed,
    this.countLabel = '集',
  });

  final int total;
  final int completed;
  final int generating;
  final int failed;
  final String countLabel;

  int get _pending => (total - completed - generating - failed).clamp(0, total);

  double _fraction(int value) => total > 0 ? value / total : 0;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.cardPadding.w,
        vertical: Spacing.lg.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.2),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildRing(),
          SizedBox(width: Spacing.lg.w),
          Expanded(child: _buildDetails()),
        ],
      ),
    );
  }

  Widget _buildRing() {
    final pct = total > 0 ? (completed * 100 ~/ total) : 0;
    return SizedBox(
      width: 54.r,
      height: 54.r,
      child: CustomPaint(
        painter: _RingPainter(
          completedFraction: _fraction(completed),
          generatingFraction: _fraction(generating),
          failedFraction: _fraction(failed),
          strokeWidth: 5.r,
        ),
        child: Center(
          child: Text(
            '$pct%',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        SizedBox(height: Spacing.sm.h),
        _buildProgressBar(),
        SizedBox(height: Spacing.sm.h),
        _buildLegend(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          '整体进度',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          '$total $countLabel · $completed 已完成',
          style: AppTextStyles.tiny.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      child: SizedBox(
        height: 6.h,
        child: Row(
          children: [
            _barSegment(_fraction(completed), AppColors.success),
            _barSegment(_fraction(generating), AppColors.primary),
            _barSegment(_fraction(failed), AppColors.error),
            _barSegment(_fraction(_pending), AppColors.surfaceContainer),
          ],
        ),
      ),
    );
  }

  Widget _barSegment(double fraction, Color color) {
    if (fraction <= 0) return const SizedBox.shrink();
    return Flexible(
      flex: (fraction * 1000).round().clamp(1, 1000),
      child: Container(color: color),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem('已完成', completed, AppColors.success),
        SizedBox(width: Spacing.lg.w),
        _legendItem('生成中', generating, AppColors.primary),
        SizedBox(width: Spacing.lg.w),
        _legendItem('失败', failed, AppColors.error),
        SizedBox(width: Spacing.lg.w),
        _legendItem('待生成', _pending, AppColors.mutedDark),
      ],
    );
  }

  Widget _legendItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: Spacing.xs.w),
        Text(label, style: AppTextStyles.tiny.copyWith(color: AppColors.muted)),
        SizedBox(width: Spacing.xs.w),
        Text(
          '$count',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

/// 环形进度图画笔，按完成/生成中/失败三段弧绘制
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.completedFraction,
    required this.generatingFraction,
    required this.failedFraction,
    required this.strokeWidth,
  });

  final double completedFraction;
  final double generatingFraction;
  final double failedFraction;
  final double strokeWidth;

  static const _startAngle = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.onSurface.withValues(alpha: 0.05);
    canvas.drawCircle(center, radius, bgPaint);

    var angle = _startAngle;
    void drawArc(double fraction, Color color) {
      if (fraction <= 0) return;
      final sweep = fraction * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(rect, angle, sweep, false, paint);
      angle += sweep;
    }

    drawArc(completedFraction, AppColors.success);
    drawArc(generatingFraction, AppColors.primary);
    drawArc(failedFraction, AppColors.error);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      completedFraction != old.completedFraction ||
      generatingFraction != old.generatingFraction ||
      failedFraction != old.failedFraction;
}
