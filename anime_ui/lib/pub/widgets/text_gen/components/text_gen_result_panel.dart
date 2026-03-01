import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import '../text_gen_controller.dart';

/// 文本生成右侧结果面板（空闲 / 生成中 / 结果 / 错误）
class TextGenResultPanel extends StatelessWidget {
  const TextGenResultPanel({
    super.key,
    required this.ctrl,
    required this.accent,
    required this.onGenerate,
  });

  final TextGenController ctrl;
  final Color accent;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: switch (ctrl.status) {
        TextGenStatus.idle => _buildIdlePlaceholder(context),
        TextGenStatus.generating => _buildGenerating(context),
        TextGenStatus.done => _buildResult(context),
        TextGenStatus.error => _buildError(context),
      },
    );
  }

  Widget _buildIdlePlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(Spacing.mid.r),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.document,
              size: 36.r,
              color: accent.withValues(alpha: 0.3),
            ),
          ),
          SizedBox(height: Spacing.lg.h),
          Text(
            '输入指令开始生成',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
          SizedBox(height: Spacing.sm.h),
          Text(
            'AI 将根据你的描述生成文字内容',
            style: AppTextStyles.caption.copyWith(color: AppColors.mutedDarker),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerating(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32.w,
            height: 32.h,
            child: CircularProgressIndicator(strokeWidth: 3.r, color: accent),
          ),
          SizedBox(height: Spacing.lg.h),
          Text(
            '正在生成…',
            style: AppTextStyles.bodyMedium.copyWith(color: accent),
          ),
          SizedBox(height: Spacing.sm.h),
          Text(
            'AI 正在创作中，请稍候',
            style: AppTextStyles.caption.copyWith(color: AppColors.mutedDark),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            Spacing.lg.w,
            Spacing.gridGap.h,
            Spacing.lg.w,
            Spacing.sm.h,
          ),
          child: Row(
            children: [
              Icon(AppIcons.checkOutline, size: 14.r, color: accent),
              SizedBox(width: Spacing.sm.w),
              Text(
                '生成结果',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
              const Spacer(),
              _TinyAction(
                icon: AppIcons.copy,
                label: '复制',
                color: accent,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: ctrl.result));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('已复制到剪贴板'),
                      backgroundColor: AppColors.surfaceContainer,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              SizedBox(width: Spacing.sm.w),
              _TinyAction(
                icon: AppIcons.magicStick,
                label: '重新生成',
                color: AppColors.muted,
                onTap: onGenerate,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              Spacing.lg.w,
              0,
              Spacing.lg.w,
              Spacing.lg.h,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(Spacing.gridGap.r),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                border: Border.all(color: accent.withValues(alpha: 0.15)),
              ),
              child: SelectableText(
                ctrl.result,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurface,
                  height: 1.7,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.error, size: 32.r, color: AppColors.error),
          SizedBox(height: Spacing.md.h),
          Text(
            '生成失败',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          if (ctrl.errorMsg.isNotEmpty) ...[
            SizedBox(height: Spacing.sm.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.xl.w),
              child: Text(
                ctrl.errorMsg,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          SizedBox(height: Spacing.lg.h),
          TextButton.icon(
            onPressed: onGenerate,
            icon: Icon(AppIcons.magicStick, size: 14.r, color: accent),
            label: Text(
              '重试',
              style: AppTextStyles.bodySmall.copyWith(color: accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// 小操作按钮（复制、重新生成等）
class _TinyAction extends StatelessWidget {
  const _TinyAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 12.r, color: color),
      label: Text(label, style: AppTextStyles.tiny.copyWith(color: color)),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm.w,
          vertical: Spacing.xs.h,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
