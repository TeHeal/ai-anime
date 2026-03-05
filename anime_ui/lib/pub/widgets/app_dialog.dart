import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';


/// 统一深色主题对话框样式
///
/// 用于 AlertDialog、确认删除、警告等，保持视觉一致
abstract final class AppDialog {
  static ShapeBorder get shape => RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(RadiusTokens.lg.r)),
  );

  static TextStyle get titleStyle =>
      AppTextStyles.h3.copyWith(color: AppColors.onSurface);

  static TextStyle get contentStyle =>
      AppTextStyles.bodyMedium.copyWith(color: AppColors.muted, height: 1.5);

  /// 显示自定义内容对话框（用于 ImageGen、VoiceGen、修改密码等）
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget Function(BuildContext, VoidCallback close) builder,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: shape,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: builder(ctx, () => Navigator.of(ctx).pop()),
      ),
    );
  }

  /// 构建统一样式的 AlertDialog
  static AlertDialog alert({
    required String title,
    required Widget content,
    List<Widget>? actions,
    Color? backgroundColor,
  }) {
    return AlertDialog(
      backgroundColor: backgroundColor ?? AppColors.surface,
      shape: shape,
      title: Text(title, style: titleStyle),
      content: DefaultTextStyle(style: contentStyle, child: content),
      actions: actions,
    );
  }
}
