import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/generation_center/styled_card.dart';

/// 导入占位卡片：图标 + 标题 + 可拖拽上传区 + 信息提示
///
/// 用于 shot_images、shots、script 的导入占位
class ImportCardPlaceholder extends StatefulWidget {
  const ImportCardPlaceholder({
    super.key,
    required this.title,
    required this.placeholderLabel,
    this.hintText,
    this.infoText,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String placeholderLabel;

  /// 占位区下方的提示文字（如「支持 PNG/JPG/ZIP 批量导入」）
  final String? hintText;

  /// 信息框内容（如「按文件名自动匹配镜头编号」）
  final String? infoText;

  final VoidCallback? onTap;

  /// 标题行右侧额外内容
  final Widget? trailing;

  @override
  State<ImportCardPlaceholder> createState() => _ImportCardPlaceholderState();
}

class _ImportCardPlaceholderState extends State<ImportCardPlaceholder> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Spacing.sm.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentImport.withValues(alpha: 0.25),
                      AppColors.accentImport.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                ),
                child: Icon(
                  AppIcons.upload,
                  size: 18.r,
                  color: AppColors.accentImport,
                ),
              ),
              SizedBox(width: Spacing.md.w),
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
          SizedBox(height: Spacing.lg.h),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              onTap:
                  widget.onTap ??
                  () {
                    showToast(context, '导入功能开发中', isInfo: true);
                  },
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: _hovered
                      ? AppColors.accentImport.withValues(alpha: 0.6)
                      : AppColors.border.withValues(alpha: 0.5),
                  radius: RadiusTokens.xl.r,
                  dashWidth: 6,
                  dashGap: 4,
                  strokeWidth: 1.2,
                ),
                child: AnimatedContainer(
                  duration: MotionTokens.durationFast,
                  curve: MotionTokens.curveStandard,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: Spacing.xl.h),
                  decoration: BoxDecoration(
                    color: _hovered
                        ? AppColors.surfaceContainer.withValues(alpha: 0.8)
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSlide(
                        duration: MotionTokens.durationFast,
                        curve: MotionTokens.curveStandard,
                        offset:
                            _hovered ? const Offset(0, -0.1) : Offset.zero,
                        child: Icon(
                          AppIcons.uploadOutline,
                          size: 22.r,
                          color: AppColors.accentImport,
                        ),
                      ),
                      SizedBox(height: Spacing.md.h),
                      Text(
                        widget.placeholderLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accentImport,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.hintText != null) ...[
                        SizedBox(height: Spacing.sm.h),
                        Text(
                          widget.hintText!,
                          style: AppTextStyles.tiny.copyWith(
                            color: AppColors.mutedDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.infoText != null) ...[
            SizedBox(height: Spacing.gridGap.h),
            Container(
              padding: EdgeInsets.all(Spacing.sm.r),
              decoration: BoxDecoration(
                color: AppColors.accentImport.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(AppIcons.info, size: 14.r, color: AppColors.mutedDark),
                  SizedBox(width: Spacing.sm.w),
                  Expanded(
                    child: Text(
                      widget.infoText!,
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.mutedDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 虚线圆角矩形边框
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.dashWidth = 6,
    this.dashGap = 4,
    this.strokeWidth = 1,
  });

  final Color color;
  final double radius;
  final double dashWidth;
  final double dashGap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final dashPath = _buildDashPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _buildDashPath(Path source) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        result.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += dashWidth + dashGap;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
